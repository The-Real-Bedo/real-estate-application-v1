# 🏢 Aqarat - Open-Source Multi-Role Real Estate Boilerplate

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/firebase-%23ffca28.svg?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge" alt="PRs Welcome">
</p>

---

## 🌟 Overview

**Aqarat** is a production-ready, highly scalable, and modern open-source real estate framework built using **Flutter** and **Firebase**. Designed specifically for the modern PropTech (Property Technology) ecosystem, this platform bridges the gap between property seekers and landlords by providing a transparent, middleman-free marketplace.

The architecture focuses on solving real-world challenges like market exploitation and decentralized property viewing, making it the perfect starting blueprint for developers looking to deploy robust marketplace applications.

---

## 🎯 Key Business Needs Solved
* **Transparency**: Eliminates hidden broker fees and unfair exploitation.
* **Expat & Student Friendly**: Optimized for tourists, expatriates, and university students seeking temporary or permanent housing.
* **Time Efficiency**: Minimizes physical property viewing friction through cutting-edge visual tours and automated bookings.

---

## 🚀 Core Features & Architecture

This boilerplate utilizes a strict **Role-Based Access Control (RBAC)** architecture natively integrated with Cloud Firestore.

### 👤 User Roles Breakdown

#### 🔍 1. Buyers & Renters (Seekers)
* **Advanced Search Filters**: Dynamic filtering based on price, precise location, surface area, and property type.
* **Interactive Map Integration**: View nearby verified listings using `google_maps_flutter`.
* **Trust & Transparency**: Full access to landlord and property star ratings and written reviews.
* **Appointment Scheduler**: Book face-to-face or virtual viewing appointments directly with property owners.

#### 🏡 2. Property Owners (Landlords / Developers)
* **Dynamic Content Management**: Upload real estate listings complete with descriptions and high-resolution images backed by Firebase Storage.
* **Schedule Control**: View and manage viewing requests from potential tenants or buyers.
* **Listing Controls**: Edit, update, or remove property details instantaneously.

#### 🕵️‍♂️ 3. Invisible System Admins
* Secure, hidden administrative layer with total oversight to flag listings, remove fraudulent actors, and ensure community guidelines are strictly met.

### 💎 The "Creative" Tech Edge
* **360° Virtual Property Tours**: Integrated immersive indoor views using the `panorama` package, allowing buyers to inspect properties virtually before booking.

---

## 🎨 Design System & Visual Identity

The UI/UX is built to deliver stability, luxury, and professional trust.

### Color Palette

| Element | Custom Hex Code | Aesthetic Value |
| :--- | :--- | :--- |
| **Primary Color** | `0xFF1A365D` | Deep Navy Blue — Instills absolute corporate trust & security. |
| **Accent Color** | `0xFFF6AD55` | Soft Warm Amber — Directs eyes to crucial Call-To-Actions (e.g., Bookings). |
| **Background** | `0xFFF7FAFC` | Ultra Light Minimal Gray — Maximizes visual readability. |

### Typography
* **Arabic Layout**: `Cairo` / `Tajawal` — Perfect legibility and geometric structure for contemporary applications.
* **English Layout**: `Poppins` / `Montserrat` — Clean, modern, and perfectly suited for numerical price displays.

---

## 🛠️ Technology Stack

* **Frontend Framework:** Flutter (Dart)
* **Backend Utilities:** Firebase Ecosystem
  * **Authentication:** Multi-factor Email/Phone & Google Sign-In setup.
  * **Database:** Cloud Firestore (Structured Collections for `Users`, `Properties`, and `Appointments`).
  * **Storage:** Firebase Cloud Storage for high-fidelity asset management.
* **State Management:** Highly decoupled and modular (Provider / GetX ready).

---

## 📂 Database Schema (Cloud Firestore)

```text
/Users (Collection)
   ├── uid (Document)
   │     ├── name: "John Doe"
   │     ├── email: "john@example.com"
   │     ├── role: "buyer" | "owner" | "admin"
   │     └── phone: "+201XXXXXXXXX"
   
/Properties (Collection)
   ├── propertyId (Document)
   │     ├── title: "Modern 2-BHK Apartment"
   │     ├── price: 10000
   │     ├── location: GeoPoint(latitude, longitude)
   │     ├── images: ["url1", "url2"]
   │     └── ownerId: "uid_reference"

/Appointments (Collection)
   ├── appointmentId (Document)
   │     ├── propertyId: "propertyId_reference"
   │     ├── buyerId: "uid_reference"
   │     ├── dateTime: Timestamp
   │     └── status: "pending" | "confirmed" | "declined"
