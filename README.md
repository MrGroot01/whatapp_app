# Velora – Flutter Chat Application

<p align="center">
  <strong>A modern, real-time messaging application built with Flutter and Firebase.</strong>
</p>

<p align="center">
  A WhatsApp-inspired mobile application focused on real-time communication, offline messaging, and a smooth user experience.
</p>

---

## 📱 Project Overview

**Velora** is a Flutter-based mobile messaging application designed to provide a reliable and user-friendly communication experience.

The application uses Firebase for authentication, real-time database synchronization, cloud storage, and push notifications. SQLite provides local data storage and offline support, while Provider manages application state.

The project follows a modular architecture that separates UI screens, business logic, data models, and backend services.

---

## ✨ Features

### Authentication and Profile
- Firebase Authentication integration.
- User account management.
- User profile management.

### Messaging
- One-to-one conversations.
- Real-time message synchronization.
- Message forwarding.
- Message status management.
- Support for different message types.

### Group Communication
- Group creation and management.
- Group conversations.
- Group member management.

### Contacts
- Add new contacts.
- Contact management.
- Search contacts.
- Firebase-based contact synchronization.

### Notifications
- Firebase Cloud Messaging integration.
- Push notification support.
- Incoming message notifications.

### Offline Support
- Local message storage using SQLite.
- Offline message access.
- Pending message outbox.
- Message synchronization when connectivity is restored.

### User Interface
- Modern messaging interface.
- WhatsApp-inspired design.
- Reusable UI components.
- Centralized strings, icons, and colors.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Firebase Realtime Database | Real-time data synchronization |
| Firebase Storage | Media storage |
| Firebase Cloud Messaging | Push notifications |
| SQLite (sqflite) | Local database and offline storage |
| Provider | State management |
| Google Fonts | Typography |
| Android Studio | Development environment |
| Git & GitHub | Version control |

---

## 🏗️ Project Architecture

Velora follows a modular, MVC-inspired architecture with Provider-based state management.

```text
lib/
│
├── core/
│   ├── app_brand.dart
│   ├── app_strings.dart
│   ├── app_icons.dart
│   └── app_theme.dart
│
├── models/
│   ├── message.dart
│   ├── contact.dart
│   ├── last_message.dart
│   ├── chat_row.dart
│   └── found_profile.dart
│
├── providers/
│   ├── chat_list_provider.dart
│   ├── chat_selection_provider.dart
│   ├── contacts_provider.dart
│   ├── groups_provider.dart
│   ├── profile_provider.dart
│   ├── chat_search_provider.dart
│   ├── composer_provider.dart
│   ├── messages_provider.dart
│   ├── group_chat_provider.dart
│   ├── voice_input_provider.dart
│   ├── account_provider.dart
│   └── add_contact_provider.dart
│
├── services/
│   ├── database_helper.dart
│   ├── message_sync_service.dart
│   ├── group_service.dart
│   ├── task_service.dart
│   ├── status_service.dart
│   ├── push_service.dart
│   ├── fcm_service.dart
│   ├── notification_service.dart
│   └── incoming_message_notifier.dart
│
├── views/
│   └── Application screens and widgets
│
└── main.dart
```

*Note: This is a representative project structure. The actual files and folders may evolve during development.*

### Architecture Responsibilities

| Layer | Responsibility |
|---|---|
| Core | Application strings, icons, colors, and configuration |
| Models | Application data structures |
| Providers | State management and business logic coordination |
| Services | Firebase, SQLite, synchronization, and notifications |
| Views | Application screens and reusable widgets |
| Main | Application initialization and global provider setup |

---

## 🔄 Application Data Flow

Velora uses Provider to connect the user interface with application logic and backend services.

```text
        User Interaction
                |
                v
           Views / UI
                |
                v
             Provider
                |
                v
             Services
             /      \
            v        v
        Firebase   SQLite
            \        /
             v      v
       Data Synchronization
                |
                v
         Provider Update
                |
                v
            UI Refresh
```

---

## 🚀 Getting Started

Follow these instructions to set up and run the application locally.

### Prerequisites

Install the following tools:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Git
- Firebase account

### 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
```

### 2. Navigate to the Project Directory

```bash
cd whatapp_app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Connect the Flutter application to your Firebase project.

The application uses the following Firebase services:

- Firebase Authentication
- Firebase Realtime Database
- Firebase Storage
- Firebase Cloud Messaging

Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Configure Firebase:

```bash
flutterfire configure
```

Ensure the Firebase configuration files are correctly generated and included in the project.

### 5. Run the Application

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

### 6. Analyze the Project

```bash
flutter analyze
```

---

## 📸 Application Screenshots

