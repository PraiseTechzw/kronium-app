import 'dart:async';
import 'package:kronium/core/logger_service.dart' as logging;
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/api_service.dart';
import 'package:get/get.dart';

/// Production-ready notification service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();
  final List<NotificationHandler> _handlers = [];
  final StreamController<AppNotification> _notificationController =
      StreamController.broadcast();

  /// Stream of notifications
  Stream<AppNotification> get notifications => _notificationController.stream;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      logging.logger.info('Initializing NotificationService');

      // Register default handlers
      _registerDefaultHandlers();

      // Initialize API service if not already done
      _apiService.initialize();

      logging.logger.info('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error initializing NotificationService',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(
        e,
        context: 'NotificationService initialization',
      );
      rethrow;
    }
  }

  /// Register default notification handlers
  void _registerDefaultHandlers() {
    // Email notification handler
    registerHandler(EmailNotificationHandler());

    // SMS notification handler
    registerHandler(SmsNotificationHandler());

    // Push notification handler
    registerHandler(PushNotificationHandler());

    // In-app notification handler
    registerHandler(InAppNotificationHandler());

    logging.logger.debug(
      'Registered ${_handlers.length} default notification handlers',
    );
  }

  /// Register a notification handler
  void registerHandler(NotificationHandler handler) {
    _handlers.add(handler);
    logging.logger.debug('Registered notification handler: ${handler.type}');
  }

  /// Send notification
  Future<NotificationResult> sendNotification(
    AppNotification notification,
  ) async {
    try {
      logging.logger.info(
        'Sending notification: ${notification.type} to ${notification.recipient}',
      );

      // Validate notification
      if (!_validateNotification(notification)) {
        throw ArgumentError('Invalid notification data');
      }

      // Find appropriate handler
      final handler = _handlers.firstWhereOrNull(
        (h) => h.canHandle(notification),
      );
      if (handler == null) {
        throw Exception(
          'No handler found for notification type: ${notification.type}',
        );
      }

      // Send notification
      final result = await handler.send(notification);

      // Log result
      if (result.success) {
        logging.logger.info(
          'Notification sent successfully: ${notification.id}',
        );
      } else {
        logging.logger.warning(
          'Notification failed: ${notification.id} - ${result.error}',
        );
      }

      // Add to stream for in-app handling
      _notificationController.add(notification);

      return result;
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error sending notification: ${notification.id}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Send notification');
      return NotificationResult(
        success: false,
        error: e.toString(),
        notificationId: notification.id,
      );
    }
  }

  /// Send multiple notifications
  Future<List<NotificationResult>> sendBulkNotifications(
    List<AppNotification> notifications,
  ) async {
    try {
      logging.logger.info('Sending ${notifications.length} bulk notifications');

      final results = <NotificationResult>[];

      // Send notifications concurrently with limit
      const batchSize = 10;
      for (int i = 0; i < notifications.length; i += batchSize) {
        final batch = notifications.skip(i).take(batchSize);
        final batchResults = await Future.wait(
          batch.map((notification) => sendNotification(notification)),
        );
        results.addAll(batchResults);
      }

      final successCount = results.where((r) => r.success).length;
      logging.logger.info(
        'Bulk notifications completed: $successCount/${notifications.length} successful',
      );

      return results;
    } catch (e, stackTrace) {
      logging.logger.error('Error sending bulk notifications', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Send bulk notifications');
      rethrow;
    }
  }

  /// Validate notification data
  bool _validateNotification(AppNotification notification) {
    if (notification.recipient.isEmpty) {
      logging.logger.warning('Notification validation failed: empty recipient');
      return false;
    }

    if (notification.title.isEmpty && notification.body.isEmpty) {
      logging.logger.warning(
        'Notification validation failed: empty title and body',
      );
      return false;
    }

    return true;
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Send welcome notification to new user
  Future<NotificationResult> sendWelcomeNotification(
    String userId,
    String userName,
    String email,
  ) async {
    final notification = AppNotification(
      id: 'welcome_$userId',
      type: NotificationType.email,
      recipient: email,
      title: 'Welcome to Kronium Pro!',
      body:
          'Hi $userName, welcome to Kronium Pro. We\'re excited to have you on board!',
      data: {'userId': userId, 'userName': userName, 'template': 'welcome'},
    );

    return await sendNotification(notification);
  }

  /// Send booking confirmation notification
  Future<NotificationResult> sendBookingConfirmation({
    required String userId,
    required String email,
    required String serviceName,
    required DateTime bookingDate,
    required String bookingId,
  }) async {
    final notification = AppNotification(
      id: 'booking_confirmation_$bookingId',
      type: NotificationType.email,
      recipient: email,
      title: 'Booking Confirmed - $serviceName',
      body:
          'Your booking for $serviceName on ${bookingDate.toString().split(' ')[0]} has been confirmed.',
      data: {
        'userId': userId,
        'bookingId': bookingId,
        'serviceName': serviceName,
        'bookingDate': bookingDate.toIso8601String(),
        'template': 'booking_confirmation',
      },
    );

    return await sendNotification(notification);
  }

  /// Send project update notification
  Future<NotificationResult> sendProjectUpdate({
    required String userId,
    required String email,
    required String projectTitle,
    required String updateMessage,
    required String projectId,
  }) async {
    final notification = AppNotification(
      id: 'project_update_${projectId}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.email,
      recipient: email,
      title: 'Project Update - $projectTitle',
      body: updateMessage,
      data: {
        'userId': userId,
        'projectId': projectId,
        'projectTitle': projectTitle,
        'template': 'project_update',
      },
    );

    return await sendNotification(notification);
  }

  /// Send payment confirmation notification
  Future<NotificationResult> sendPaymentConfirmation({
    required String userId,
    required String email,
    required double amount,
    required String currency,
    required String paymentId,
  }) async {
    final notification = AppNotification(
      id: 'payment_confirmation_$paymentId',
      type: NotificationType.email,
      recipient: email,
      title: 'Payment Confirmed',
      body:
          'Your payment of $currency${amount.toStringAsFixed(2)} has been processed successfully.',
      data: {
        'userId': userId,
        'paymentId': paymentId,
        'amount': amount,
        'currency': currency,
        'template': 'payment_confirmation',
      },
    );

    return await sendNotification(notification);
  }

  /// Send admin alert notification
  Future<NotificationResult> sendAdminAlert({
    required String title,
    required String message,
    required String alertType,
    Map<String, dynamic>? data,
  }) async {
    // Get admin users (this would typically come from a user service)
    final adminEmails = [
      'admin@kronium.com',
    ]; // Replace with actual admin emails

    final results = <NotificationResult>[];

    for (final email in adminEmails) {
      final notification = AppNotification(
        id: 'admin_alert_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.email,
        recipient: email,
        title: 'Admin Alert: $title',
        body: message,
        priority: NotificationPriority.high,
        data: {'alertType': alertType, 'template': 'admin_alert', ...?data},
      );

      final result = await sendNotification(notification);
      results.add(result);
    }

    return results.first; // Return first result for simplicity
  }

  /// Send push notification to user
  Future<NotificationResult> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: 'push_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.push,
      recipient: userId,
      title: title,
      body: body,
      data: data ?? {},
    );

    return await sendNotification(notification);
  }

  /// Send SMS notification
  Future<NotificationResult> sendSmsNotification({
    required String phoneNumber,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: 'sms_${phoneNumber}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.sms,
      recipient: phoneNumber,
      title: '',
      body: message,
      data: data ?? {},
    );

    return await sendNotification(notification);
  }

  /// Dispose notification service
  void dispose() {
    logging.logger.info('Disposing NotificationService');
    _notificationController.close();
    _handlers.clear();
  }
}

