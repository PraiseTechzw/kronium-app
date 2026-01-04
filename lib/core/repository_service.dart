import 'dart:async';
import 'package:kronium/core/supabase_service.dart';
import 'package:kronium/core/logger_service.dart' as logging;
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/models/user_model.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/project_model.dart';

/// Repository pattern implementation for data management
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> create(T item);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Stream<List<T>> watch();
}

/// User repository implementation
class UserRepository implements Repository<User> {
  final SupabaseService _supabaseService = SupabaseService.instance;

  @override
  Future<List<User>> getAll() async {
    try {
      logging.logger.debug('UserRepository: Fetching all users');
      final stream = _supabaseService.getUsers();
      return await stream.first;
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error fetching all users',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.getAll');
      rethrow;
    }
  }

  @override
  Future<User?> getById(String id) async {
    try {
      logging.logger.debug('UserRepository: Fetching user by ID: $id');
      return await _supabaseService.getUserById(id);
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error fetching user by ID: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.getById');
      return null;
    }
  }

  @override
  Future<void> create(User item) async {
    try {
      logging.logger.info('UserRepository: Creating user: ${item.name}');
      await _supabaseService.addUser(item);
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error creating user: ${item.name}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.create');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      logging.logger.info('UserRepository: Updating user: $id');
      await _supabaseService.updateUser(id, data);
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error updating user: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.update');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      logging.logger.warning('UserRepository: Deleting user: $id');
      await _supabaseService.deleteUser(id);
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error deleting user: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.delete');
      rethrow;
    }
  }

  @override
  Stream<List<User>> watch() {
    try {
      logging.logger.debug('UserRepository: Setting up users watch stream');
      return _supabaseService.getUsers();
    } catch (e) {
      logging.logger.error('UserRepository: Error setting up watch stream', e);
      ErrorHandler.handleError(e, context: 'UserRepository.watch');
      rethrow;
    }
  }

  /// Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      logging.logger.debug('UserRepository: Fetching users by role: $role');
      final allUsers = await getAll();
      return allUsers.where((user) => user.role == role).toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error fetching users by role: $role',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.getUsersByRole');
      rethrow;
    }
  }

  /// Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    try {
      logging.logger.debug(
        'UserRepository: Searching users with query: $query',
      );
      final allUsers = await getAll();
      final lowercaseQuery = query.toLowerCase();

      return allUsers.where((user) {
        return user.name.toLowerCase().contains(lowercaseQuery) ||
            user.email.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'UserRepository: Error searching users with query: $query',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'UserRepository.searchUsers');
      rethrow;
    }
  }
}

/// Service repository implementation
class ServiceRepository implements Repository<Service> {
  final SupabaseService _supabaseService = SupabaseService.instance;

  @override
  Future<List<Service>> getAll() async {
    try {
      logging.logger.debug('ServiceRepository: Fetching all services');
      final stream = _supabaseService.getServices();
      return await stream.first;
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error fetching all services',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.getAll');
      rethrow;
    }
  }

  @override
  Future<Service?> getById(String id) async {
    try {
      logging.logger.debug('ServiceRepository: Fetching service by ID: $id');
      final allServices = await getAll();
      return allServices.where((service) => service.id == id).firstOrNull;
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error fetching service by ID: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.getById');
      return null;
    }
  }

  @override
  Future<void> create(Service item) async {
    try {
      logging.logger.info('ServiceRepository: Creating service: ${item.title}');
      await _supabaseService.addService(item);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error creating service: ${item.title}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.create');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      logging.logger.info('ServiceRepository: Updating service: $id');
      await _supabaseService.updateService(id, data);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error updating service: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.update');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      logging.logger.warning('ServiceRepository: Deleting service: $id');
      await _supabaseService.deleteService(id);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error deleting service: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.delete');
      rethrow;
    }
  }

  @override
  Stream<List<Service>> watch() {
    try {
      logging.logger.debug(
        'ServiceRepository: Setting up services watch stream',
      );
      return _supabaseService.getServices();
    } catch (e) {
      logging.logger.error(
        'ServiceRepository: Error setting up watch stream',
        e,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.watch');
      rethrow;
    }
  }

  /// Get active services only
  Future<List<Service>> getActiveServices() async {
    try {
      logging.logger.debug('ServiceRepository: Fetching active services');
      final allServices = await getAll();
      return allServices.where((service) => service.isActive).toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error fetching active services',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'ServiceRepository.getActiveServices',
      );
      rethrow;
    }
  }

  /// Get services by category
  Future<List<Service>> getServicesByCategory(String category) async {
    try {
      logging.logger.debug(
        'ServiceRepository: Fetching services by category: $category',
      );
      final allServices = await getAll();
      return allServices
          .where((service) => service.category == category)
          .toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error fetching services by category: $category',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'ServiceRepository.getServicesByCategory',
      );
      rethrow;
    }
  }

  /// Search services
  Future<List<Service>> searchServices(String query) async {
    try {
      logging.logger.debug(
        'ServiceRepository: Searching services with query: $query',
      );
      final allServices = await getAll();
      final lowercaseQuery = query.toLowerCase();

      return allServices
          .where(
            (service) =>
                service.description.toLowerCase().contains(lowercaseQuery) ||
                service.category.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'ServiceRepository: Error searching services with query: $query',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ServiceRepository.searchServices');
      rethrow;
    }
  }
}

