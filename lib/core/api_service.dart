import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kronium/core/logger_service.dart' as logging;
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/security_service.dart';
import 'package:kronium/core/config_service.dart';

/// Production-ready API service for external integrations
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecurityService _securityService = SecurityService();
  late final http.Client _httpClient;

  // API Configuration
  static const String baseUrl =
      'https://api.kronium.com'; // Replace with your API URL
  static const Duration defaultTimeout = Duration(seconds: 30);

  // Headers
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Kronium-Mobile/${ConfigService.appVersion}',
    'X-API-Version': '1.0',
  };

  /// Initialize API service
  void initialize() {
    _httpClient = http.Client();
    logging.logger.info('API Service initialized');
  }

  /// Make authenticated GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) async {
    return _makeRequest(
      'GET',
      endpoint,
      headers: headers,
      queryParams: queryParams,
      timeout: timeout,
    );
  }

  /// Make authenticated POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _makeRequest(
      'POST',
      endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
    );
  }

  /// Make authenticated PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _makeRequest(
      'PUT',
      endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
    );
  }

  /// Make authenticated DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _makeRequest('DELETE', endpoint, headers: headers, timeout: timeout);
  }

  /// Core HTTP request method
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
  }) async {
    try {
      // Build URL
      final uri = _buildUri(endpoint, queryParams);

      // Prepare headers
      final requestHeaders = <String, String>{..._defaultHeaders, ...?headers};

      // Rate limiting check
      if (!_securityService.checkRateLimit('api_$endpoint', maxRequests: 100)) {
        throw ApiException('Rate limit exceeded for endpoint: $endpoint', 429);
      }

      // Log request
      logging.logger.debug('API Request: $method $uri');

      // Prepare request
      final request = http.Request(method, uri);
      request.headers.addAll(requestHeaders);

      if (body != null) {
        // Sanitize request body
        final sanitizedBody = _sanitizeRequestBody(body);
        request.body = jsonEncode(sanitizedBody);
        logging.logger.debug('Request body: ${request.body}');
      }

      // Send request with timeout
      final streamedResponse = await _httpClient
          .send(request)
          .timeout(timeout ?? defaultTimeout);

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      // Log response
      logging.logger.debug(
        'API Response: ${response.statusCode} for $method $uri',
      );

      // Handle response
      return _handleResponse(response, endpoint);
    } on SocketException catch (e) {
      logging.logger.error('Network error for $method $endpoint', e);
      ErrorHandler.handleNetworkError(e, context: 'API $method $endpoint');
      throw ApiException('Network connection failed', 0, originalError: e);
    } on http.ClientException catch (e) {
      logging.logger.error('Timeout error for $method $endpoint', e);
      ErrorHandler.handleError(e, context: 'API $method $endpoint timeout');
      throw ApiException('Request timeout', 408, originalError: e);
    } catch (e) {
      logging.logger.error('Unexpected error for $method $endpoint', e);
      ErrorHandler.handleError(e, context: 'API $method $endpoint');
      rethrow;
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      final sanitizedParams = <String, String>{};
      queryParams.forEach((key, value) {
        if (value != null) {
          sanitizedParams[key] = _securityService.sanitizeInput(
            value.toString(),
          );
        }
      });
      return uri.replace(queryParameters: sanitizedParams);
    }

    return uri;
  }

  /// Sanitize request body to prevent injection attacks
  Map<String, dynamic> _sanitizeRequestBody(Map<String, dynamic> body) {
    final sanitized = <String, dynamic>{};

    body.forEach((key, value) {
      if (value is String) {
        // Check for SQL injection patterns
        if (_securityService.containsSqlInjection(value)) {
          logging.logger.warning(
            'Potential SQL injection detected in request body',
          );
          throw ApiException('Invalid request data', 400);
        }
        sanitized[key] = _securityService.sanitizeInput(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeRequestBody(value);
      } else if (value is List) {
        sanitized[key] =
            value.map((item) {
              if (item is String) {
                return _securityService.sanitizeInput(item);
              } else if (item is Map<String, dynamic>) {
                return _sanitizeRequestBody(item);
              }
              return item;
            }).toList();
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(
    http.Response response,
    String endpoint,
  ) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    logging.logger.debug(
      'Response status: $statusCode, body length: ${responseBody.length}',
    );

    // Parse response body
    Map<String, dynamic> data;
    try {
      data = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      logging.logger.error('Failed to parse response JSON for $endpoint', e);
      throw ApiException('Invalid response format', statusCode);
    }

    // Handle different status codes
    switch (statusCode) {
      case 200:
      case 201:
      case 202:
        logging.logger.debug('Successful response for $endpoint');
        return data;

      case 400:
        logging.logger.warning(
          'Bad request for $endpoint: ${data['message'] ?? 'Unknown error'}',
        );
        throw ApiException(
          data['message'] ?? 'Bad request',
          statusCode,
          data: data,
        );

      case 401:
        logging.logger.warning('Unauthorized request for $endpoint');
        throw ApiException('Authentication required', statusCode, data: data);

      case 403:
        logging.logger.warning('Forbidden request for $endpoint');
        throw ApiException('Access denied', statusCode, data: data);

      case 404:
        logging.logger.warning('Not found for $endpoint');
        throw ApiException('Resource not found', statusCode, data: data);

      case 409:
        logging.logger.warning('Conflict for $endpoint');
        throw ApiException(
          data['message'] ?? 'Resource conflict',
          statusCode,
          data: data,
        );

      case 422:
        logging.logger.warning('Validation error for $endpoint');
        throw ApiException(
          data['message'] ?? 'Validation failed',
          statusCode,
          data: data,
        );

      case 429:
        logging.logger.warning('Rate limit exceeded for $endpoint');
        throw ApiException('Too many requests', statusCode, data: data);

      case 500:
      case 502:
      case 503:
      case 504:
        logging.logger.error('Server error for $endpoint: $statusCode');
        throw ApiException('Server error', statusCode, data: data);

      default:
        logging.logger.error(
          'Unexpected status code for $endpoint: $statusCode',
        );
        throw ApiException('Unexpected error', statusCode, data: data);
    }
  }

  // ==================== SPECIFIC API ENDPOINTS ====================

  /// Send push notification
  Future<Map<String, dynamic>> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return post(
      '/notifications/push',
      body: {
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
      },
    );
  }

  /// Send email notification
  Future<Map<String, dynamic>> sendEmailNotification({
    required String to,
    required String subject,
    required String body,
    String? template,
    Map<String, dynamic>? templateData,
  }) async {
    return post(
      '/notifications/email',
      body: {
        'to': to,
        'subject': subject,
        'body': body,
        'template': template,
        'templateData': templateData ?? {},
      },
    );
  }

  /// Send SMS notification
  Future<Map<String, dynamic>> sendSmsNotification({
    required String phoneNumber,
    required String message,
  }) async {
    return post(
      '/notifications/sms',
      body: {'phoneNumber': phoneNumber, 'message': message},
    );
  }

  /// Process payment
  Future<Map<String, dynamic>> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required String customerId,
    Map<String, dynamic>? metadata,
  }) async {
    return post(
      '/payments/process',
      body: {
        'paymentMethodId': paymentMethodId,
        'amount': amount,
        'currency': currency,
        'customerId': customerId,
        'metadata': metadata ?? {},
      },
    );
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    return get('/payments/$paymentId/status');
  }

  /// Refund payment
  Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    return post(
      '/payments/$paymentId/refund',
      body: {'amount': amount, 'reason': reason},
    );
  }

  /// Generate analytics report
  Future<Map<String, dynamic>> generateAnalyticsReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    return post(
      '/analytics/reports',
      body: {
        'reportType': reportType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'filters': filters ?? {},
      },
    );
  }

  /// Get system health
  Future<Map<String, dynamic>> getSystemHealth() async {
    return get('/health');
  }

  /// Upload file to external storage
  Future<Map<String, dynamic>> uploadFileToCloud({
    required File file,
    required String folder,
    Map<String, String>? metadata,
  }) async {
    try {
      logging.logger.info('Uploading file to cloud: ${file.path}');

      // Validate file
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();

      final validation = _securityService.validateFileUpload(
        fileName,
        fileSize,
        null,
      );
      if (!validation['isValid']) {
        throw ApiException(
          'File validation failed: ${validation['errors'].join(', ')}',
          400,
        );
      }

      // Create multipart request
      final uri = _buildUri('/files/upload', null);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_defaultHeaders);
      request.headers.remove(
        'Content-Type',
      ); // Let http package set this for multipart

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Add metadata
      request.fields['folder'] = folder;
      if (metadata != null) {
        metadata.forEach((key, value) {
          request.fields[key] = _securityService.sanitizeInput(value);
        });
      }

      // Send request
      final streamedResponse = await _httpClient
          .send(request)
          .timeout(const Duration(minutes: 5));
      final response = await http.Response.fromStream(streamedResponse);

      logging.logger.info(
        'File upload completed with status: ${response.statusCode}',
      );
      return _handleResponse(response, '/files/upload');
    } catch (e, stackTrace) {
      logging.logger.error('Error uploading file to cloud', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Cloud file upload');
      rethrow;
    }
  }

  /// Validate API key
  Future<Map<String, dynamic>> validateApiKey(String apiKey) async {
    return post('/auth/validate', body: {'apiKey': apiKey});
  }

  /// Get API usage statistics
  Future<Map<String, dynamic>> getApiUsageStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    return get('/analytics/api-usage', queryParams: queryParams);
  }

  /// Dispose resources
  void dispose() {
    logging.logger.info('Disposing API Service resources');
    _httpClient.close();
  }
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? data;
  final dynamic originalError;

  const ApiException(
    this.message,
    this.statusCode, {
    this.data,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }

  /// Check if this is a network error
  bool get isNetworkError => statusCode == 0;

  /// Check if this is a server error
  bool get isServerError => statusCode >= 500;

  /// Check if this is a client error
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Check if this is an authentication error
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if this is a validation error
  bool get isValidationError => statusCode == 422 || statusCode == 400;

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (statusCode) {
      case 0:
        return 'Network connection failed. Please check your internet connection.';
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication required. Please log in again.';
      case 403:
        return 'Access denied. You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data.';
      case 422:
        return 'Please check your input and try again.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server error. Please try again later.';
      default:
        return message;
    }
  }
}
