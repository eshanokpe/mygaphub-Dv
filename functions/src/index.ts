import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {setGlobalOptions} from "firebase-functions/v2";
import * as admin from "firebase-admin";
import * as schedule from "node-schedule";

// Set region if needed
setGlobalOptions({region: "us-central1"});

admin.initializeApp();

// Store scheduled jobs in memory
const scheduledJobs = new Map<string, schedule.Job>();

interface ScheduleReminderRequest {
  reminderId: number;
  title: string;
  body: string;
  scheduleTime: string; // ISO string
  userFcmToken: string;
  deviceType: string;
  amount: string;
  currency: string;
  note?: string;
}

interface ScheduleReminderResponse {
  success: boolean;
  message: string;
  data: {
    jobId: string;
    scheduledAt: string;
    firestoreDocId: string;
  };
}

/**
 * 1. Schedule Reminder Notification - Cloud Function
 * Called from Flutter app
 */
export const scheduleReminderNotification = onCall(
  {
    cors: true, // Enable CORS if needed
    enforceAppCheck: false, // Set to true if using App Check
  },
  async (request): Promise<ScheduleReminderResponse> => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const userId = request.auth.uid;
    const data = request.data as ScheduleReminderRequest;
    const {
      reminderId,
      title,
      scheduleTime,
      userFcmToken,
      deviceType,
      amount,
      currency,
      note,
    } = data;

    // Validate required fields
    if (!reminderId || !title || !scheduleTime || !userFcmToken) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required fields: reminderId, title, scheduleTime, userFcmToken"
      );
    }

    // Parse schedule time
    const scheduledDate = new Date(scheduleTime);
    const now = new Date();

    // Check if time is in the future
    if (scheduledDate <= now) {
      throw new HttpsError(
        "invalid-argument",
        "Schedule time must be in the future"
      );
    }

    // Create notification body with amount and currency
    const notificationBody = note ?
      `${note} - Amount: ${currency}${amount}` :
      `Reminder: ${title} - Amount: ${currency}${amount}`;

    // Create notification payload
    const notificationPayload: admin.messaging.Message = {
      notification: {
        title: title,
        body: notificationBody,
      },
      data: {
        type: "reminder",
        reminder_id: reminderId.toString(),
        title: title,
        body: note || "",
        amount: amount,
        currency: currency,
        action: "view_reminder",
        source: "cloud_function",
      },
      token: userFcmToken,
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: notificationBody,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    };
    console.log(`📅 Scheduling notification for reminder ${reminderId}`);
    console.log(`   User: ${userId}`);
    console.log(`   Title: ${title}`);
    console.log(`   Scheduled for: ${scheduledDate}`);
    try {
      // Store in Firestore for persistence
      const reminderDoc = await admin.firestore()
        .collection("scheduledNotifications")
        .add({
          userId: userId,
          reminderId: reminderId,
          title: title,
          body: notificationBody,
          fcmToken: userFcmToken,
          scheduledAt: scheduledDate,
          deviceType: deviceType,
          amount: amount,
          currency: currency,
          note: note || "",
          status: "scheduled",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Schedule the job
      const job = schedule.scheduleJob(scheduledDate, async () => {
        try {
          console.log(`🔔 Sending scheduled  ${reminderId}`);

          // Send FCM notification
          const response = await admin.messaging().send(notificationPayload);

          console.log(`✅ Notification sent successfully: ${response}`);

          // Update status in Firestore
          await reminderDoc.update({
            status: "sent",
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            messageId: response,
          });

          // Clean up memory
          const jobId = `${userId}_${reminderId}`;
          scheduledJobs.delete(jobId);
        } catch (error) {
          console.error(`❌ Error sending notification: ${error}`);

          // Update status as failed
          await reminderDoc.update({
            status: "failed",
            error: (error as Error).message,
            failedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      });

      // Store job reference
      const jobId = `${userId}_${reminderId}`;
      scheduledJobs.set(jobId, job);

      return {
        success: true,
        message: "Notification scheduled successfully",
        data: {
          jobId: jobId,
          scheduledAt: scheduledDate.toISOString(),
          firestoreDocId: reminderDoc.id,
        },
      };
    } catch (error) {
      console.error("❌ Error scheduling notification:", error);
      throw new HttpsError(
        "internal",
        "Failed to schedule notification"
      );
    }
  }
);

/**
 * 2. Cancel Scheduled Notification - Cloud Function
 */
export const cancelReminderNotification = onCall(
  async (request) => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const data = request.data as { reminderId: number };
    const {reminderId} = data;
    const userId = request.auth.uid;

    if (!reminderId) {
      throw new HttpsError(
        "invalid-argument",
        "Reminder ID is required"
      );
    }

    const jobId = `${userId}_${reminderId}`;

    try {
      // Cancel scheduled job
      const job = scheduledJobs.get(jobId);
      if (job) {
        job.cancel();
        scheduledJobs.delete(jobId);
        console.log(`🗑️ Cancelled scheduled job: ${jobId}`);
      }

      // Update status in Firestore
      const notificationsRef = admin
        .firestore()
        .collection("scheduledNotifications");
      const query = notificationsRef
        .where("userId", "==", userId)
        .where("reminderId", "==", reminderId)
        .where("status", "==", "scheduled");

      const snapshot = await query.get();

      const batch = admin.firestore().batch();
      snapshot.forEach((doc) => {
        batch.update(doc.ref, {
          status: "cancelled",
          cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();

      return {
        success: true,
        message: "Notification cancelled successfully",
        cancelledJobs: snapshot.size,
      };
    } catch (error) {
      console.error("❌ Error cancelling notification:", error);
      throw new HttpsError(
        "internal",
        "Failed to cancel notification"
      );
    }
  }
);

/**
 * 3. Scheduled Function (Cron) - Send pending notifications
 * Runs every minute to catch any missed notifications
 */
export const sendPendingNotifications = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "UTC",
  },
  async () => {
    console.log("⏰ Checking for pending notifications...");

    const now = new Date();
    const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);

    try {
      const notificationsRef = admin
        .firestore()
        .collection("scheduledNotifications");
      const query = notificationsRef
        .where("status", "==", "scheduled")
        .where("scheduledAt", "<=", now)
        .where("scheduledAt", ">=", fiveMinutesAgo);

      const snapshot = await query.get();

      console.log(`📋 Found ${snapshot.size} pending noti`);

      const promises = snapshot.docs.map(async (doc) => {
        const notification = doc.data();

        console.log(`🔔 Sending missed noti ${notification.reminderId}`);

        const payload: admin.messaging.Message = {
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: {
            type: "reminder",
            reminder_id: notification.reminderId.toString(),
            title: notification.title,
            body: notification.note || "",
            amount: notification.amount || "0",
            currency: notification.currency || "₦",
            action: "view_reminder",
            source: "cron_job",
          },
          token: notification.fcmToken,
          apns: {
            payload: {
              aps: {
                alert: {
                  title: notification.title,
                  body: notification.body,
                },
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        try {
          const response = await admin.messaging().send(payload);

          await doc.ref.update({
            status: "sent",
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            messageId: response,
            sentBy: "cron_job",
          });

          console.log(`✅ Sent missed notification: ${notification.reminderId}`);
          return {success: true, reminderId: notification.reminderId};
        } catch (error) {
          console.error(`❌ Failed  ${notification.reminderId}:`, error);

          await doc.ref.update({
            status: "failed",
            error: (error as Error).message,
            failedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          return {
            success: false,
            reminderId: notification.reminderId,
            error: (error as Error).message,
          };
        }
      });

      const results = await Promise.all(promises);

      const successful = results.filter((r) => r.success).length;
      const failed = results.filter((r) => !r.success).length;

      console.log(`📊 Cron job completed: ${successful} sent, ${failed} failed`);
    } catch (error) {
      console.error("❌ Error in cron job:", error);
    }
  }
);
