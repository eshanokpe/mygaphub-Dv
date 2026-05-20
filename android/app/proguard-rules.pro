# Keep your MainActivity and all activities
-keep class com.prismcheck.gaphub.MainActivity { *; }
-keep class com.prismcheck.gaphub.MyFirebaseMessagingService { *; }

# Keep all classes in your app package
-keep class com.prismcheck.gaphub.** { *; }

# Keep Flutter engine and all Flutter-related classes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all Android lifecycle components
-keep class * extends android.app.Activity { *; }
-keep class * extends android.app.Service { *; }
-keep class * extends android.content.BroadcastReceiver { *; }
-keep class * extends android.content.ContentProvider { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep plugin classes
-keep class com.dexterous.** { *; }
-keep class com.pichillilorenzo.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all class names and member names for classes with serialization
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep generic signatures
-keepattributes Signature
-keepattributes *Annotation*

# Keep all public classes with public methods
-keep public class * {
    public protected *;
}

# Keep all classes that might be used via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Ignore Play Core warnings
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep MultiDex
-keep class androidx.multidex.** { *; }

# Keep all constructors
-keepclassmembers class * {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}