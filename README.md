# PhishGuard — Ecosystem Setup & Running Guide

This repository contains the complete **PhishGuard** anti-phishing suite. It consists of four integrated components:
1. 🐍 **Python Machine Learning Service** (`phishguard_ml`) - Naive Bayes text-classification engine.
2. ☕ **Spring Boot Backend API** (`phishguard_backend`) - Relational datastore & scanner coordinator.
3. 💻 **React Web Client** (`phishguard_web`) - Premium Glassmorphic administrative dashboard.
4. 📱 **Flutter Mobile Application** (`phishguard_app`) - Mobile interface for real-time scans.

---

## 🛠️ System Prerequisites

Make sure the following software is installed globally on your machine:
*   **Java JDK 17+**
*   **Node.js (v18+) & npm**
*   **Flutter SDK (v3.x+)**
*   **Python (v3.10+)**
*   **MySQL Server** (running locally)

---

## 🗄️ Database Setup (MySQL)
Before launching the backend api, make sure MySQL is running and setup a database with these settings:
*   **Database Name**: `phishguard_db`
*   **Username**: `root`
*   **Password**: `password`
*(Note: If you have a different root password, update it in `phishguard_backend/src/main/resources/application.properties`)*

---

## 🚀 How to Run the Components

To run PhishGuard, we recommend starting the services in the following order:

### 🐍 Step 1: Run the Machine Learning Service (`phishguard_ml`)
1.  Navigate to the ML folder:
    ```bash
    cd phishguard_ml
    ```
2.  Install required packages:
    ```bash
    pip install -r requirements.txt
    ```
3.  Train the ML Classifier (Downloads dataset and exports model files):
    ```bash
    python train.py
    ```
4.  Run the FastAPI backend server:
    ```bash
    uvicorn app:app --host 127.0.0.1 --port 8000 --reload
    ```
    *   *ML Microservice runs at: `http://127.0.0.1:8000`*

---

### ☕ Step 2: Run the Spring Boot Backend API (`phishguard_backend`)
1.  Navigate to the backend directory:
    ```bash
    cd phishguard_backend
    ```
2.  Verify connection settings in `src/main/resources/application.properties`.
3.  Run the Spring Boot application:
    ```bash
    mvn spring-boot:run
    ```
    *   *The API backend will start on port `8081` at: `http://localhost:8081/api`*

---

### 💻 Step 3: Run the React Web Dashboard (`phishguard_web`)
1.  Navigate to the web app directory:
    ```bash
    cd phishguard_web
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Start the local development server:
    ```bash
    npm run dev
    ```
    *   *The Web dashboard will launch at: `http://localhost:5173`*

---

### 📱 Step 4: Run the Flutter Mobile App (`phishguard_app`)

> [!IMPORTANT]
> When testing on a **physical device** or **Android Emulator**, local host mapping changes.
> Open `lib/core/network/api_client.dart` in the mobile app and configure your computer's local network IP address (e.g., `192.168.1.8`) to bridge connection calls to your local Spring Boot server.

1.  Navigate to the mobile directory:
    ```bash
    cd phishguard_app
    ```
2.  Get packages:
    ```bash
    flutter pub get
    ```
3.  Ensure your device or emulator is active, and run the app:
    ```bash
    flutter run
    ```
