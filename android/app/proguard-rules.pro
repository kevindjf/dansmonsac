# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep Riverpod generated code
-keep class **$ProviderAdapter { *; }
-keepclassmembers class * extends riverpod.ProviderBase {
    *;
}

# Google Play Core (for deferred components - not used but referenced by Flutter)
# Ignore missing classes from Play Core library - these are optional Flutter features we don't use
-dontwarn com.google.android.play.core.**
-dontnote com.google.android.play.core.**
