# Kronium Admin Dashboard

A comprehensive Next.js admin dashboard for managing the Kronium agricultural and construction services platform.

## 🚀 Features

### Dashboard Overview
- **Real-time Analytics**: Track users, services, bookings, and revenue
- **Quick Actions**: Fast access to common administrative tasks
- **Recent Activity**: Monitor latest bookings and user registrations
- **Performance Metrics**: Growth indicators and trend analysis

### User Management
- **User Listing**: View all users with search and filtering
- **User Creation**: Add new users with role assignment
- **Role Management**: Assign roles (Customer, Admin, Manager, Technician)
- **Status Control**: Activate/deactivate user accounts
- **Profile Management**: Edit user information and settings

### Service Management
- **Service Catalog**: Manage all available services
- **Service Creation**: Add new services with detailed information
- **Category Organization**: Organize services by categories
- **Pricing Management**: Set and update service pricing
- **Feature Management**: Define service features and specifications
- **Status Control**: Enable/disable services

### Booking Management
- **Booking Overview**: View all customer bookings
- **Status Updates**: Change booking status (Pending, Confirmed, Completed, Cancelled)
- **Customer Information**: Access customer details for each booking
- **Service Details**: View booked service information
- **Timeline Tracking**: Monitor booking dates and progress

### Project Management
- **Project Tracking**: Monitor all customer projects
- **Status Management**: Update project status and progress
- **Client Communication**: View project details and client information
- **Timeline Management**: Track project start and end dates
- **Budget Monitoring**: Monitor project budgets and costs

### Analytics & Reporting
- **Performance Dashboard**: Comprehensive business analytics
- **Revenue Tracking**: Monitor income and financial performance
- **User Growth**: Track user acquisition and engagement
- **Service Performance**: Analyze most popular services
- **Booking Trends**: Monitor booking patterns and seasonality
- **Category Analysis**: Service category performance metrics

### Customer Support Chat
- **Live Chat Interface**: Real-time customer support
- **Chat Sessions**: Manage multiple customer conversations
- **Message History**: Access conversation history
- **Customer Context**: View customer information during chats
- **Response Management**: Send and receive messages efficiently

## 🛠️ Technology Stack

- **Framework**: Next.js 14 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Icons**: Heroicons
- **State Management**: React Hooks + Context
- **Real-time**: Supabase Realtime subscriptions

## 📦 Installation & Setup

### Prerequisites
- Node.js 18+ 
- npm or yarn
- Supabase account and project

### 1. Clone and Install
```bash
cd admin
npm install
```

### 2. Environment Configuration
Create `.env.local` file:
```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# App Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_nextauth_secret
```

### 3. Database Setup
Ensure your Supabase database has the following tables:
- `users` - User profiles and authentication
- `services` - Service catalog
- `bookings` - Customer bookings
- `projects` - Customer projects
- `chat_rooms` - Chat sessions (optional)
- `chat_messages` - Chat messages (optional)

### 4. Run Development Server
```bash
npm run dev
```

The dashboard will be available at `http://localhost:3000`

## 🔐 Authentication & Security

### Admin Access
- Only users with `admin` role can access the dashboard
- Authentication handled through Supabase Auth
- Role-based access control (RBAC)
- Secure session management

### Security Features
- Input sanitization and validation
- XSS protection
- SQL injection prevention
- Secure API endpoints
- Environment variable protection

## 📱 Responsive Design

The dashboard is fully responsive and works on:
- **Desktop**: Full feature set with sidebar navigation
- **Tablet**: Optimized layout with collapsible sidebar
- **Mobile**: Mobile-first design with hamburger menu

## 🎨 UI/UX Features

### Design System
- **Consistent Colors**: Primary blue theme with semantic colors
- **Typography**: Clean, readable font hierarchy
- **Spacing**: Consistent spacing system
- **Components**: Reusable UI components
- **Accessibility**: WCAG compliant design

### Interactive Elements
- **Loading States**: Smooth loading indicators
- **Error Handling**: User-friendly error messages
- **Success Feedback**: Clear success confirmations
- **Modal Dialogs**: Contextual information display
- **Form Validation**: Real-time form validation

## 📊 Analytics & Metrics

### Key Performance Indicators (KPIs)
- Total Users
- Active Services
- Total Bookings
- Revenue Generated
- Growth Percentages
- Popular Service Categories

### Reporting Features
- **Time Range Selection**: 7 days, 30 days, 90 days, 1 year
- **Trend Analysis**: Visual charts and graphs
- **Export Capabilities**: Data export functionality
- **Real-time Updates**: Live data synchronization

## 🔧 Development

### Project Structure
```
admin/
├── app/                    # Next.js App Router
│   ├── dashboard/         # Dashboard pages
│   │   ├── users/        # User management
│   │   ├── services/     # Service management
│   │   ├── bookings/     # Booking management
│   │   ├── projects/     # Project management
│   │   ├── analytics/    # Analytics dashboard
│   │   └── chat/         # Customer support chat
│   ├── login/            # Authentication
│   ├── layout.tsx        # Root layout
│   └── providers.tsx     # Context providers
├── components/           # Reusable components
├── lib/                 # Utilities and configurations
├── public/              # Static assets
└── styles/              # Global styles
```

### Code Quality
- **TypeScript**: Full type safety
- **ESLint**: Code linting and formatting
- **Prettier**: Code formatting
- **Husky**: Git hooks for quality checks

### Performance Optimization
- **Code Splitting**: Automatic route-based splitting
- **Image Optimization**: Next.js Image component
- **Caching**: Efficient data caching strategies
- **Bundle Analysis**: Webpack bundle analyzer

## 🚀 Deployment

### Production Build
```bash
npm run build
npm start
```

### Environment Variables
Ensure all production environment variables are set:
- Supabase production URLs and keys
- Secure NEXTAUTH_SECRET
- Production domain for NEXTAUTH_URL

### Deployment Platforms
- **Vercel**: Recommended (seamless Next.js integration)
- **Netlify**: Alternative deployment option
- **Docker**: Containerized deployment
- **Traditional Hosting**: Node.js hosting providers

## 🔄 Integration with Flutter App

The admin dashboard is fully integrated with the Kronium Flutter mobile app:

### Shared Database
- Same Supabase database and tables
- Real-time synchronization
- Consistent data models

### User Management
- Admin can manage Flutter app users
- Role assignments affect app permissions
- Profile updates sync across platforms

### Service Management
- Services created in admin appear in Flutter app
- Pricing and availability managed centrally
- Category organization shared

### Booking Management
- Bookings from Flutter app appear in admin
- Status updates sync in real-time
- Customer communication through both platforms

## 📞 Support & Maintenance

### Monitoring
- Error tracking and logging
- Performance monitoring
- User activity analytics
- System health checks

### Updates
- Regular security updates
- Feature enhancements
- Bug fixes and improvements
- Database migrations

### Backup & Recovery
- Automated database backups
- Data export capabilities
- Disaster recovery procedures
- Version control for code

## 🤝 Contributing

### Development Workflow
1. Create feature branch
2. Implement changes with tests
3. Submit pull request
4. Code review process
5. Merge to main branch

### Coding Standards
- Follow TypeScript best practices
- Use consistent naming conventions
- Write comprehensive comments
- Implement proper error handling

## 📄 License

This project is proprietary software for Kronium platform.

## 📞 Contact

For technical support or questions about the admin dashboard, please contact the development team.

---

**Kronium Admin Dashboard** - Empowering efficient business management for agricultural and construction services.