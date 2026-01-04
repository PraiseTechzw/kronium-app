import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';

/// Production-ready toast utility for Kronium app
/// Provides consistent user feedback across the application
class ToastUtils {
  // Private constructor to prevent instantiation
  ToastUtils._();

  // Configuration constants for production
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _errorDuration = Duration(seconds: 4);
  static const Duration _loadingDuration = Duration(seconds: 2);
  static const EdgeInsets _defaultMargin = EdgeInsets.all(16);
  static const double _borderRadius = 12.0;
  static const double _iconSize = 20.0;

  /// Shows a success toast with green background and checkmark icon
  ///
  /// [message] - The success message to display
  /// [title] - Optional title for the toast (defaults to 'Success')
  /// [duration] - How long to show the toast (defaults to 3 seconds)
  static void showSuccess(String message, {String? title, Duration? duration}) {
    _showToast(
      title: title ?? 'Success',
      message: message,
      backgroundColor: AppTheme.successColor,
      icon: Iconsax.tick_circle,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows an error toast with red background and X icon
  ///
  /// [message] - The error message to display
  /// [title] - Optional title for the toast (defaults to 'Error')
  /// [duration] - How long to show the toast (defaults to 4 seconds)
  static void showError(String message, {String? title, Duration? duration}) {
    _showToast(
      title: title ?? 'Error',
      message: message,
      backgroundColor: AppTheme.errorColor,
      icon: Iconsax.close_circle,
      duration: duration ?? _errorDuration,
    );
  }

  /// Shows a warning toast with orange background and warning icon
  ///
  /// [message] - The warning message to display
  /// [title] - Optional title for the toast (defaults to 'Warning')
  /// [duration] - How long to show the toast (defaults to 3 seconds)
  static void showWarning(String message, {String? title, Duration? duration}) {
    _showToast(
      title: title ?? 'Warning',
      message: message,
      backgroundColor: AppTheme.warningColor,
      icon: Iconsax.warning_2,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows an info toast with blue background and info icon
  ///
  /// [message] - The info message to display
  /// [title] - Optional title for the toast (defaults to 'Info')
  /// [duration] - How long to show the toast (defaults to 3 seconds)
  static void showInfo(String message, {String? title, Duration? duration}) {
    _showToast(
      title: title ?? 'Info',
      message: message,
      backgroundColor: AppTheme.infoColor,
      icon: Iconsax.info_circle,
      duration: duration ?? _defaultDuration,
    );
  }

  /// Shows a loading toast with primary color background and spinner
  ///
  /// [message] - The loading message to display
  /// [title] - Optional title for the toast (defaults to 'Loading')
  /// [duration] - How long to show the toast (defaults to 2 seconds)
  static void showLoading(String message, {String? title, Duration? duration}) {
    _showToast(
      title: title ?? 'Loading',
      message: message,
      backgroundColor: AppTheme.primaryColor,
      icon: Iconsax.refresh,
      duration: duration ?? _loadingDuration,
      isDismissible: false,
      showProgressIndicator: true,
    );
  }

  /// Shows a custom toast with specified parameters
  ///
  /// [message] - The message to display
  /// [title] - Optional title for the toast
  /// [backgroundColor] - Background color (defaults to primary color)
  /// [textColor] - Text color (defaults to white)
  /// [icon] - Icon to display
  /// [duration] - How long to show the toast (defaults to 3 seconds)
  /// [position] - Position of the toast (defaults to TOP)
  /// [isDismissible] - Whether the toast can be dismissed (defaults to true)
  static void showCustom({
    required String message,
    String? title,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    SnackPosition? position,
    bool? isDismissible,
  }) {
    _showToast(
      title: title ?? '',
      message: message,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      textColor: textColor ?? Colors.white,
      icon: icon,
      duration: duration ?? _defaultDuration,
      position: position ?? SnackPosition.TOP,
      isDismissible: isDismissible ?? true,
    );
  }

  /// Dismisses all currently visible toasts
  static void dismissAll() {
    try {
      if (_isOverlayAvailable()) {
        Get.closeAllSnackbars();
      } else {
        debugPrint('ToastUtils: Cannot dismiss toasts - overlay not available');
      }
    } catch (e) {
      // Silently handle any errors when dismissing toasts
      debugPrint('Error dismissing toasts: $e');
    }
  }

  /// Checks if the overlay context is available for showing snackbars
  static bool _isOverlayAvailable() {
    try {
      // Check if Get context is available and has overlay
      final context = Get.context;
      if (context == null) return false;

      // Try to find overlay - this will throw if not available
      Overlay.of(context, rootOverlay: false);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Private method to show toast with consistent styling
  static void _showToast({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData? icon,
    required Duration duration,
    Color textColor = Colors.white,
    SnackPosition position = SnackPosition.TOP,
    bool isDismissible = true,
    bool showProgressIndicator = false,
  }) {
    try {
      // Validate inputs
      if (message.trim().isEmpty) {
        debugPrint('ToastUtils: Message cannot be empty');
        return;
      }

      // Check if overlay is available before showing toast
      if (!_isOverlayAvailable()) {
        // Fallback to console logging with clear formatting
        final logMessage = title.isNotEmpty ? '$title: $message' : message;
        debugPrint('🔔 TOAST (Overlay not ready): $logMessage');

        // Schedule toast to show after a short delay when overlay might be ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isOverlayAvailable()) {
            _showToast(
              title: title,
              message: message,
              backgroundColor: backgroundColor,
              icon: icon,
              duration: duration,
              textColor: textColor,
              position: position,
              isDismissible: isDismissible,
              showProgressIndicator: showProgressIndicator,
            );
          } else {
            // Still not ready, just log it
            debugPrint('🔔 TOAST (Deferred): $logMessage');
          }
        });
        return;
      }

      // Truncate message if too long for better UX
      final truncatedMessage =
          message.length > 200 ? '${message.substring(0, 200)}...' : message;

      Get.snackbar(
        title,
        truncatedMessage,
        backgroundColor: backgroundColor,
        colorText: textColor,
        icon:
            showProgressIndicator
                ? SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
                : icon != null
                ? Icon(icon, color: textColor, size: _iconSize)
                : null,
        snackPosition: position,
        duration: duration,
        margin: _defaultMargin,
        borderRadius: _borderRadius,
        isDismissible: isDismissible,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
        maxWidth: 400, // Limit width for better readability
        shouldIconPulse: !showProgressIndicator,
        snackStyle: SnackStyle.FLOATING,
      );
    } catch (e) {
      // Fallback to console logging if toast fails
      final logMessage = title.isNotEmpty ? '$title: $message' : message;
      debugPrint('🔔 TOAST (Error): $logMessage');
      debugPrint('ToastUtils Error: $e');
    }
  }
}
