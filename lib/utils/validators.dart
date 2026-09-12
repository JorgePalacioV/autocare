class Validators {
  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'El nombre es requerido';
    }
    if (value!.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    if (value!.length < 7) {
      return 'Teléfono inválido';
    }
    return null;
  }

  static String? validatePlate(String? value) {
    if (value?.isEmpty ?? true) {
      return 'La placa es requerida';
    }
    if (value!.length < 3) {
      return 'La placa debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateYear(String? value) {
    if (value?.isEmpty ?? true) {
      return 'El año es requerido';
    }
    final year = int.tryParse(value!);
    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
      return 'Año inválido';
    }
    return null;
  }

  static String? validateKm(String? value) {
    if (value?.isEmpty ?? true) {
      return 'El kilometraje es requerido';
    }
    final km = int.tryParse(value!);
    if (km == null || km < 0) {
      return 'Kilometraje inválido';
    }
    return null;
  }

  static String? validateCost(String? value) {
    if (value?.isEmpty ?? true) {
      return 'El costo es requerido';
    }
    final cost = double.tryParse(value!);
    if (cost == null || cost < 0) {
      return 'Costo inválido';
    }
    return null;
  }

  static String? validateLicense(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    if (value!.length < 5) {
      return 'Número de licencia inválido';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return '$fieldName es requerido';
    }
    return null;
  }
}
