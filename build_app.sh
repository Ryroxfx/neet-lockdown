#!/bin/bash
# ATM NEET LOCKDOWN - STABLE PROJECT STRUCTURE GENERATOR

echo "[+] Creating Standard Directory Structure..."
mkdir -p app/gradle/wrapper
mkdir -p app/app/src/main/java/com/atm/neetlockdown/core/security
mkdir -p app/app/src/main/java/com/atm/neetlockdown/data/database
mkdir -p app/app/src/main/java/com/atm/neetlockdown/presentation/ui
mkdir -p app/app/src/main/java/com/atm/neetlockdown/ui/theme
mkdir -p app/app/src/main/res/xml

# 1. GRADLE WRAPPER PROPERTIES
cat << 'EOF' > app/gradle/wrapper/gradle-wrapper.properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# 2. APP BUILD.GRADLE.KTS
cat << 'EOF' > app/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("kotlin-kapt")
}
android {
    namespace = "com.atm.neetlockdown"
    compileSdk = 34
    defaultConfig {
        applicationId = "com.atm.neetlockdown"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.8" }
}
dependencies {
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation(platform("androidx.compose:compose-bom:2024.02.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.navigation:navigation-compose:2.7.7")
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
}
EOF

# 3. ANDROID MANIFEST
cat << 'EOF' > app/app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.atm.neetlockdown">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <application
        android:allowBackup="false"
        android:label="A.T.M. NEET LOCKDOWN"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.DeviceDefault.NoActionBar">
        <activity android:name=".MainActivity" android:exported="true" android:launchMode="singleTask">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <service android:name=".core.security.AtmLockdownService" android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE" android:exported="false">
            <intent-filter><action android:name="android.accessibilityservice.AccessibilityService" /></intent-filter>
            <meta-data android:name="android.accessibilityservice" android:resource="@xml/accessibility_service_config" />
        </service>
        <receiver android:name=".core.security.AntiCheatReceiver" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.TIME_SET" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
EOF

# 4. ACCESSIBILITY CONFIG
cat << 'EOF' > app/app/src/main/res/xml/accessibility_service_config.xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagIncludeNotImportantViews"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="50" />
EOF

# 5. LOCKDOWN SERVICE
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/core/security/AtmLockdownService.kt
package com.atm.neetlockdown.core.security
import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import com.atm.neetlockdown.MainActivity

class AtmLockdownService : AccessibilityService() {
    private val allowedPackages = setOf(
        "com.atm.neetlockdown", "com.google.android.youtube", "com.openai.chatgpt",
        "com.google.android.apps.bard", "com.whatsapp", "com.android.camera", "com.android.gallery"
    )
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val launchedPackage = event.packageName?.toString() ?: return
            if (launchedPackage == "com.android.settings" || !allowedPackages.contains(launchedPackage)) {
                val intent = Intent(this, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(intent)
            }
        }
    }
    override fun onInterrupt() {}
}
EOF

# 6. ANTI-CHEAT RECEIVER
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/core/security/AntiCheatReceiver.kt
package com.atm.neetlockdown.core.security
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class AntiCheatReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Toast.makeText(context, "A.T.M. SECURITY SYSTEM: ACTIVE PROTECTION", Toast.LENGTH_LONG).show()
    }
}
EOF

# 7. DATABASE ENTITIES
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/data/database/Entities.kt
package com.atm.neetlockdown.data.database
import androidx.room.*

@Entity(tableName = "users")
data class UserEntity(@PrimaryKey val uid: String = "CURRENT_STUDENT", val currentStreak: Int = 0)

@Entity(tableName = "ncert_books")
data class NcertBookEntity(@PrimaryKey val chapterId: String, val chapterName: String, val contentMarkdown: String)

@Entity(tableName = "printable_flashcards")
data class PrintableFlashcardEntity(@PrimaryKey val cardId: String, val chapterId: String, val questionFront: String, val answerBack: String)
EOF

# 8. DATABASE MASTER
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/data/database/AtmDatabase.kt
package com.atm.neetlockdown.data.database
import android.content.Context
import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface AtmDao {
    @Query("SELECT * FROM users WHERE uid = 'CURRENT_STUDENT'")
    fun getStudentProfile(): Flow<UserEntity?>
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun saveStudentProfile(user: UserEntity)
}

