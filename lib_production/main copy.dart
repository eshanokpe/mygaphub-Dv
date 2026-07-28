import 'dart:async';
import 'package:GapHub/provider/signin_preferences_provider.dart';
import 'package:GapHub/service/navigation_service.dart';
import 'package:GapHub/service/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';
import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/provider/marketOpportunitiesProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/pinScreen.dart';
import 'package:GapHub/screens/others/splashscreen.dart';
import 'package:GapHub/route_utils.dart';
import 'package:GapHub/service/deepLink_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';
import 'models/preferencesModel.dart';
import 'provider/AuthProvider.dart';
import 'provider/activity_provider.dart';
import 'provider/currencyProvider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'provider/notification_provider.dart';
import 'provider/reminderProvider.dart';
import 'screens/reminder/reminder.dart';
import 'service/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();

  runApp(_buildApp());
}

Widget _buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ChangeNotifierProvider(create: (_) => Providers()),
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => AcquisitionProvider()),
      ChangeNotifierProvider(create: (_) => AcquisiProvider()),
      ChangeNotifierProvider(create: (_) => MarketOpportunitiesProvider()),
      ChangeNotifierProvider(create: (_) => SignInPreferencesProvider()),
      ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ChangeNotifierProxyProvider<ReminderProvider, NotificationProvider>(
        create: (ctx) => NotificationProvider(
          Provider.of<ReminderProvider>(ctx, listen: false),
        ),
        update: (ctx, reminder, previous) =>
            previous ?? NotificationProvider(reminder),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (_) => PreferencesModel(
          paymentReminders: true,
          acquisitionOpportunities: true,
          newsUpdates: true,
          personalStrategy: true,
          personalizedInsights: true,
          marketingPromotions: true,
          marketingDeliveryMethod: 'all',
        ),
      ),
    ],
    child: const MyApp(),
  );
}

Future<void> _initializeApp() async {
  tz.initializeTimeZones();
  await _configureLocalTimeZone();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  await notificationService.checkIOSPermissions();

  await _ensureFirebaseInitialized();

  await PushNotificationService().initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

Future<FirebaseApp> _ensureFirebaseInitialized() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      print('ℹ️ Firebase already initialized, using existing instance');
      return Firebase.app();
    }

    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    return app;
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print('ℹ️ Firebase default app already exists, reusing instance');
      return Firebase.app();
    }
    rethrow;
  }
}

