# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.platform.** { *; }

# Flutter Embedding rules - IMPORTANT pour éviter les erreurs R8
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# SQLite specific rules
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep annotation used by Flutter plugins
-keep class androidx.annotation.Keep
-keep @androidx.annotation.Keep class * {*;}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <init>(...);
}

# Google Play Core rules - CORRIGÉ pour éviter les erreurs R8
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Flutter Play Store Split Application - NOUVEAU
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Riverpod rules
-keep class ** extends com.google.firebase.appcheck.interop.InteropRegistrar { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Additional common rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# File provider rules
-keep class androidx.core.content.FileProvider
-keep class androidx.core.app.CoreComponentFactory

# Keep Gson classes
-keep class com.google.gson.** { *; }

# Règles pour bibliothèques tierces manquantes - NOUVEAU-dontwarn org.objenesis.**-dontwarn net.bytebuddy.**-dontwarn org.mockito.**# AJOUTÉ: Règles pour les dépendances de test qui apparaissent en release-dontwarn junit.**-dontwarn org.hamcrest.**-dontwarn org.junit.**-dontwarn androidx.test.**# AJOUTÉ: Règles supplémentaires pour Play Core-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication-dontwarn com.google.android.play.core.splitinstall.**-dontwarn com.google.android.play.core.tasks.**

# Keep serializable classes (important pour les classes de données)
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
} 