@Database(entities = [UserEntity::class, NcertBookEntity::class, PrintableFlashcardEntity::class], version = 1, exportSchema = false)
abstract class AtmDatabase : RoomDatabase() {
    abstract fun atmDao(): AtmDao
    companion object {
        fun getDatabase(context: Context): AtmDatabase {
            return Room.databaseBuilder(context.applicationContext, AtmDatabase::class.java, "atm_db").build()
        }
    }
}
EOF

# 9. THEME
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/ui/theme/Theme.kt
package com.atm.neetlockdown.ui.theme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

@Composable
fun AtmNeetTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = darkColorScheme(primary = Color(0xFFFFD700), background = Color(0xFF000000), surface = Color(0xFF111111)),
        content = content
    )
}
EOF

# 10. DASHBOARD SCREEN UI
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/presentation/ui/DashboardScreen.kt
package com.atm.neetlockdown.presentation.ui
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.atm.neetlockdown.ui.theme.AtmNeetTheme

@Composable
fun DashboardScreen() {
    var activeTab by remember { mutableStateOf("DASHBOARD") }
    AtmNeetTheme {
        Column(modifier = Modifier.fillMaxSize().background(Color.Black).padding(16.dp)) {
            Text("A.T.M. OPERATING ENVIRONMENT v1.0", color = MaterialTheme.colorScheme.primary, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(12.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { activeTab = "DASHBOARD" }, modifier = Modifier.weight(1f)) { Text("STATS") }
                Button(onClick = { activeTab = "NCERT" }, modifier = Modifier.weight(1f)) { Text("BOOKS") }
                Button(onClick = { activeTab = "CARDS" }, modifier = Modifier.weight(1f)) { Text("PRINTS") }
            }
            Spacer(modifier = Modifier.height(16.dp))
            when (activeTab) {
                "DASHBOARD" -> {
                    Card(colors = CardDefaults.cardColors(containerColor = Color(0xFF111111)), modifier = Modifier.fillMaxWidth()) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("STREAK COUNT", color = Color.Gray, fontSize = 12.sp)
                            Text("1 DAYS", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Black)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text("LOCKDOWN PHASE: ACTIVE Protection", color = MaterialTheme.colorScheme.primary, fontSize = 12.sp)
                        }
                    }
                }
                "NCERT" -> {
                    Box(modifier = Modifier.fillMaxSize().border(1.dp, Color.DarkGray).background(Color(0xFF0A0A0A)).padding(12.dp)) {
                        Text("NCERT BIOLOGY - CELL\n\n[NCERT Text loaded successfully from local repository.]", color = Color.LightGray, fontSize = 14.sp)
                    }
                }
                "CARDS" -> {
                    Box(modifier = Modifier.fillMaxWidth().height(150.dp).border(1.dp, Color.LightGray).background(Color.White).padding(12.dp)) {
                        Column {
                            Text("[FRONT SIDE - QUESTION]", color = Color.DarkGray, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            Text("Draw and label Mitochondria Matrix.", color = Color.Black, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }
    }
}
EOF

# 11. MAIN ACTIVITY
cat << 'EOF' > app/app/src/main/java/com/atm/neetlockdown/MainActivity.kt
package com.atm.neetlockdown
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.atm.neetlockdown.presentation.ui.DashboardScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { DashboardScreen() }
    }
}
EOF

# 12. ROOT GRADLE FILES
cat << 'EOF' > app/build.gradle.kts
plugins {
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}
EOF

cat << 'EOF' > app/settings.gradle.kts
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "atm-neet-lockdown"
include(":app")
EOF

# 13. GRADLE WRAPPER JAR DOWNLOAD
curl -sL https://github.com/gradle/gradle/raw/v8.4.0/gradle/wrapper/gradle-wrapper.jar -o app/gradle/wrapper/gradle-wrapper.jar
touch app/gradlew
cat << 'EOF' > app/gradlew
#!/usr/bin/env bash
# Gradle Wrapper Stub Script
exec bash "$(dirname "$0")/gradle/wrapper/gradle-wrapper.jar" "$@"
EOF
chmod +x app/gradlew

echo "[+] Setup Complete Structure Built!"
