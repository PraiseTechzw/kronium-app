import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/models/booking_model.dart';

class AdminNotificationService extends GetxController {
  static AdminNotificationService get instance => Get.find();

  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Observable lists for real-time updates
  final RxList<AdminNotification> _notifications = <AdminNotification>[].obs;
  final RxInt _unreadCount = 0.obs;

  List<AdminNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    // Listen to bookings for new customer requests
    _firebaseService.getBookings().listen((bookings) {
      for (var booking in bookings) {
        if (booking.status == BookingStatus.pending) {
          _addNotification(
            AdminNotification(
              id: 'booking_${booking.id}',
              type: NotificationType.newBooking,
              title: 'New Booking Request',
              message: '${booking.clientName} requested ${booking.serviceName}',
              customerId: booking.clientEmail,
              customerName: booking.clientName,
              timestamp: booking.date,
              isRead: false,
            ),
          );
        }
      }
    });

    // Listen to chat messages for customer inquiries
    _firebaseService.getChatRooms().listen((chatRooms) {
      for (var chat in chatRooms) {
        if (chat.lastMessageAt != null) {
          final timeDiff = DateTime.now().difference(chat.lastMessageAt!);
          if (timeDiff.inMinutes < 5) {
            // New message within 5 minutes
            _addNotification(
              AdminNotification(
                id: 'chat_${chat.id}',
                type: NotificationType.newMessage,
                title: 'New Message',
                message: '${chat.customerName} sent a message',
                customerId: chat.customerEmail,
                customerName: chat.customerName,
                timestamp: chat.lastMessageAt!,
                isRead: false,
              ),
            );
          }
        }
      }
    });
  }

  void _addNotification(AdminNotification notification) {
    // Check if notification already exists
    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification);
      _unreadCount.value++;

      // Show snackbar for important notifications
      if (notification.type == NotificationType.newBooking) {
        Get.snackbar(
          'New Booking Request',
          notification.message,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Iconsax.calendar, color: Colors.white),
          onTap: (_) => _markAsRead(notification.id),
        );
      }
    }
  }

  void _markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount.value--;
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _unreadCount.value = 0;
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount.value = 0;
  }

  void sendServiceOfferToCustomer(String customerId, Service service) {
    _addNotification(
      AdminNotification(
        id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.serviceOffer,
        title: 'Service Offer Sent',
        message: 'Offered ${service.title} to customer',
        customerId: customerId,
        customerName: 'Customer',
        timestamp: DateTime.now(),
        isRead: true,
      ),
    );
  }
}

enum NotificationType {
  newBooking,
  newMessage,
  serviceOffer,
  customerRegistration,
}

class AdminNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String customerId;
  final String customerName;
  final DateTime timestamp;
  final bool isRead;

  AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.customerId,
    required this.customerName,
    required this.timestamp,
    required this.isRead,
  });

  AdminNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? customerId,
    String? customerName,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class AdminNotificationWidget extends StatelessWidget {
  const AdminNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<AdminNotificationService>();

    return Obx(
      () => Stack(
        children: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () => _showNotifications(context),
          ),
          if (notificationService.unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${notificationService.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final notificationService = Get.find<AdminNotificationService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (notificationService.unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          notificationService.markAllAsRead();
                        },
                        child: const Text('Mark All Read'),
                      ),
                    IconButton(
                      onPressed: () {
                        notificationService.clearNotifications();
                        Get.back();
                      },
                      icon: const Icon(Iconsax.trash),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (notificationService.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.notification,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: notificationService.notifications.length,
                      itemBuilder: (context, index) {
                        final notification =
                            notificationService.notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildNotificationCard(AdminNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.grey[200]!
                  : Colors.blue.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
        trailing:
            notification.isRead
                ? null
                : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
        onTap: () {
          if (!notification.isRead) {
            Get.find<AdminNotificationService>()._markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newBooking:
        return Colors.orange;
      case NotificationType.newMessage:
        return Colors.blue;
      case NotificationType.serviceOffer:
        return Colors.green;
      case NotificationType.customerRegistration:
        return Colors.purple;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newBooking:
        return Iconsax.calendar;
      case NotificationType.newMessage:
        return Iconsax.message;
      case NotificationType.serviceOffer:
        return Iconsax.add_circle;
      case NotificationType.customerRegistration:
        return Iconsax.user_add;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(AdminNotification notification) {
    switch (notification.type) {
      case NotificationType.newBooking:
        Get.toNamed('/admin-bookings');
        break;
      case NotificationType.newMessage:
        Get.toNamed('/admin-chat');
        break;
      case NotificationType.serviceOffer:
        Get.toNamed('/admin-services');
        break;
      case NotificationType.customerRegistration:
        Get.toNamed('/admin-management');
        break;
    }
  }
}