/// Notification types
enum NotificationType { email, sms, push, inApp }

/// Notification priority
enum NotificationPriority { low, normal, high, urgent }

/// App notification model
class AppNotification {
  final String id;
  final NotificationType type;
  final String recipient;
  final String title;
  final String body;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.recipient,
    required this.title,
    required this.body,
    this.priority = NotificationPriority.normal,
    this.data = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'recipient': recipient,
      'title': title,
      'body': body,
      'priority': priority.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Notification result
class NotificationResult {
  final bool success;
  final String? error;
  final String notificationId;
  final Map<String, dynamic>? responseData;

  NotificationResult({
    required this.success,
    this.error,
    required this.notificationId,
    this.responseData,
  });
}

/// Abstract notification handler
abstract class NotificationHandler {
  String get type;
  bool canHandle(AppNotification notification);
  Future<NotificationResult> send(AppNotification notification);
}

/// Email notification handler
class EmailNotificationHandler extends NotificationHandler {
  final ApiService _apiService = ApiService();

  @override
  String get type => 'email';

  @override
  bool canHandle(AppNotification notification) {
    return notification.type == NotificationType.email;
  }

  @override
  Future<NotificationResult> send(AppNotification notification) async {
    try {
      logging.logger.debug('Sending email notification: ${notification.id}');

      final response = await _apiService.sendEmailNotification(
        to: notification.recipient,
        subject: notification.title,
        body: notification.body,
        template: notification.data['template'],
        templateData: notification.data,
      );

      return NotificationResult(
        success: true,
        notificationId: notification.id,
        responseData: response,
      );
    } catch (e) {
      logging.logger.error(
        'Error sending email notification: ${notification.id}',
        e,
      );
      return NotificationResult(
        success: false,
        error: e.toString(),
        notificationId: notification.id,
      );
    }
  }
}

/// SMS notification handler
class SmsNotificationHandler extends NotificationHandler {
  final ApiService _apiService = ApiService();