// Helper function to configure local timezone
Future<void> _configureLocalTimeZone() async {
  try {
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print('✅ Timezone set to: $timeZoneName');
  } catch (e) {
    print('❌ Timezone error: $e');
    // Fallback to a safe default timezone
    tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _lockScreenTimer;
  Timer? _notificationCheckerTimer; // Add this
  late DeepLinkService _deepLinkService;
  late PushNotificationService _pushNotificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _trackInitialAppOpen();
    _deepLinkService = DeepLinkService(NavigationService2.navigatorKey);
    _deepLinkService.initDeepLinks();
    _initializePushNotifications();
    _startNotificationChecker(); // Add this
    // Fetch notifications when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotificationsOnAppStart();
    });
  }

  void _fetchNotificationsOnAppStart() {
    final context = NavigationService2.navigatorKey.currentContext;
    if (context != null) {
      try {
        print('📱 Fetching notifications on app start');
        final provider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        provider.fetchNotifications(refresh: true);
      } catch (e) {
        print('❌ Error fetching notifications on app start: $e');
      }
    }
  }

  void _startNotificationChecker() {
    // Check for new notifications every 20 seconds when app is active
    _notificationCheckerTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) {
      final context = NavigationService2.navigatorKey.currentContext;
      if (context == null) return;
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      if (!provider.isLoading) {
        // guard added
        _checkForNewNotifications();
      }
      _cleanupShownNotificationIds();
    });
  }

  Future<void> _cleanupShownNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shownIds = prefs.getStringList('shown_notification_ids') ?? [];

      if (shownIds.length > 100) {
        // Keep only last 100 shown IDs
        final recentIds = shownIds.sublist(shownIds.length - 100);
        await prefs.setStringList('shown_notification_ids', recentIds);
        print('🧹 Cleaned up shown notification IDs');
      }
    } catch (e) {
      print('Error cleaning up shown notification IDs: $e');
    }
  }

  void _checkForNewNotifications() {
    final context = NavigationService2.navigatorKey.currentContext;
    if (context != null) {
      try {
        final provider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        // Fetch notifications silently (without loading indicator)
        provider.fetchNotifications(refresh: true);
      } catch (e) {
        print('Error checking notifications: $e');
      }
    }
  }

  void _initializePushNotifications() {
    _pushNotificationService = PushNotificationService();

    // Set up global notification listeners
    _pushNotificationService.onMessageReceived = (data) {
      _handleForegroundNotification(data);
    };

    _pushNotificationService.onNotificationOpened = (data) {
      _handleNotificationTap(data);
    };

    // Set navigator key for push notifications
    PushNotificationService.navigatorKey = NavigationService2.navigatorKey;
  }

  void _handleForegroundNotification(Map<String, dynamic> data) {
    print('📱 FCM message received in foreground: ${data['title']}');

    // Refresh notifications in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = NavigationService2.navigatorKey.currentContext;
      if (context != null) {
        final provider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        provider.fetchNotifications();
      }
    });
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final category = data['category'];
    final notificationId = data['notification_id'];

    print('📍 Handling notification tap: $category, ID: $notificationId');

    // Mark as read
    if (notificationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = NavigationService2.navigatorKey.currentContext;
        if (context != null) {
          final provider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );
          provider.markAsRead(notificationId);
        }
      });
    }
    // Navigate based on category
    final navigatorKey = NavigationService2.navigatorKey;
    if (navigatorKey.currentState != null) {
      print("Notification Page: $category");
      switch (category) {
        case 'reminder':
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => const ReminderScreen()),
          );
          break;
        case 'notification':
          // navigatorKey.currentState!.push(
          //   MaterialPageRoute(builder: (context) => const NotificationsScreen()),
          // );
          break;
        // Add other cases as needed
        default:
        // Navigate to general notifications screen
        // navigatorKey.currentState!.push(
        //   MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        // );
      }
    }
  }

  void _trackInitialAppOpen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackAppOpen();
    });
  }

  void _trackAppOpen() {
    Provider.of<ActivityProvider>(context, listen: false).trackAppOpen();
  }

  @override
  void dispose() {
    _lockScreenTimer?.cancel();
    _notificationCheckerTimer?.cancel(); // Don't forget this
    _deepLinkService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _lockScreenTimer = Timer(
          const Duration(seconds: 60),
          _showLockScreenDialog,
        );
        break;
      case AppLifecycleState.resumed:
        _lockScreenTimer?.cancel();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        var currency = context.watch<Providers>().snapshotmodel.currency;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!provider.initialLoadDone && !provider.isLoading) {
            provider.ensureInitialLoad(currency);
          }
        });
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return GetMaterialApp(
              title: 'GAPhub',
              navigatorKey: NavigationService2.navigatorKey,
              locale: const Locale('en', 'GB'),
              supportedLocales: const [
                Locale('en', 'GB'),
                Locale('en', 'US'), // Add others as needed
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              // builder: EasyLoading.init(),
              builder: (context, widget) {
                // Set the navigator key for push notifications
                PushNotificationService.navigatorKey =
                    NavigationService2.navigatorKey;

                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler
                        .noScaling, // ✅ replaces deprecated textScaleFactor
                  ),
                  child: EasyLoading.init()(context, widget),
                );
              },
              theme: ThemeData(
                useMaterial3: true,
                actionIconTheme: ActionIconThemeData(
                  backButtonIconBuilder: (context) {
                    return Icon(
                      Icons.arrow_back_ios_new,
                      size: 15.sp,
                      color: Colors.white,
                    );
                  },
                ),
                appBarTheme: const AppBarTheme(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffED3237),
                  iconTheme: IconThemeData(size: 24.0),
                  actionsIconTheme: IconThemeData(size: 24.0),
                ),
                fontFamily: 'Nunito',
                scaffoldBackgroundColor: const Color(0xffffffff),
                highlightColor: const Color(0xffED3237).withValues(alpha: 0.5),
                primaryColor: const Color(0xffED3237),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(secondary: const Color(0xff494949)),
              ),
              home: UpgradeAlert(
                dialogStyle: UpgradeDialogStyle.cupertino,
                child: SplashScreen(),
              ),
              routes: appRoutes,
            );
          },
        );
      },
    );
  }

  void _showLockScreenDialog() {
    if (NavigationService2.navigatorKey.currentState?.mounted ?? false) {
      NavigationService2.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const PinScreen()),
      );
    }
  }
}
