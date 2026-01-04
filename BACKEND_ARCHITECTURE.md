# 🏗️ Kronium Pro - Backend Architecture

## 📋 Overview

The Kronium Pro backend is built with a modern, scalable architecture using **Supabase** as the primary backend-as-a-service (BaaS) platform, complemented by custom services for enhanced functionality.

## 🏛️ Architecture Layers

### 1. **Data Layer**
- **Supabase Database**: PostgreSQL with real-time subscriptions
- **Supabase Storage**: File storage with public/private buckets
- **Supabase Auth**: Authentication and user management

### 2. **Service Layer**
- **SupabaseService**: Database operations and real-time streams
- **ApiService**: External API integrations and HTTP requests
- **CacheService**: In-memory and persistent caching
- **NotificationService**: Multi-channel notifications (email, SMS, push, in-app)

### 3. **Repository Layer**
- **Repository Pattern**: Abstracted data access layer
- **UserRepository**: User data management
- **ServiceRepository**: Service catalog management
- **BookingRepository**: Booking lifecycle management
- **ProjectRepository**: Project tracking and updates

### 4. **Business Logic Layer**
- **DashboardController**: Analytics and dashboard data
- **UserController**: User state management
- **RoleManager**: Role-based access control (RBAC)

### 5. **Security Layer**
- **SecurityService**: Input validation, XSS prevention, rate limiting
- **ErrorHandler**: Centralized error handling and user feedback
- **ValidationService**: Data validation and sanitization

## 🗄️ Database Schema

### **Core Tables**

#### **users**
```sql
- id: UUID (Primary Key, Supabase Auth ID)
- simpleId: VARCHAR(8) (Sequential ID: AAA00001, AAA00002...)
- name: VARCHAR(255)
- email: VARCHAR(255) UNIQUE
- phone: VARCHAR(50)
- profileImage: TEXT
- address: TEXT
- role: VARCHAR(20) DEFAULT 'customer'
- isActive: BOOLEAN DEFAULT true
- favoriteServices: JSONB DEFAULT '[]'
- createdAt: TIMESTAMP DEFAULT NOW()
- updatedAt: TIMESTAMP DEFAULT NOW()
```

#### **services**
```sql
- id: UUID (Primary Key)
- title: VARCHAR(255)
- description: TEXT
- category: VARCHAR(100)
- price: DECIMAL(10,2)
- duration: INTEGER (minutes)
- imageUrl: TEXT
- videoUrl: TEXT
- isActive: BOOLEAN DEFAULT true
- createdAt: TIMESTAMP DEFAULT NOW()
- updatedAt: TIMESTAMP DEFAULT NOW()
```

#### **bookings**
```sql
- id: UUID (Primary Key)
- serviceName: VARCHAR(255)
- clientName: VARCHAR(255)
- clientEmail: VARCHAR(255)
- clientPhone: VARCHAR(50)
- date: TIMESTAMP
- status: VARCHAR(20) DEFAULT 'pending'
- price: DECIMAL(10,2)
- location: TEXT
- notes: TEXT
- createdAt: TIMESTAMP DEFAULT NOW()
- updatedAt: TIMESTAMP DEFAULT NOW()
```

#### **projects**
```sql
- id: UUID (Primary Key)
- title: VARCHAR(255)
- description: TEXT
- clientName: VARCHAR(255)
- clientEmail: VARCHAR(255)
- clientPhone: VARCHAR(50)
- status: VARCHAR(20) DEFAULT 'active'
- progress: DECIMAL(5,2) DEFAULT 0
- location: TEXT
- mediaUrls: JSONB DEFAULT '[]'
- updates: JSONB DEFAULT '[]'
- createdAt: TIMESTAMP DEFAULT NOW()
- updatedAt: TIMESTAMP DEFAULT NOW()
```

#### **chat_rooms**
```sql
- id: UUID (Primary Key)
- customerId: UUID (Foreign Key)
- customerName: VARCHAR(255)
- customerEmail: VARCHAR(255)
- lastMessageAt: TIMESTAMP
- createdAt: TIMESTAMP DEFAULT NOW()
```

#### **chat_messages**
```sql
- id: UUID (Primary Key)
- chatRoomId: UUID (Foreign Key)
- senderId: UUID
- senderName: VARCHAR(255)
- senderType: VARCHAR(20) ('customer' | 'admin')
- message: TEXT
- timestamp: TIMESTAMP DEFAULT NOW()
- read: BOOLEAN DEFAULT false
```

