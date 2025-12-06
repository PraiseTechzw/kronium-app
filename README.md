# KRONIUM PRO - Service Booking Platform

A comprehensive Flutter-based service booking application for construction, renewable energy, and agricultural services.

## 🚀 Features

### For Customers
- **User Authentication**: Secure registration and login system
- **Service Browsing**: View available services with detailed information
- **Project Booking**: Easy booking system with project details
- **Project Tracking**: Monitor project progress and status
- **Customer Dashboard**: Personalized dashboard with booking history
- **Profile Management**: Update personal information and preferences
- **Chat Support**: Real-time communication with admin support
- **Dark/Light Mode**: Theme switching capability

### For Administrators
- **Admin Authentication**: Secure admin login system
- **Service Management**: Add, edit, and delete services
- **Booking Management**: View and manage all customer bookings
- **Customer Management**: View customer profiles and information
- **Admin Dashboard**: Analytics and overview of business metrics
- **Chat Support**: Respond to customer inquiries
- **Basic Reporting**: Simple analytics and reporting

## 🛠 Technical Stack

- **Frontend**: Flutter with GetX state management
- **Backend**: Backend services
- **UI Libraries**: 
  - Lottie animations
  - Iconsax icons
  - Shimmer effects
  - Animate_do for animations
- **State Management**: GetX reactive programming
- **Navigation**: GetX routing with custom transitions

## 📱 Available Services

- **Greenhouse Construction** ($3,500)
- **Solar Panel Installation** ($8,500)
- **Construction Services**
- **Engineering Services**
- **Home Repair Services**
- **Electrical Services**
- **Plumbing**
- **Cleaning Services**

## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Backend configuration
- Android Studio / VS Code

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd km
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/                    # Core services and utilities
│   ├── admin_auth_service.dart
│   ├── user_auth_service.dart
│   ├── app_theme.dart
│   ├── constants.dart
│   └── routes.dart
├── models/                  # Data models
│   ├── user_model.dart
│   ├── service_model.dart
│   ├── booking_model.dart
│   ├── project_model.dart
│   └── chat_model.dart
├── pages/                   # UI pages
│   ├── auth/               # Authentication pages
│   ├── admin/              # Admin pages
│   ├── customer/           # Customer pages
│   ├── home/               # Home page
│   ├── services/           # Service-related pages
│   ├── projects/           # Project-related pages
│   ├── profile/            # Profile pages
│   ├── settings/           # Settings pages
│   └── splash/             # Splash screen
└── widgets/                # Reusable widgets
```

## 🔐 Authentication

### Customer Authentication
- Email/password registration and login
- User profile management
- Session persistence
- Password validation

### Admin Authentication
- Secure admin login
- Role-based access control
- Admin session management

## 💬 Chat System

- Real-time messaging between customers and admins
- Chat room management
- Message history
- Read status tracking

## 🎨 UI/UX Features

- Modern Material Design
- Responsive layout
- Smooth animations and transitions
- Dark/Light theme support
- Loading states and error handling
- Form validation

## 📊 Admin Features

- Dashboard with key metrics
- Service management (CRUD operations)
- Booking management with status updates
- Customer information viewing
- Basic analytics and reporting
- Chat support system

## 🔒 Security Features

- Secure Authentication
- Input validation
- Secure data storage
- Role-based access control
- Session management

## 📱 Platform Support

- Android (minimum API 21)
- iOS (iOS 11.0+)
- Web (Flutter Web)
- Desktop (Windows, macOS, Linux)

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📈 Future Enhancements

- Payment gateway integration
- Push notifications
- Advanced analytics
- Multi-language support
- Offline capabilities
- Advanced reporting
- Social media integration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and inquiries:
- Email: support@kroniumpro.com
- Phone: +263 XXX XXX XXX
- Address: Zimbabwe

## 🏢 About KRONIUM PRO

KRONIUM PRO is a leading service provider in Zimbabwe, specializing in:
- Construction services
- Renewable energy solutions
- Agricultural infrastructure
- Engineering services
- Home improvement

Our mission is to provide high-quality, reliable services to our customers while maintaining the highest standards of professionalism and customer satisfaction.