/// Booking repository implementation
class BookingRepository implements Repository<Booking> {
  final SupabaseService _supabaseService = SupabaseService.instance;

  @override
  Future<List<Booking>> getAll() async {
    try {
      logging.logger.debug('BookingRepository: Fetching all bookings');
      final stream = _supabaseService.getBookings();
      return await stream.first;
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error fetching all bookings',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.getAll');
      rethrow;
    }
  }

  @override
  Future<Booking?> getById(String id) async {
    try {
      logging.logger.debug('BookingRepository: Fetching booking by ID: $id');
      final allBookings = await getAll();
      return allBookings.where((booking) => booking.id == id).firstOrNull;
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error fetching booking by ID: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.getById');
      return null;
    }
  }

  @override
  Future<void> create(Booking item) async {
    try {
      logging.logger.info(
        'BookingRepository: Creating booking: ${item.serviceName} for ${item.clientName}',
      );
      await _supabaseService.addBooking(item);
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error creating booking: ${item.serviceName}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.create');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      logging.logger.info('BookingRepository: Updating booking: $id');
      // Use specific update method if updating status
      if (data.containsKey('status') && data.length == 1) {
        await _supabaseService.updateBookingStatus(id, data['status']);
      } else {
        // For other updates, we'd need a general update method in SupabaseService
        logging.logger.warning(
          'BookingRepository: General booking update not implemented',
        );
        throw UnimplementedError('General booking update not implemented');
      }
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error updating booking: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.update');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      logging.logger.warning('BookingRepository: Deleting booking: $id');
      await _supabaseService.deleteBooking(id);
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error deleting booking: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.delete');
      rethrow;
    }
  }

  @override
  Stream<List<Booking>> watch() {
    try {
      logging.logger.debug(
        'BookingRepository: Setting up bookings watch stream',
      );
      return _supabaseService.getBookings();
    } catch (e) {
      logging.logger.error(
        'BookingRepository: Error setting up watch stream',
        e,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.watch');
      rethrow;
    }
  }

  /// Update booking status
  Future<void> updateStatus(String id, String status) async {
    try {
      logging.logger.info(
        'BookingRepository: Updating booking status: $id -> $status',
      );
      await _supabaseService.updateBookingStatus(id, status);
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error updating booking status: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'BookingRepository.updateStatus');
      rethrow;
    }
  }

  /// Get bookings by status
  Future<List<Booking>> getBookingsByStatus(String status) async {
    try {
      logging.logger.debug(
        'BookingRepository: Fetching bookings by status: $status',
      );
      final allBookings = await getAll();
      return allBookings
          .where((booking) => booking.status.name == status)
          .toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error fetching bookings by status: $status',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'BookingRepository.getBookingsByStatus',
      );
      rethrow;
    }
  }

  /// Get bookings by client email
  Future<List<Booking>> getBookingsByClientEmail(String email) async {
    try {
      logging.logger.debug(
        'BookingRepository: Fetching bookings by client email: $email',
      );
      final allBookings = await getAll();
      return allBookings
          .where((booking) => booking.clientEmail == email)
          .toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error fetching bookings by client email: $email',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'BookingRepository.getBookingsByClientEmail',
      );
      rethrow;
    }
  }

  /// Get bookings by date range
  Future<List<Booking>> getBookingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      logging.logger.debug(
        'BookingRepository: Fetching bookings by date range: $startDate to $endDate',
      );
      final allBookings = await getAll();
      return allBookings.where((booking) {
        return booking.date.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            booking.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e, stackTrace) {
      logging.logger.error(
        'BookingRepository: Error fetching bookings by date range',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'BookingRepository.getBookingsByDateRange',
      );
      rethrow;
    }
  }
}

/// Project repository implementation
class ProjectRepository implements Repository<Project> {
  final SupabaseService _supabaseService = SupabaseService.instance;

