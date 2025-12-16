#!/bin/bash
set -e

echo "Creando estructura OIG-QuantumCode-Labs..."
ROOT="OIG-QuantumCode-Labs"
rm -rf "$ROOT"
mkdir -p "$ROOT"

cd "$ROOT"

# carpetas app
mkdir -p app/src/main/java/com/oig/quantumcode/ui/home
mkdir -p app/src/main/java/com/oig/quantumcode/ui/video
mkdir -p app/src/main/java/com/oig/quantumcode/ui/voice
mkdir -p app/src/main/java/com/oig/quantumcode/ui/image
mkdir -p app/src/main/java/com/oig/quantumcode/ui/settings
mkdir -p app/src/main/java/com/oig/quantumcode/ai/video
mkdir -p app/src/main/java/com/oig/quantumcode/ai/image
mkdir -p app/src/main/java/com/oig/quantumcode/core
mkdir -p app/src/main/java/com/oig/quantumcode/utils
mkdir -p app/src/main/res/values

# backend & ai_core
mkdir -p backend/api
mkdir -p backend/video
mkdir -p backend/image
mkdir -p backend/voice
mkdir -p ai_core/video
mkdir -p ai_core/image
mkdir -p ai_core/voice

mkdir -p .github/workflows
mkdir -p docs

echo "Escribiendo archivos..."

cat > .gitignore <<'GIT'
.gradle/
build/
app/build/
local.properties
*.keystore
.idea/
*.iml
*.apk
.env
GIT

cat > README.md <<'MD'
# OIG QuantumCode Labs

Proyecto base (Opción A): App Android (Kotlin) + Backend FastAPI + Módulos IA.
Estructura profesional lista para editar en Termux y compilar en GitHub Actions.

Instrucciones rápidas:
1. En Termux: ejecutar setup.sh (si no lo hiciste).
2. Editar archivos en app/src/main/java/com/oig/quantumcode.
3. Subir a GitHub y activar Actions (para APK).
4. Ejecutar backend en servidor con RUNWAY_API_KEY para video IA.

MD

cat > config.json <<'JSON'
{
  "app_title": "OIG QuantumCode Labs",
  "chat_api_url": "http://127.0.0.1:8000/chat",
  "image_api_url": "http://127.0.0.1:8000/image",
  "voice_api_url": "http://127.0.0.1:8000/voice",
  "video_api_url": "http://127.0.0.1:8000/video",
  "api_key": ""
}
JSON

# settings.gradle
cat > settings.gradle <<'SG'
rootProject.name = "OIGQuantumCodeLabs"
include ':app'
SG

# root buildscript minimal
cat > build.gradle <<'BG'
buildscript {
    repositories { google(); mavenCentral() }
    dependencies { classpath 'com.android.tools.build:gradle:7.4.2' }
}
allprojects { repositories { google(); mavenCentral() } }
BG

# app module build.gradle
cat > app/build.gradle <<'AG'
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'

android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.oig.quantumcode"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.10"
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.squareup.okhttp3:okhttp:4.11.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'com.google.code.gson:gson:2.10.1'
}
AG

# AndroidManifest
cat > app/src/main/AndroidManifest.xml <<'AM'
<manifest package="com.oig.quantumcode" xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="@string/app_name"
        android:allowBackup="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">
        <activity android:name=".ui.video.VideoScreen" />
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
AM

# strings
cat > app/src/main/res/values/strings.xml <<'SS'
<resources>
    <string name="app_name">OIG QuantumCode Labs</string>
</resources>
SS

# MainActivity
cat > app/src/main/java/com/oig/quantumcode/MainActivity.kt <<'MA'
package com.oig.quantumcode

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        ConfigManager.refreshAsync(this)

        val btnChat = Button(this).apply { text = "Chat IA" }
        val btnImage = Button(this).apply { text = "Generar Imagen" }
        val btnVoice = Button(this).apply { text = "TTS / STT" }
        val btnVideo = Button(this).apply { text = "Generar Video IA" }

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(btnChat)
            addView(btnImage)
            addView(btnVoice)
            addView(btnVideo)
        }

        setContentView(layout)

        btnVideo.setOnClickListener {
            startActivity(Intent(this, Class.forName("com.oig.quantumcode.ui.video.VideoScreen")))
        }
    }
}
MA

