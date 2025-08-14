# Farm Flow – Customer/Shop Owner & Government Employee Apps

This repository contains two Flutter applications:

- **`app2/`** → App for **customers** and **plant shop owners**
- **`emplyapp/`** → App for **government Krishibhavan employees** and **main admins**

Both apps work together to create a connected agricultural platform, using **Firebase** for backend services and integrating APIs like **Gemini**, **Geoapify Location**, and **Postimage**.

---

## 🌱 `app2` – Customer & Shop Owner App

### Key Features
- **Firebase Authentication & Database**  
  For secure login, data storage, and real-time updates.
- **Geoapify Location API**  
  Displays maps and shop locations for customers to find nearby plant shops.
- **Postimage API**  
  Used to upload media (images) and get sharable links — helpful for the free-tier Firebase storage limitation.
- **Gemini API**  
  - Plant Disease Cure: Input plant name + disease → get cure & precautions.
  - AI Chatbot: Agriculture assistance powered by Gemini.
- **Marketplace**  
  Customers can view products listed by shop owners.

---

## 🏢 `emplyapp` – Government Employee/Admin App

### Key Features
- **Firebase Backend**  
  Handles employee authentication, data, and notifications.
- **Notification System**  
  Government Krishibhavan employees can send alerts to customers.
- **Admin Panel**  
  Main admin can manage government notifications and oversee employee activity.

---

## 🔗 APIs & Services Used

| API / Service         | Purpose |
|-----------------------|---------|
| **Firebase**          | Authentication, Database, Notifications |
| **Gemini API**        | Plant disease cure & chatbot assistance |
| **Geoapify Location** | Map + location services for shop finding |
| **Postimage**         | Image hosting to bypass free-tier Firebase media limits |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- API keys for:
  - Firebase
  - Gemini API
  - Geoapify Location
  - Postimage (optional but recommended)

### Clone the Repo
```bash
git clone https://github.com/vargheesk/Farm-Flow--both-apps-.git
cd Farm-Flow--both-apps-
