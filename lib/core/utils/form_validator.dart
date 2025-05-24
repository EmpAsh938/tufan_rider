class FormValidator {
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? value, String originalPassword) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Firstname is required';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lastname is required';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
    }

    try {
      final dob = DateTime.parse(value);
      final now = DateTime.now();

      if (dob.isAfter(now)) {
        return 'Date of Birth cannot be in the future';
      }

      if (dob.isBefore(DateTime(1900))) {
        return 'Date of Birth cannot be before 1900';
      }

      return null;
    } catch (e) {
      return 'Invalid Date of Birth format';
    }
  }

  static String? validateLicense(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }

    // Remove any dashes or spaces for validation
    final cleanedValue = value.replaceAll(RegExp(r'[-\s]'), '');

    // Accept either:
    // 1. Traditional format: 000-00000-0000 (which becomes 11 digits when cleaned)
    // 2. Plain 11-digit number
    if (cleanedValue.length != 12 ||
        !RegExp(r'^[0-9]{12}$').hasMatch(cleanedValue)) {
      return 'Enter 12 digits or format: 00-00-00000000';
    }

    return null;
  }

  // 2. Plain 11-digit number

  static String? validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'National ID number is required';
    }

    // Remove any dashes or spaces for validation
    final cleanedValue = value.replaceAll(RegExp(r'[-\s]'), '');

    // Accept either:
    // 1. Traditional format: 000-000-000-0 (which becomes 10 digits when cleaned)
    // 2. Plain 11-digit number
    if (cleanedValue.length == 10 &&
        RegExp(r'^[0-9]{10}$').hasMatch(cleanedValue)) {
      return null; // Valid 10-digit format (with dashes)
    }
    return 'Enter 10 digits or format: 000-000-000-0';
  }

  static String? validateCitizenship(String? value) {
    if (value == null || value.isEmpty) {
      return 'Citizenship number is required';
    }

    // Remove any dashes or spaces for validation
    final cleanedValue = value.replaceAll(RegExp(r'[-\s]'), '');

    // Check if it's digits only and greater than 4 digits
    if (!RegExp(r'^\d+$').hasMatch(cleanedValue) || cleanedValue.length <= 4) {
      return 'Enter a valid citizenship number with more than 4 digits';
    }

    return null;
  }

  static String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  }
}
