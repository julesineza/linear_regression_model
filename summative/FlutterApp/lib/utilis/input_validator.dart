class ValidatedCropInput {
  final String country;
  final String product;
  final String seasonName;
  final String productionSystem;
  final double area;
  final int plantingYear;
  final int plantingMonth;
  final int harvestMonth;

  ValidatedCropInput({
    required this.country,
    required this.product,
    required this.seasonName,
    required this.productionSystem,
    required this.area,
    required this.plantingYear,
    required this.plantingMonth,
    required this.harvestMonth,
  });
}

class InputValidator {
  /// Validates raw text inputs. Returns a [ValidatedCropInput] if valid,
  /// or throws a [FormatException] with a user-friendly message if invalid.
  static ValidatedCropInput validate({
    required String country,
    required String product,
    required String seasonName,
    required String productionSystem,
    required String areaText,
    required String yearText,
    required String plantingMonthText,
    required String harvestMonthText,
  }) {
    // 1. Missing values
    if (country.trim().isEmpty ||
        product.trim().isEmpty ||
        seasonName.trim().isEmpty ||
        productionSystem.trim().isEmpty ||
        areaText.trim().isEmpty ||
        yearText.trim().isEmpty ||
        plantingMonthText.trim().isEmpty ||
        harvestMonthText.trim().isEmpty) {
      throw const FormatException(
        'Error: All fields are required. Please fill in any missing values.',
      );
    }

    // 2. Wrong types
    final double? area = double.tryParse(areaText.trim());
    if (area == null) {
      throw const FormatException(
        'Error: Area must be a valid decimal number (e.g., 4.0).',
      );
    }

    final int? year = int.tryParse(yearText.trim());
    if (year == null) {
      throw const FormatException(
        'Error: Planting Year must be a whole number (e.g., 2023).',
      );
    }

    final int? plantingMonth = int.tryParse(plantingMonthText.trim());
    if (plantingMonth == null) {
      throw const FormatException(
        'Error: Planting Month must be a whole number (1–12).',
      );
    }

    final int? harvestMonth = int.tryParse(harvestMonthText.trim());
    if (harvestMonth == null) {
      throw const FormatException(
        'Error: Harvest Month must be a whole number (1–12).',
      );
    }

    // 3. Out-of-range values
    if (area <= 0) {
      throw const FormatException('Error: Area must be greater than 0 hectares.');
    }
    if (year < 1960 || year > 2100) {
      throw const FormatException(
        'Error: Planting Year must be between 1960 and 2100.',
      );
    }
    if (plantingMonth < 1 || plantingMonth > 12) {
      throw const FormatException(
        'Error: Planting Month must be between 1 and 12.',
      );
    }
    if (harvestMonth < 1 || harvestMonth > 12) {
      throw const FormatException(
        'Error: Harvest Month must be between 1 and 12.',
      );
    }

    return ValidatedCropInput(
      country: country.trim(),
      product: product.trim(),
      seasonName: seasonName.trim(),
      productionSystem: productionSystem.trim(),
      area: area,
      plantingYear: year,
      plantingMonth: plantingMonth,
      harvestMonth: harvestMonth,
    );
  }
}