# Flutter default ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google ML Kit ProGuard rules
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.ml.** { *; }
-dontwarn com.google.mlkit.**
