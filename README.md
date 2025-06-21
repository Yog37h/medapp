# 🏥 Ezmed - All-in-One Digital Health Management System

> A comprehensive Flutter-based mobile application to simplify and centralize your personal healthcare — from health monitoring to booking doctor appointments, buying medicines, and managing medical records.

![Platform](https://img.shields.io/badge/Built%20With-Flutter-blue.svg)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 📖 Overview

**Ezmed** is a unified digital health management system designed to streamline personal healthcare. It allows users to:

- Track vital health parameters (glucose, heart rate, calorie intake)
- Schedule doctor and lab appointments
- Set medication reminders
- Store medical records securely
- Purchase medicines and health equipment online
- Get personalized health insights powered by AI

This app bridges the gap between users and modern healthcare by bringing everything into a single, intuitive platform.

---

## 🚀 Features

- 🩺 **Vitals Tracking:** Monitor glucose, heart rate & calorie intake daily  
- ⏰ **Medication Reminders:** Get notified to take your medicines on time  
- 🧾 **Medical Records:** Secure storage and access to prescriptions & reports  
- 👨‍⚕️ **Doctor/Lab Appointments:** Seamless booking with time slot selection  
- 🛒 **E-Commerce Integration:** Purchase medical supplies through in-app store  
- 🧠 **AI Health Chatbot:** Powered by OpenAI for health-related Q&A  
- 📍 **Location Services:** Integrated Google Maps for nearby hospitals/labs  
- 📷 **Media Uploads:** Upload medical scans to Supabase Buckets  
- 🔔 **Realtime Notifications:** Using Twilio for alerts and confirmations  

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile app development |
| **Firebase Firestore** | User data, vitals, and real-time updates |
| **Supabase Buckets** | Medical reports and file uploads |
| **Twilio** | SMS/Call notifications and alerts |
| **Google Maps API** | Location-based hospital and lab discovery |
| **OpenAI API** | AI-powered health assistant/chatbot |
| **Maven** | Dependency management for backend integrations (if applicable) |

---

## 📦 Installation

### Prerequisites

- Flutter SDK ≥ 3.0
- Dart ≥ 2.18
- Android Studio / Xcode for emulator
- Firebase Project setup
- Supabase account & bucket
- Twilio account with verified phone number

### Steps

```bash
git clone https://github.com/Yog37h/medapp.git
cd medapp
flutter pub get
flutter run