Explore the Velora mobile application interface.

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/3f661195-7141-4df6-b605-110614bd7ef9" width="220" alt="Screenshot 1"/>
      <br/><b>Application Screen 1</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/c6748c42-d84d-487e-8dda-d1e45dfab75a" width="220" alt="Screenshot 2"/>
      <br/><b>Application Screen 2</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/05d72883-df40-4f93-8f73-f32c9d75f7c3" width="220" alt="Screenshot 3"/>
      <br/><b>Application Screen 3</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/cd5c88aa-048d-4210-b08b-4ca8c8658046" width="220" alt="Screenshot 4"/>
      <br/><b>Application Screen 4</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/a92f858c-5d2e-4c8b-83d0-e90692c67f6f" width="220" alt="Screenshot 5"/>
      <br/><b>Application Screen 5</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/9ff30787-92f8-499e-a915-9595e3e8131b" width="220" alt="Screenshot 6"/>
      <br/><b>Application Screen 6</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/731fa179-e841-498a-8d16-6597d7f3df2e" width="220" alt="Screenshot 7"/>
      <br/><b>Application Screen 7</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/340982cb-c31c-4b55-8910-0c18951794d0" width="220" alt="Screenshot 8"/>
      <br/><b>Application Screen 8</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/2489371c-5587-44f7-8818-f0dd5a44e06a" width="220" alt="Screenshot 9"/>
      <br/><b>Application Screen 9</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/12fc9833-5834-489f-b97a-3a56e4197bdb" width="220" alt="Screenshot 10"/>
      <br/><b>Application Screen 10</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/8fc7b3ce-1c12-49db-82ed-c88760f79a6c" width="220" alt="Screenshot 11"/>
      <br/><b>Application Screen 11</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/1b40d089-a8a1-410f-851a-dd8fcb17e89b" width="220" alt="Screenshot 12"/>
      <br/><b>Application Screen 12</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/3e80942d-31ab-4db3-94af-36d9cea2d46d" width="220" alt="Screenshot 13"/>
      <br/><b>Application Screen 13</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/6d6a48e3-d39f-4349-98ba-e3a8cafdd1ea" width="220" alt="Screenshot 14"/>
      <br/><b>Application Screen 14</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/7a4b2705-a430-4f00-a542-20392229b5e6" width="220" alt="Screenshot 15"/>
      <br/><b>Application Screen 15</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/e5231883-8604-4ea3-a358-061bfbd3f652" width="220" alt="Screenshot 16"/>
      <br/><b>Application Screen 16</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/f2ad5805-ff3b-47b7-bd8e-c6318b7270fc" width="220" alt="Screenshot 17"/>
      <br/><b>Application Screen 17</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/6ab18544-4418-47ce-9de8-3629ef851bcf" width="220" alt="Screenshot 18"/>
      <br/><b>Application Screen 18</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/8dd46503-e984-405f-8172-9e88bc5d1c84" width="220" alt="Screenshot 19"/>
      <br/><b>Application Screen 19</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/eb352314-2d6f-48bd-904e-66dbf4cbcafb" width="220" alt="Screenshot 20"/>
      <br/><b>Application Screen 20</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/d508d445-9603-46a5-bb6d-989f5a8b7b91" width="220" alt="Screenshot 21"/>
      <br/><b>Application Screen 21</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/89b55078-276e-4de2-b006-0e0e041d35f8" width="220" alt="Screenshot 22"/>
      <br/><b>Application Screen 22</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/91e4c6e7-6f05-4166-86b3-66661d233587" width="220" alt="Screenshot 23"/>
      <br/><b>Application Screen 23</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/05e7594a-c707-45c5-ad1d-fbb479bf6ca0" width="220" alt="Screenshot 24"/>
      <br/><b>Application Screen 24</b>
    </td>
  </tr>
</table>

---

## 🔐 Security

- Firebase Authentication for user authentication.
- Firebase security rules to restrict unauthorized access.
- User-specific data access controls.
- Sensitive credentials and configuration files should not be committed to GitHub.
- Validate and authorize database operations.

---

## 🧪 Development Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install project dependencies |
| `flutter run` | Run the application |
| `flutter analyze` | Analyze Dart code |
| `flutter test` | Run automated tests |
| `flutter clean` | Clean build files |
| `flutter build apk` | Build Android APK |
| `flutter doctor` | Check Flutter environment |

---

## 📌 Project Status

**Status: Under Development**

Velora is actively being developed. Application screens, architecture, features, and backend integrations are being improved incrementally.

---

## 🎯 Future Enhancements

- Voice and video calling.
- Message reactions.
- Read receipts and typing indicators.
- Improved media sharing.
- Advanced group management.
- Enhanced offline synchronization.
- Additional security improvements.

---

## 👨‍💻 Project Information

| Detail | Description |
|---|---|
| Project Name | Velora |
| Repository Folder | `whatapp_app` |
| Platform | Flutter / Android |
| Programming Language | Dart |
| Backend | Firebase |
| Local Database | SQLite |
| State Management | Provider |
| Development Environment | Android Studio |

---

## 📄 License

This project is developed for learning and application development purposes.

An appropriate open-source license should be added before public distribution.

---

<p align="center">
  <strong>Velora – Connecting People, One Message at a Time.</strong>
</p>
