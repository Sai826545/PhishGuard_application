# PhishGuard Setup & Execution Guide

PhishGuard is a high-fidelity cyber-security scanning and warning suite comprising:
1. **Backend**: Java Spring Boot Security REST API
2. **Web Application**: React.js (Vite + Vanilla CSS) single-page application
3. **Mobile Application**: Flutter (Riverpod state management) cross-platform client

This document serves as the setup reference to configure, link, and run all three components on a local network.

---

## 🛠️ 1. Prerequisites (What to Download)

Before running the applications, ensure you have the following software installed:

*   **Java SE Development Kit (JDK 17 or higher)**: Required to compile and run the Spring Boot backend. [Download JDK 17](https://www.oracle.com/java/technologies/downloads/).
*   **Node.js (v18 or higher & npm)**: Required to install dependencies and run the React web app. [Download Node.js](https://nodejs.org/).
*   **Flutter SDK (Stable channel)**: Required to build and launch the mobile app. [Download Flutter](https://docs.flutter.dev/get-started/install).
*   **MySQL Server (v8.0 or higher)**: Relational database storing credentials, user logs, and static backup alerts. [Download MySQL](https://dev.mysql.com/downloads/installer/).
*   **Maven**: Package manager for Java. (Included inside the backend root folder as wrapper `./mvnw`, or standalone `mvn`).
*   **Mobile Simulator/Emulator**: Android Studio (AVD) or Xcode (Simulator) configured.

---

## 🗄️ 2. Database Configuration

The backend is configured to use MySQL. To configure database parameters (such as port, database name, username, or password):

1.  Open the backend configuration file:
    `phishguard_backend/src/main/resources/application.properties`
2.  Update the database connection details to match your MySQL server:
    ```properties
    # MySQL Database Connection
    spring.datasource.url=jdbc:mysql://localhost:3306/phishguard_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    spring.datasource.username=YOUR_MYSQL_USERNAME  # e.g., root
    spring.datasource.password=YOUR_MYSQL_PASSWORD  # e.g., mysecurepassword
    spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
    ```
3.  **Automatic Seeding**:
    *   `spring.jpa.hibernate.ddl-auto=update` automatically generates the tables matching the JPA schemas.
    *   `spring.sql.init.mode=always` runs the seeded SQL script (`phishguard_backend/src/main/resources/data.sql`) on start to insert backup alerts, users, and setting parameters automatically if they do not exist.

---

## 🚀 3. Running the Spring Boot Backend

To run the REST API backend:

1.  Open your terminal and navigate to the backend folder:
    ```bash
    cd phishguard_backend
    ```
2.  Build and compile the code:
    ```bash
    mvn clean compile
    ```
3.  Boot up the application:
    ```bash
    mvn spring-boot:run
    ```
4.  The server will spin up on **`http://localhost:8081/api`**.

---

## 💻 4. Running the React.js Web Application

The React.js frontend compiles into optimized HTML/CSS assets and proxies requests automatically:

1.  Open your terminal and navigate to the web directory:
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
4.  Open your browser and navigate to **`http://localhost:5173`**.
5.  *Proxying details*: All REST requests targeting `/api` are automatically proxied via `vite.config.js` to `http://localhost:8081/api` to bypass local CORS rules during development.

---

## 📱 5. Running the Flutter Mobile Application

To connect a mobile emulator or a physical test device on the same local network, you need to match your PC's Wi-Fi IP address.

### Step A: Find your local IPv4 address
*   **Windows**: Open Command Prompt (`cmd`) or PowerShell, run `ipconfig`, and copy the `IPv4 Address` under your wireless adapter (e.g. `192.168.1.5`).
*   **macOS / Linux**: Run `ifconfig` or `ip a` and identify your LAN IP.

### Step B: Sync the connection parameters
1.  **Sync URL**: Open `phishguard_app/lib/core/constants/app_strings.dart` and update the `baseUrl` constant with your machine's IP (port `8081`):
    ```dart
    static const String baseUrl = 'http://192.168.1.5:8081/api';
    ```
2.  **Cleartext Permissions**: Open `phishguard_app/android/app/src/main/res/xml/network_security_config.xml` and make sure your IP is authorized to permit HTTP connection traffic:
    ```xml
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">192.168.1.5</domain>
    </domain-config>
    ```

### Step C: Launch the mobile app
1.  Navigate to the mobile app folder:
    ```bash
    cd phishguard_app
    ```
2.  Fetch packages:
    ```bash
    flutter pub get
    ```
3.  Ensure your device or emulator is booted, and run:
    ```bash
    flutter run
    ```
