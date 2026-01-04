import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/logger_service.dart';
import 'package:kronium/core/toast_utils.dart';

/// Production-ready error handling service
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle and display user-friendly error messages
  static void handleError(
    dynamic error, {
    String? context,
    bool showToUser = true,
  }) {
    String userMessage = _getUserFriendlyMessage(error);
    String technicalMessage = error.toString();

    // Log the technical error
    logger.error('Error in $context: $technicalMessage', error);

    // Show user-friendly message if requested
    if (showToUser && Get.context != null) {
      showErrorSnackbar(userMessage);
    }
  }

  /// Handle authentication errors specifically
  static void handleAuthError(dynamic error, {String? context}) {
    String message = _getAuthErrorMessage(error);
    logger.error('Auth error in $context: ${error.toString()}', error);

    if (Get.context != null) {
      showErrorSnackbar(message);
    }
  }

  /// Handle network errors
  static void handleNetworkError(dynamic error, {String? context}) {
    String message = _getNetworkErrorMessage(error);
    logger.error('Network error in $context: ${error.toString()}', error);

    if (Get.context != null) {
      showErrorSnackbar(message);
    }
  }

  /// Handle validation errors
  static void handleValidationError(String message, {String? context}) {
    logger.warning('Validation error in $context: $message');

    if (Get.context != null) {
      showWarningSnackbar(message);
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(String message) {
    ToastUtils.showError(message);
  }

  /// Show warning snackbar
  static void showWarningSnackbar(String message) {
    ToastUtils.showWarning(message);
  }

  /// Show success snackbar
  static void showSuccessSnackbar(String message) {
    ToastUtils.showSuccess(message);
  }

  /// Show info snackbar
  static void showInfoSnackbar(String message) {
    ToastUtils.showInfo(message);
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'You are not authorized to perform this action. Please log in again.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'Please check your input and try again.';
    }

    if (errorString.contains('duplicate') ||
        errorString.contains('already exists')) {
      return 'This item already exists. Please use a different value.';
    }

    // Default message for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get authentication-specific error message
  static String _getAuthErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid_credentials') ||
        errorString.contains('invalid login')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (errorString.contains('user_not_found')) {
      return 'No account found with this email address.';
    }

    if (errorString.contains('email_already_exists') ||
        errorString.contains('user_already_registered')) {
      return 'An account with this email already exists. Please use a different email or try logging in.';
    }

    if (errorString.contains('weak_password')) {
      return 'Password is too weak. Please use a stronger password.';
    }

    if (errorString.contains('email_not_confirmed')) {
      return 'Please check your email and click the confirmation link before logging in.';
    }

    if (errorString.contains('too_many_requests')) {
      return 'Too many login attempts. Please wait a few minutes before trying again.';
    }

    if (errorString.contains('session_expired')) {
      return 'Your session has expired. Please log in again.';
    }

    return 'Authentication failed. Please try again.';
  }

  /// Get network-specific error message
  static String _getNetworkErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('no internet') ||
        errorString.contains('offline')) {
      return 'No internet connection. Please check your network settings.';
    }

    if (errorString.contains('dns') || errorString.contains('host lookup')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    if (errorString.contains('ssl') || errorString.contains('certificate')) {
      return 'Secure connection failed. Please try again.';
    }

    return 'Network error. Please check your connection and try again.';
  }

  /// Show error dialog for critical errors
  static void showErrorDialog({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    if (Get.context == null) return;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (actionText != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionText)),
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    if (Get.context == null) return false;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }
}
