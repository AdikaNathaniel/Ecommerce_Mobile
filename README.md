# 📱 Digizone - Multi-Vendor Mobile Platform

Welcome to **Digizone**, a mobile-based multi-vendor platform developed using **Flutter**. This app allows  **Sellers** to add,remove and edit products,**Users** to search,add products to cart and place orders, and receive notifications for key activities as well as enabling **Administrators** track activity on DigiZone. The platform integrates with existing backend microservices for authentication, product management, order processing, and notifications.

---

## 🚀 **Project Objectives**
1. Develop a mobile app replicating the existing web platform's functionality.
2. Ensure seamless integration with backend microservices.
3. Build a responsive and user-friendly app using **Flutter**.
4. Enhance the platform with delivery and payment services for a complete shopping experience.

---

## 🛠 **Technical Stack**

### **Frontend:**
- **Flutter:** Cross-platform mobile development.
### **Backend:**
- **NestJs:** Powerful framework for building scalable backend microservices.
### **Database:**
- **MongoDB:** NoSQL database for flexible data storage.
 

### **Backend Microservices:**
- **Authentication Service:** User registration, login, and OTP verification using RabbitMQ for communication between email and notification microservices.
- **Product Service:** Product management including search and filters.
- **Order and Cart Service:** Order placement, tracking, and cart functionality.
- **Notification Service:** Push notifications from the backend to the frontend.
- **Payment and Delivery Services:** Enhance the user experience with seamless transactions using Stripe Payment Platform and real-time order deliveries tracking using Google Maps.

### **Other Tools:**
- **Git & GitHub:** Version control and repository management.
- **Postman:** API testing and verification.
- **RabbitMQ:** Message broker for microservices communication specifically between the email microservice and notification microservice.

---

## 📲 **Key Features**

- **Authentication:**
  - User registration with OTP verification when a user registers on DigiZone.
  - Token-based session management.
  - Secure login and logout.

- **Products:**
  - Browse and search through a variety of products.
  - View detailed product information with high-quality images.

- **Orders:**
  - Add products to the cart and place orders.
  - Real-time order tracking and status updates.

- **Notifications:**
  - Push notifications for order status, promotions, and updates.
  - Fetched from the backend.

- **Payment & Delivery:**
  - Secure payment gateway integration Using **Stripe**.
  - Delivery tracking using **Google Maps** and status updates.

---

## 💻 **Setup Instructions**

1. **Clone the Repository:**
```bash
git clone https://github.com/AdikaNathaniel/Ecommerce_Mobile
cd digizone
```

2. **Install Dependencies:**
```bash
flutter pub get
```

3. **Run the App:**
```bash
flutter run
```

4. **Test API Endpoints:**
- Use **Postman** to verify backend microservices are running correctly.

---

## 📧 **Contact**
For any inquiries or support, please contact **Nathaniel Adika** at [nathanieladikajnr@gmail.com](mailto:nathanieladikajnr@gmail.com).

---

## 🤝 **Contributing**

1. **Fork the Repository**
2. **Create a Feature Branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit Your Changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the Branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

---

### 🌐 **Follow Me**
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Nathaniel%20Adika-blue?logo=linkedin)](https://www.linkedin.com/in/nathaniel-adika-20a30226a)
[![GitHub](https://img.shields.io/badge/GitHub-AdikaNathaniel-black?logo=github)](https://github.com/AdikaNathaniel)

---

Thank you for checking out **Digizone**! Happy coding! 🎉