## 🔧 Service Architecture

### **SupabaseService**
**Purpose**: Primary database interface with enhanced error handling and logging

**Key Features**:
- Real-time data streams
- Input sanitization and validation
- Comprehensive error handling
- Connection health monitoring
- File upload security

**Methods**:
```dart
// Users
Stream<List<User>> getUsers()
Future<User?> getUserById(String id)
Future<void> addUser(User user)
Future<void> updateUser(String id, Map<String, dynamic> data)

// Services
Stream<List<Service>> getServices()
Future<void> addService(Service service)
Future<void> updateService(String id, Map<String, dynamic> data)

// Bookings
Stream<List<Booking>> getBookings()
Future<void> addBooking(Booking booking)
Future<void> updateBookingStatus(String id, String status)

// Projects
Stream<List<Project>> getProjects()
Future<void> addProject(Project project)
Future<void> updateProjectProgress(String id, double progress)

// File Storage
Future<String> uploadImage(File file, String folder)
Future<String> uploadVideo(File file, String folder)
```

### **ApiService**
**Purpose**: External API integrations and HTTP client

**Key Features**:
- RESTful API client with timeout handling
- Request/response logging
- Rate limiting
- Input sanitization
- Error handling with user-friendly messages

**Methods**:
```dart
Future<Map<String, dynamic>> get(String endpoint)
Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body})
Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body})
Future<Map<String, dynamic>> delete(String endpoint)

// Specialized endpoints
Future<Map<String, dynamic>> sendPushNotification({...})
Future<Map<String, dynamic>> sendEmailNotification({...})
Future<Map<String, dynamic>> processPayment({...})
```

### **CacheService**
**Purpose**: High-performance caching with TTL and memory management

**Key Features**:
- In-memory and persistent storage
- TTL (Time To Live) support
- Memory usage optimization
- Critical item prioritization
- Automatic cleanup

**Methods**:
```dart
Future<void> set(String key, dynamic value, {Duration? ttl, bool persistent = false})
Future<T?> get<T>(String key)
Future<void> remove(String key)
Future<void> clear({bool persistent = true})

// Convenience methods
Future<void> cacheUserProfile(Map<String, dynamic> profile)
Future<void> cacheServices(List<Map<String, dynamic>> services)
Future<void> cacheDashboardStats(Map<String, dynamic> stats)
```

### **NotificationService**
**Purpose**: Multi-channel notification system

**Key Features**:
- Email, SMS, push, and in-app notifications
- Template support
- Bulk notifications
- Handler pattern for extensibility
- Delivery tracking

**Methods**:
```dart
Future<NotificationResult> sendNotification(AppNotification notification)
Future<List<NotificationResult>> sendBulkNotifications(List<AppNotification> notifications)

// Convenience methods
Future<NotificationResult> sendWelcomeNotification(String userId, String userName, String email)
Future<NotificationResult> sendBookingConfirmation({...})
Future<NotificationResult> sendProjectUpdate({...})
```

### **RepositoryService**
**Purpose**: Repository pattern implementation for clean data access

**Key Features**:
- Abstracted data access layer
- Consistent CRUD operations
- Error handling and logging
- Type-safe operations

**Repositories**:
- `UserRepository`: User management
- `ServiceRepository`: Service catalog
- `BookingRepository`: Booking lifecycle
- `ProjectRepository`: Project tracking

**Interface**:
```dart
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> create(T item);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Stream<List<T>> watch();
}
```

## 🔒 Security Architecture

### **Input Validation & Sanitization**
- XSS prevention through input sanitization
- SQL injection detection and prevention
- File upload security validation
- Email and phone number validation

### **Rate Limiting**
- API endpoint rate limiting
- Chat message rate limiting
- File upload rate limiting
- Configurable limits per endpoint

### **Authentication & Authorization**
- Supabase Auth integration
- Role-based access control (RBAC)
- Session management
- Permission-based feature access

### **Data Protection**
- Input sanitization on all user inputs
- Secure file upload validation
- CSRF token generation and validation
- Encrypted sensitive data storage

## 📊 Real-time Features

### **Database Subscriptions**
- Real-time user updates
- Live service catalog changes
- Booking status updates
- Project progress tracking
- Chat message delivery