# ConfigManager
cat > app/src/main/java/com/oig/quantumcode/ConfigManager.kt <<'CM'
package com.oig.quantumcode

import android.content.Context
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

object ConfigManager {
    private const val REMOTE = "https://raw.githubusercontent.com/TU_USUARIO/OIG-QuantumCode-Labs/main/config.json"
    private const val PREFS = "oig_config"
    private const val KEY_CACHE = "config_cache"

    fun getConfig(context: Context): JSONObject {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val cached = prefs.getString(KEY_CACHE, null)
        if (cached != null) {
            try { return JSONObject(cached) } catch (_: Exception) {}
        }
        return try {
            val conn = URL(REMOTE).openConnection() as HttpURLConnection
            conn.connectTimeout = 3000
            conn.readTimeout = 3000
            conn.requestMethod = "GET"
            conn.connect()
            val text = conn.inputStream.bufferedReader().use { it.readText() }
            val json = JSONObject(text)
            prefs.edit().putString(KEY_CACHE, json.toString()).apply()
            json
        } catch (e: Exception) {
            JSONObject().put("video_api_url", "http://127.0.0.1:8000/video")
        }
    }

    fun refreshAsync(context: Context) {
        thread {
            try {
                val conn = URL(REMOTE).openConnection() as HttpURLConnection
                conn.connectTimeout = 5000
                conn.readTimeout = 5000
                val text = conn.inputStream.bufferedReader().use { it.readText() }
                val json = JSONObject(text)
                context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    .edit().putString(KEY_CACHE, json.toString()).apply()
            } catch (_: Exception) {}
        }
    }
}
CM

# ApiService (OkHttp sync helper)
cat > app/src/main/java/com/oig/quantumcode/ApiService.kt <<'AS'
package com.oig.quantumcode

import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

object ApiService {
    private val client = OkHttpClient()

    fun postJson(url: String, json: String, apiKey: String?): String {
        val body = json.toRequestBody("application/json".toMediaTypeOrNull())
        val builder = Request.Builder().url(url).post(body)
        apiKey?.let { builder.addHeader("Authorization", "Bearer $it") }
        val resp = client.newCall(builder.build()).execute()
        return resp.body?.string() ?: "{}"
    }
}
AS

# VideoGenerator (Kotlin)
cat > app/src/main/java/com/oig/quantumcode/ai/video/VideoGenerator.kt <<'VG'
package com.oig.quantumcode.ai.video

import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

object VideoGenerator {
    private val client = OkHttpClient()

    fun requestVideo(apiUrl: String, prompt: String, duration: Int = 4, apiKey: String? = null): String {
        val json = JSONObject()
            .put("prompt", prompt)
            .put("duration", duration)
            .put("style", "cinematic")
            .toString()
        val body = json.toRequestBody("application/json".toMediaTypeOrNull())
        val builder = Request.Builder().url(apiUrl).post(body)
        apiKey?.let { builder.addHeader("Authorization", "Bearer $it") }
        val resp = client.newCall(builder.build()).execute()
        return resp.body?.string() ?: "{}"
    }
}
VG

# VideoScreen activity (minimal)
cat > app/src/main/java/com/oig/quantumcode/ui/video/VideoScreen.kt <<'VS'
package com.oig.quantumcode.ui.video

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.EditText
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.*
import org.json.JSONObject
import com.oig.quantumcode.ConfigManager
import com.oig.quantumcode.ai.video.VideoGenerator