  @override
  Future<List<Project>> getAll() async {
    try {
      logging.logger.debug('ProjectRepository: Fetching all projects');
      final stream = _supabaseService.getProjects();
      return await stream.first;
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error fetching all projects',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.getAll');
      rethrow;
    }
  }

  @override
  Future<Project?> getById(String id) async {
    try {
      logging.logger.debug('ProjectRepository: Fetching project by ID: $id');
      final allProjects = await getAll();
      return allProjects.where((project) => project.id == id).firstOrNull;
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error fetching project by ID: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.getById');
      return null;
    }
  }

  @override
  Future<void> create(Project item) async {
    try {
      logging.logger.info(
        'ProjectRepository: Creating project: ${item.title} for ${item.clientName}',
      );
      await _supabaseService.addProject(item);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error creating project: ${item.title}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.create');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      logging.logger.info('ProjectRepository: Updating project: $id');
      await _supabaseService.updateProject(id, data);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error updating project: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.update');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      logging.logger.warning('ProjectRepository: Deleting project: $id');
      await _supabaseService.deleteProject(id);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error deleting project: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.delete');
      rethrow;
    }
  }

  @override
  Stream<List<Project>> watch() {
    try {
      logging.logger.debug(
        'ProjectRepository: Setting up projects watch stream',
      );
      return _supabaseService.getProjects();
    } catch (e) {
      logging.logger.error(
        'ProjectRepository: Error setting up watch stream',
        e,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.watch');
      rethrow;
    }
  }

  /// Update project progress
  Future<void> updateProgress(String id, double progress) async {
    try {
      logging.logger.info(
        'ProjectRepository: Updating project progress: $id -> ${progress.toStringAsFixed(1)}%',
      );
      await _supabaseService.updateProjectProgress(id, progress);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error updating project progress: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.updateProgress');
      rethrow;
    }
  }

  /// Add project update
  Future<void> addUpdate(String id, Map<String, dynamic> update) async {
    try {
      logging.logger.info('ProjectRepository: Adding project update: $id');
      await _supabaseService.addProjectUpdate(id, update);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error adding project update: $id',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'ProjectRepository.addUpdate');
      rethrow;
    }
  }

  /// Get projects by status
  Future<List<Project>> getProjectsByStatus(String status) async {
    try {
      logging.logger.debug(
        'ProjectRepository: Fetching projects by status: $status',
      );
      return await _supabaseService.fetchProjectsByStatus(status);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error fetching projects by status: $status',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'ProjectRepository.getProjectsByStatus',
      );
      rethrow;
    }
  }

  /// Get projects by client email
  Future<List<Project>> getProjectsByClientEmail(String email) async {
    try {
      logging.logger.debug(
        'ProjectRepository: Fetching projects by client email: $email',
      );
      return await _supabaseService.fetchProjectsByClientEmail(email);
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error fetching projects by client email: $email',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'ProjectRepository.getProjectsByClientEmail',
      );
      rethrow;
    }
  }

  /// Get projects with pagination
  Future<List<Project>> getProjectsPaginated({
    int limit = 20,
    int offset = 0,
    String? status,
    String? clientEmail,
  }) async {
    try {
      logging.logger.debug(
        'ProjectRepository: Fetching projects with pagination: limit=$limit, offset=$offset',
      );
      return await _supabaseService.fetchProjects(
        limit: limit,
        offset: offset,
        status: status,
        clientEmail: clientEmail,
      );
    } catch (e, stackTrace) {
      logging.logger.error(
        'ProjectRepository: Error fetching projects with pagination',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'ProjectRepository.getProjectsPaginated',
      );
      rethrow;
    }
  }
}

/// Repository manager to coordinate all repositories
class RepositoryManager {
  static final RepositoryManager _instance = RepositoryManager._internal();
  factory RepositoryManager() => _instance;
  RepositoryManager._internal();

  late final UserRepository users;
  late final ServiceRepository services;
  late final BookingRepository bookings;
  late final ProjectRepository projects;

  /// Initialize all repositories
  void initialize() {
    logging.logger.info('Initializing RepositoryManager');

    users = UserRepository();
    services = ServiceRepository();
    bookings = BookingRepository();
    projects = ProjectRepository();

    logging.logger.info('RepositoryManager initialized successfully');
  }

  /// Get comprehensive statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      logging.logger.debug(
        'RepositoryManager: Fetching comprehensive statistics',
      );

      final results = await Future.wait([
        users.getAll(),
        services.getAll(),
        bookings.getAll(),
        projects.getAll(),
      ]);

      final allUsers = results[0] as List<User>;
      final allServices = results[1] as List<Service>;
      final allBookings = results[2] as List<Booking>;
      final allProjects = results[3] as List<Project>;

      return {
        'users': {
          'total': allUsers.length,
          'customers': allUsers.where((u) => u.role == 'customer').length,
          'admins': allUsers.where((u) => u.role == 'admin').length,
        },
        'services': {
          'total': allServices.length,
          'active': allServices.where((s) => s.isActive).length,
          'inactive': allServices.where((s) => !s.isActive).length,
        },
        'bookings': {
          'total': allBookings.length,
          'pending':
              allBookings.where((b) => b.status.name == 'pending').length,
          'confirmed':
              allBookings.where((b) => b.status.name == 'confirmed').length,
          'completed':
              allBookings.where((b) => b.status.name == 'completed').length,
        },
        'projects': {
          'total': allProjects.length,
          'active':
              allProjects.where((p) => p.status.name != 'completed').length,
          'completed':
              allProjects.where((p) => p.status.name == 'completed').length,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      logging.logger.error(
        'RepositoryManager: Error fetching statistics',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'RepositoryManager.getStatistics');
      rethrow;
    }
  }

  /// Dispose all repositories
  void dispose() {
    logging.logger.info('Disposing RepositoryManager');
    // Cleanup any resources if needed
  }
}