### **Stream Management**
- Automatic reconnection on failures
- Error handling in streams
- Memory-efficient stream handling
- Subscription cleanup

## 🚀 Performance Optimizations

### **Caching Strategy**
- Multi-level caching (memory + persistent)
- TTL-based cache invalidation
- Critical data prioritization
- Automatic memory management

### **Database Optimization**
- Indexed columns for fast queries
- Pagination for large datasets
- Efficient query patterns
- Connection pooling

### **File Storage**
- Optimized file upload process
- Image compression and resizing
- CDN integration for fast delivery
- Secure file access controls

## 📈 Monitoring & Analytics

### **Logging**
- Structured logging with levels
- Error tracking and reporting
- Performance monitoring
- User activity logging

### **Health Checks**
- Database connection monitoring
- API endpoint health checks
- Service availability monitoring
- Performance metrics collection

### **Analytics**
- User engagement tracking
- Feature usage analytics
- Performance metrics
- Business intelligence data

## 🔧 Configuration Management

### **Environment Configuration**
```dart
class ConfigService {
  static const bool isProduction = kReleaseMode;
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // Feature flags
  static const bool enableOfflineMode = false;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;
}
```

### **Security Configuration**
- Session timeout settings
- Rate limiting configuration
- File upload restrictions
- API security settings

## 🚀 Deployment Architecture

### **Production Setup**
1. **Supabase Project**: Production database and storage
2. **Environment Variables**: Secure configuration management
3. **CDN**: Fast content delivery
4. **Monitoring**: Error tracking and performance monitoring

### **Scaling Considerations**
- Database connection pooling
- Horizontal scaling support
- Load balancing for API endpoints
- Caching layer optimization

## 📋 API Endpoints

### **Authentication**
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Token refresh

### **Users**
- `GET /users` - List users (admin only)
- `GET /users/:id` - Get user by ID
- `PUT /users/:id` - Update user
- `DELETE /users/:id` - Delete user (admin only)

### **Services**
- `GET /services` - List services
- `POST /services` - Create service (admin only)
- `PUT /services/:id` - Update service (admin only)
- `DELETE /services/:id` - Delete service (admin only)

### **Bookings**
- `GET /bookings` - List bookings
- `POST /bookings` - Create booking
- `PUT /bookings/:id` - Update booking
- `DELETE /bookings/:id` - Cancel booking

### **Projects**
- `GET /projects` - List projects
- `POST /projects` - Create project
- `PUT /projects/:id` - Update project
- `PUT /projects/:id/progress` - Update progress

## 🔄 Data Flow

### **User Registration Flow**
1. User submits registration form
2. Input validation and sanitization
3. Supabase Auth user creation
4. User profile creation in database
5. Welcome notification sent
6. User session established

### **Booking Flow**
1. User selects service and date
2. Booking validation and creation
3. Real-time booking status updates
4. Email confirmation sent
5. Admin notification triggered
6. Project creation (if applicable)

### **Real-time Updates Flow**
1. Database change occurs
2. Supabase real-time trigger
3. Stream update propagated
4. UI automatically updates
5. User sees live changes

## 🛠️ Development Guidelines

### **Code Organization**
```
lib/core/
├── supabase_service.dart      # Database operations
├── api_service.dart           # External API client
├── cache_service.dart         # Caching layer
├── notification_service.dart  # Notifications
├── repository_service.dart    # Data repositories
├── security_service.dart      # Security utilities
├── logger_service.dart        # Logging system
└── error_handler.dart         # Error management
```

### **Best Practices**
- Always use the repository pattern for data access
- Implement proper error handling and logging
- Validate and sanitize all user inputs
- Use caching for frequently accessed data
- Follow the single responsibility principle
- Write comprehensive tests for all services

### **Error Handling**
- Use structured error handling with context
- Provide user-friendly error messages
- Log all errors with appropriate levels
- Implement retry mechanisms for transient failures

---

## 🎯 **Backend Summary**

The Kronium Pro backend provides:

✅ **Scalable Architecture** with modern patterns and practices  
✅ **Real-time Features** with Supabase subscriptions  
✅ **Comprehensive Security** with input validation and RBAC  
✅ **High Performance** with multi-level caching  
✅ **Production Ready** with monitoring and error handling  
✅ **Extensible Design** with repository and service patterns  

**Your backend is now enterprise-grade and ready for production deployment! 🚀**