class VideoScreen : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val et = EditText(this)
        et.hint = "Prompt del video…"
        val btn = Button(this)
        btn.text = "Generar video IA"

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(et)
            addView(btn)
        }
        setContentView(layout)

        btn.setOnClickListener {
            val prompt = et.text.toString()
            if (prompt.isBlank()) { Toast.makeText(this, "Escribe un prompt", Toast.LENGTH_SHORT).show(); return@setOnClickListener }

            val cfg = ConfigManager.getConfig(this)
            val apiUrl = cfg.optString("video_api_url", "http://127.0.0.1:8000/video")
            val apiKey = cfg.optString("api_key", null)

            GlobalScope.launch(Dispatchers.IO) {
                val resp = VideoGenerator.requestVideo(apiUrl, prompt, 4, apiKey)
                val json = JSONObject(resp)
                if (json.optString("status") == "ok") {
                    val url = json.optString("url")
                    runOnUiThread {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                    }
                } else {
                    runOnUiThread {
                        Toast.makeText(this@VideoScreen, "Error: ${json.optString("message")}", Toast.LENGTH_LONG).show()
                    }
                }
            }
        }
    }
}
VS

# backend server minimal
cat > backend/api/app.py <<'SA'
from fastapi import FastAPI
from pydantic import BaseModel
from ai_core.video_gen import generate_video

app = FastAPI(title="OIG QuantumCode Labs API")

class VideoReq(BaseModel):
    prompt: str
    duration: int = 4
    style: str = "cinematic"

@app.get("/")
async def root():
    return {"status":"ok"}

@app.post("/video")
async def video(req: VideoReq):
    return generate_video(req.prompt, req.duration, req.style)
SA

# ai_core python files
cat > ai_core/video/video_gen.py <<'VGpy'
import os
import requests

RUNWAY_API_KEY = os.environ.get("RUNWAY_API_KEY")
RUNWAY_URL = "https://api.runwayml.com/v1/video/generate"  # verificar documentación oficial

def generate_video(prompt: str, duration: int = 4, style: str = "cinematic"):
    if not RUNWAY_API_KEY:
        return {
            "status": "ok",
            "url": "https://example.com/mock_video.mp4",
            "note": "mock mode - set RUNWAY_API_KEY"
        }
    headers = {"Authorization": f"Bearer {RUNWAY_API_KEY}", "Content-Type": "application/json"}
    payload = {"prompt": prompt, "duration": duration, "style": style}
    try:
        r = requests.post(RUNWAY_URL, headers=headers, json=payload, timeout=300)
        r.raise_for_status()
        data = r.json()
        video_url = data.get("video_url") or data.get("result_url") or data.get("url")
        if not video_url:
            return {"status": "error", "message": "No video_url in response", "raw": data}
        return {"status":"ok","url": video_url}
    except Exception as e:
        return {"status":"error","message": str(e)}
VGpy

# minimal ai_core placeholders for image/voice/text
cat > ai_core/image/image_gen.py <<'IMG'
def generate_image(prompt: str):
    return {"status":"ok","url":"https://example.com/mock_image.png"}
IMG

cat > ai_core/voice/voice_gen.py <<'VG'
def text_to_speech(text: str):
    return {"status":"ok","path":"output.wav"}
VG

# backend requirements and Dockerfile
cat > backend/requirements.txt <<'R'
fastapi
uvicorn[standard]
requests
python-dotenv
R

cat > backend/Dockerfile <<'DF'
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "api.app:app", "--host", "0.0.0.0", "--port", "8000"]
DF

# GitHub Actions for Android
cat > .github/workflows/android_build.yml <<'YML'
name: Android Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Cache Gradle
      uses: actions/cache@v4
      with:
        path: |
          ~/.gradle/caches
          ~/.gradle/wrapper
        key: gradle-${{ runner.os }}-${{ hashFiles('**/*.gradle*','**/gradle-wrapper.properties') }}
    - name: Build Debug APK
      working-directory: ./app
      run: ./gradlew assembleDebug --no-daemon
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug-apk
        path: app/app/build/outputs/**/*.apk
YML

echo "Estructura y archivos creados en $(pwd)"
echo "Recuerda editar ConfigManager.REMOTE para poner tu usuario GitHub y revisar RUNWAY_API_KEY."
echo "Termina con: git init && git add . && git commit -m 'scaffold' && git remote add origin https://github.com/TU_USUARIO/OIG-QuantumCode-Labs.git && git push -u origin main"

