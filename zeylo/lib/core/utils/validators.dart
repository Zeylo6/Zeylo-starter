/// Validators for form inputs across the Zeylo application
class Validators {
  /// Validates email format using regex
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  /// Requirements: min 8 chars, uppercase, lowercase, number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates full name
  /// Requirements: min 2 chars, letters and spaces only
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    const nameRegex = r"^[a-zA-Z\s'.-]+$";
    if (!RegExp(nameRegex).hasMatch(value)) {
      return "Name can only contain letters, spaces, apostrophes, hyphens, and periods";
    }

    return null;
  }

  /// Validates phone numbers in a generic international-friendly way.
  /// Accepts 10-digit local numbers and international numbers up to 15 digits.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Phone number must be between 10 and 15 digits';
    }

    return null;
  }

  /// Validates that a field is not empty
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates credit card number using Luhn algorithm
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return 'Card number must be between 13 and 19 digits';
    }

    if (!_luhnCheck(digitsOnly)) {
      return 'Please enter a valid card number';
    }

    return null;
  }

  /// Luhn algorithm for credit card validation
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    int isEven = 0;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (isEven == 1) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven ^= 1;
    }

    return sum % 10 == 0;
  }

  /// Validates card expiry date in MM/YY format
  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    if (!value.contains('/')) {
      return 'Expiry date must be in MM/YY format';
    }

    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Expiry date must be in MM/YY format';
    }

    try {
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);

      if (month < 1 || month > 12) {
        return 'Month must be between 01 and 12';
      }

      // Check if card is expired (simple check)
      final now = DateTime.now();
      final currentYear = now.year % 100;
      final currentMonth = now.month;

      if (year < currentYear || (year == currentYear && month < currentMonth)) {
        return 'Card has expired';
      }
    } catch (e) {
      return 'Please enter a valid expiry date';
    }

    return null;
  }

  /// Validates card CVC (3-4 digits)
  static String? validateCVC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVC is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 3 || digitsOnly.length > 4) {
      return 'CVC must be 3 or 4 digits';
    }

    return null;
  }

  /// Validates budget range (min < max)
  static String? validateBudgetRange(String? minValue, String? maxValue) {
    if (minValue == null || minValue.isEmpty) {
      return 'Minimum budget is required';
    }

    if (maxValue == null || maxValue.isEmpty) {
      return 'Maximum budget is required';
    }

    try {
      final min = double.parse(minValue);
      final max = double.parse(maxValue);

      if (min < 0 || max < 0) {
        return 'Budget must be a positive number';
      }

      if (min >= max) {
        return 'Minimum budget must be less than maximum budget';
      }
    } catch (e) {
      return 'Please enter valid numbers';
    }

    return null;
  }
}