  @override
  String get type => 'sms';

  @override
  bool canHandle(AppNotification notification) {
    return notification.type == NotificationType.sms;
  }

  @override
  Future<NotificationResult> send(AppNotification notification) async {
    try {
      logging.logger.debug('Sending SMS notification: ${notification.id}');

      final response = await _apiService.sendSmsNotification(
        phoneNumber: notification.recipient,
        message: notification.body,
      );

      return NotificationResult(
        success: true,
        notificationId: notification.id,
        responseData: response,
      );
    } catch (e) {
      logging.logger.error(
        'Error sending SMS notification: ${notification.id}',
        e,
      );
      return NotificationResult(
        success: false,
        error: e.toString(),
        notificationId: notification.id,
      );
    }
  }
}

/// Push notification handler
class PushNotificationHandler extends NotificationHandler {
  final ApiService _apiService = ApiService();

  @override
  String get type => 'push';

  @override
  bool canHandle(AppNotification notification) {
    return notification.type == NotificationType.push;
  }

  @override
  Future<NotificationResult> send(AppNotification notification) async {
    try {
      logging.logger.debug('Sending push notification: ${notification.id}');

      final response = await _apiService.sendPushNotification(
        userId: notification.recipient,
        title: notification.title,
        body: notification.body,
        data: notification.data,
      );

      return NotificationResult(
        success: true,
        notificationId: notification.id,
        responseData: response,
      );
    } catch (e) {
      logging.logger.error(
        'Error sending push notification: ${notification.id}',
        e,
      );
      return NotificationResult(
        success: false,
        error: e.toString(),
        notificationId: notification.id,
      );
    }
  }
}

/// In-app notification handler
class InAppNotificationHandler extends NotificationHandler {
  @override
  String get type => 'inApp';

  @override
  bool canHandle(AppNotification notification) {
    return notification.type == NotificationType.inApp;
  }

  @override
  Future<NotificationResult> send(AppNotification notification) async {
    try {
      logging.logger.debug('Showing in-app notification: ${notification.id}');

      // Show in-app notification using ErrorHandler
      if (notification.priority == NotificationPriority.high ||
          notification.priority == NotificationPriority.urgent) {
        ErrorHandler.showInfoSnackbar(
          '${notification.title}: ${notification.body}',
        );
      } else {
        ErrorHandler.showInfoSnackbar(notification.body);
      }

      return NotificationResult(success: true, notificationId: notification.id);
    } catch (e) {
      logging.logger.error(
        'Error showing in-app notification: ${notification.id}',
        e,
      );
      return NotificationResult(
        success: false,
        error: e.toString(),
        notificationId: notification.id,
      );
    }
  }
}
