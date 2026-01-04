/// Production-ready validation service
class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    if (price > 1000000) {
      return 'Price cannot exceed \$1,000,000';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL (starting with http:// or https://)';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    if (value.isBefore(now.subtract(const Duration(days: 1)))) {
      return 'Date cannot be in the past';
    }

    if (value.isAfter(now.add(const Duration(days: 365)))) {
      return 'Date cannot be more than 1 year in the future';
    }

    return null;
  }

  // Text length validation
  static String? validateLength(
    String? value,
    String fieldName, {
    int minLength = 1,
    int maxLength = 255,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (trimmedValue.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  // Service title validation
  static String? validateServiceTitle(String? value) {
    return validateLength(value, 'Service title', minLength: 3, maxLength: 100);
  }

  // Service description validation
  static String? validateServiceDescription(String? value) {
    return validateLength(
      value,
      'Service description',
      minLength: 10,
      maxLength: 1000,
    );
  }

  // Project title validation
  static String? validateProjectTitle(String? value) {
    return validateLength(value, 'Project title', minLength: 3, maxLength: 100);
  }

  // Address validation
  static String? validateAddress(String? value) {
    return validateLength(value, 'Address', minLength: 10, maxLength: 500);
  }

  // Simple ID validation (AAA00001 format)
  static String? validateSimpleId(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Simple ID is auto-generated
    }

    if (!RegExp(r'^[A-Z]{3}\d{5}$').hasMatch(value)) {
      return 'Simple ID must be in format AAA00001';
    }

    return null;
  }

  // Sanitize input to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .trim();
  }

  // Clean phone number (remove formatting)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleaned = cleanPhoneNumber(phone);
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    return phone; // Return original if can't format
  }

  // Validate and format currency
  static String? validateAndFormatCurrency(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Remove currency symbols and spaces
    final cleaned = value.replaceAll(RegExp(r'[\$,\s]'), '');
    final price = double.tryParse(cleaned);

    if (price == null) {
      return null;
    }

    return '\$${price.toStringAsFixed(2)}';
  }
}
