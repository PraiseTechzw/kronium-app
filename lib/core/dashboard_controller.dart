import 'package:get/get.dart';
import 'package:kronium/core/supabase_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/logger_service.dart';
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/role_manager.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/project_model.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/models/user_model.dart';

/// Enhanced dashboard controller for both admin and customer dashboards
class DashboardController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final UserController _userController = Get.find<UserController>();

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxString lastError = ''.obs;

  // Admin Dashboard Data
  RxInt totalServices = 0.obs;
  RxInt totalBookings = 0.obs;
  RxInt pendingBookings = 0.obs;
  RxInt completedBookings = 0.obs;
  RxInt activeProjects = 0.obs;
  RxInt totalCustomers = 0.obs;
  RxDouble totalRevenue = 0.0.obs;
  RxDouble completionRate = 0.0.obs;
  RxInt activeChatRooms = 0.obs;

  // Recent data
  RxList<Booking> recentBookings = <Booking>[].obs;
  RxList<Project> recentProjects = <Project>[].obs;
  RxList<User> recentCustomers = <User>[].obs;
  RxList<Service> featuredServices = <Service>[].obs;

  // Customer Dashboard Data
  RxList<Project> userProjects = <Project>[].obs;
  RxList<Booking> userBookings = <Booking>[].obs;
  RxInt userActiveProjects = 0.obs;
  RxInt userCompletedProjects = 0.obs;

  // Filters
  RxString projectStatusFilter = 'All'.obs;
  RxString bookingStatusFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    logger.info('DashboardController initialized');
    _initializeDashboard();
  }

  void _initializeDashboard() {
    if (_userController.isAdmin) {
      loadAdminDashboard();
    } else if (_userController.isCustomer) {
      loadCustomerDashboard();
    }
  }

  /// Load admin dashboard data
  Future<void> loadAdminDashboard() async {
    if (!_userController.hasPermission(RoleManager.permissionViewAnalytics)) {
      logger.warning('User does not have permission to view analytics');
      ErrorHandler.showWarningSnackbar(
        'Access denied: Analytics permission required',
      );
      return;
    }

    try {
      isLoading.value = true;
      lastError.value = '';

      logger.info('Loading admin dashboard data');

      // Load all data concurrently
      await Future.wait([
        _loadAdminStatistics(),
        _loadRecentBookings(),
        _loadRecentProjects(),
        _loadRecentCustomers(),
        _loadFeaturedServices(),
      ]);

      logger.info('Admin dashboard data loaded successfully');
    } catch (e) {
      logger.error('Error loading admin dashboard', e);
      lastError.value = 'Failed to load dashboard data';
      ErrorHandler.handleError(e, context: 'Admin dashboard loading');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load customer dashboard data
  Future<void> loadCustomerDashboard() async {
    if (!_userController.hasPermission(RoleManager.permissionViewDashboard)) {
      logger.warning('User does not have permission to view dashboard');
      ErrorHandler.showWarningSnackbar(
        'Access denied: Dashboard permission required',
      );
      return;
    }

    try {
      isLoading.value = true;
      lastError.value = '';

      logger.info('Loading customer dashboard data');

      final userId = _userController.userId.value;
      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      // Load customer-specific data
      await Future.wait([
        _loadUserProjects(userId),
        _loadUserBookings(userId),
        _loadFeaturedServices(),
      ]);

      _calculateUserStatistics();
      logger.info('Customer dashboard data loaded successfully');
    } catch (e) {
      logger.error('Error loading customer dashboard', e);
      lastError.value = 'Failed to load dashboard data';
      ErrorHandler.handleError(e, context: 'Customer dashboard loading');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;

      if (_userController.isAdmin) {
        await loadAdminDashboard();
      } else if (_userController.isCustomer) {
        await loadCustomerDashboard();
      }

      ErrorHandler.showSuccessSnackbar('Dashboard refreshed');
    } catch (e) {
      logger.error('Error refreshing dashboard', e);
      ErrorHandler.handleError(e, context: 'Dashboard refresh');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Load admin statistics
  Future<void> _loadAdminStatistics() async {
    try {
      // Load services count
      final servicesStream = _supabaseService.getServices();
      final services = await servicesStream.first;
      totalServices.value = services.length;

      // Load bookings and calculate statistics
      final bookingsStream = _supabaseService.getBookings();
      final bookings = await bookingsStream.first;
      totalBookings.value = bookings.length;
      pendingBookings.value =
          bookings.where((b) => b.status == BookingStatus.pending).length;
      completedBookings.value =
          bookings.where((b) => b.status == BookingStatus.completed).length;

      // Calculate total revenue
      totalRevenue.value = bookings
          .where((b) => b.status == BookingStatus.completed)
          .fold(0.0, (sum, booking) => sum + booking.price);

      // Calculate completion rate
      if (totalBookings.value > 0) {
        completionRate.value =
            (completedBookings.value / totalBookings.value) * 100;
      }

      // Load projects count
      final projectsStream = _supabaseService.getProjects();
      final projects = await projectsStream.first;
      activeProjects.value =
          projects.where((p) => p.status != ProjectStatus.completed).length;

      // Load customers count
      final usersStream = _supabaseService.getUsers();
      final users = await usersStream.first;
      totalCustomers.value = users.where((u) => u.role == 'customer').length;

      // Load active chat rooms (placeholder - implement when chat is ready)
      activeChatRooms.value = 0; // TODO: Implement chat rooms count

      logger.debug(
        'Admin statistics loaded: Services: ${totalServices.value}, Bookings: ${totalBookings.value}',
      );
    } catch (e) {
      logger.error('Error loading admin statistics', e);
      rethrow;
    }
  }

  /// Load recent bookings
  Future<void> _loadRecentBookings() async {
    try {
      final bookingsStream = _supabaseService.getBookings();
      final bookings = await bookingsStream.first;
      // Sort by creation date and take the 5 most recent
      bookings.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      recentBookings.value = bookings.take(5).toList();

      logger.debug('Loaded ${recentBookings.length} recent bookings');
    } catch (e) {
      logger.error('Error loading recent bookings', e);
      rethrow;
    }
  }

  /// Load recent projects
  Future<void> _loadRecentProjects() async {
    try {
      final projectsStream = _supabaseService.getProjects();
      final projects = await projectsStream.first;
      // Sort by creation date and take the 5 most recent
      projects.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      recentProjects.value = projects.take(5).toList();

      logger.debug('Loaded ${recentProjects.length} recent projects');
    } catch (e) {
      logger.error('Error loading recent projects', e);
      rethrow;
    }
  }

  /// Load recent customers
  Future<void> _loadRecentCustomers() async {
    try {
      final usersStream = _supabaseService.getUsers();
      final users = await usersStream.first;
      final customers = users.where((u) => u.role == 'customer').toList();
      // Sort by creation date and take the 5 most recent
      customers.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      recentCustomers.value = customers.take(5).toList();

      logger.debug('Loaded ${recentCustomers.length} recent customers');
    } catch (e) {
      logger.error('Error loading recent customers', e);
      rethrow;
    }
  }

  /// Load featured services
  Future<void> _loadFeaturedServices() async {
    try {
      final servicesStream = _supabaseService.getServices();
      final services = await servicesStream.first;
      // Take active services, sort by some criteria (e.g., price or creation date)
      final activeServices = services.where((s) => s.isActive).toList();
      activeServices.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      featuredServices.value = activeServices.take(6).toList();

      logger.debug('Loaded ${featuredServices.length} featured services');
    } catch (e) {
      logger.error('Error loading featured services', e);
      rethrow;
    }
  }

  /// Load user projects
  Future<void> _loadUserProjects(String userId) async {
    try {
      // Use the existing getProjects method and filter by user
      final projectsStream = _supabaseService.getProjects();
      final allProjects = await projectsStream.first;
      final userProjectsList =
          allProjects
              .where((p) => p.clientEmail == _userController.userEmail.value)
              .toList();
      userProjects.value = userProjectsList;

      logger.debug('Loaded ${userProjects.length} user projects');
    } catch (e) {
      logger.error('Error loading user projects', e);
      rethrow;
    }
  }

  /// Load user bookings
  Future<void> _loadUserBookings(String userId) async {
    try {
      // Use the existing getBookings method and filter by user
      final bookingsStream = _supabaseService.getBookings();
      final allBookings = await bookingsStream.first;
      final userBookingsList =
          allBookings
              .where((b) => b.clientEmail == _userController.userEmail.value)
              .toList();
      userBookings.value = userBookingsList;

      logger.debug('Loaded ${userBookings.length} user bookings');
    } catch (e) {
      logger.error('Error loading user bookings', e);
      rethrow;
    }
  }

  /// Calculate user statistics
  void _calculateUserStatistics() {
    userActiveProjects.value =
        userProjects.where((p) => p.status != ProjectStatus.completed).length;
    userCompletedProjects.value =
        userProjects.where((p) => p.status == ProjectStatus.completed).length;
  }

  /// Filter projects by status
  void filterProjectsByStatus(String status) {
    projectStatusFilter.value = status;
    logger.debug('Projects filtered by status: $status');
  }

  /// Filter bookings by status
  void filterBookingsByStatus(String status) {
    bookingStatusFilter.value = status;
    logger.debug('Bookings filtered by status: $status');
  }

  /// Get filtered projects
  List<Project> get filteredProjects {
    if (projectStatusFilter.value == 'All') {
      return userProjects;
    }

    // Convert string filter to enum
    ProjectStatus? filterStatus;
    switch (projectStatusFilter.value.toLowerCase()) {
      case 'planning':
        filterStatus = ProjectStatus.planning;
        break;
      case 'inprogress':
      case 'in progress':
        filterStatus = ProjectStatus.inProgress;
        break;
      case 'onhold':
      case 'on hold':
        filterStatus = ProjectStatus.onHold;
        break;
      case 'completed':
        filterStatus = ProjectStatus.completed;
        break;
      case 'cancelled':
        filterStatus = ProjectStatus.cancelled;
        break;
    }

    if (filterStatus == null) {
      return userProjects;
    }

    return userProjects.where((p) => p.status == filterStatus).toList();
  }

  /// Get filtered bookings
  List<Booking> get filteredBookings {
    if (bookingStatusFilter.value == 'All') {
      return userBookings;
    }

    // Convert string filter to enum
    BookingStatus? filterStatus;
    switch (bookingStatusFilter.value.toLowerCase()) {
      case 'pending':
        filterStatus = BookingStatus.pending;
        break;
      case 'confirmed':
        filterStatus = BookingStatus.confirmed;
        break;
      case 'inprogress':
      case 'in progress':
        filterStatus = BookingStatus.inProgress;
        break;
      case 'completed':
        filterStatus = BookingStatus.completed;
        break;
      case 'cancelled':
        filterStatus = BookingStatus.cancelled;
        break;
    }

    if (filterStatus == null) {
      return userBookings;
    }

    return userBookings.where((b) => b.status == filterStatus).toList();
  }

  /// Get dashboard summary for admin
  Map<String, dynamic> get adminSummary => {
    'totalServices': totalServices.value,
    'totalBookings': totalBookings.value,
    'pendingBookings': pendingBookings.value,
    'completedBookings': completedBookings.value,
    'activeProjects': activeProjects.value,
    'totalCustomers': totalCustomers.value,
    'totalRevenue': totalRevenue.value,
    'completionRate': completionRate.value,
    'activeChatRooms': activeChatRooms.value,
  };

  /// Get dashboard summary for customer
  Map<String, dynamic> get customerSummary => {
    'totalProjects': userProjects.length,
    'activeProjects': userActiveProjects.value,
    'completedProjects': userCompletedProjects.value,
    'totalBookings': userBookings.length,
  };

  /// Check if dashboard has data
  bool get hasData {
    if (_userController.isAdmin) {
      return totalServices.value > 0 ||
          totalBookings.value > 0 ||
          totalCustomers.value > 0;
    } else {
      return userProjects.isNotEmpty ||
          userBookings.isNotEmpty ||
          featuredServices.isNotEmpty;
    }
  }

  /// Get status color for projects/bookings
  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'confirmed':
      case 'in_progress':
      case 'inprogress':
        return '#2196F3'; // Blue
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get status display name
  String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.capitalize ?? status;
    }
  }

  @override
  void onClose() {
    logger.info('DashboardController disposed');
    super.onClose();
  }
}
