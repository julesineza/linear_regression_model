import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../utilis/input_validator.dart';
import '../widgets/health_indicator.dart';
import '../widgets/prediction_display.dart';
import '../data/crop_options.dart';
import '../widgets/hybrid_dropdown_field.dart';

void main() {
  runApp(const YieldPredictor());
}

class YieldPredictor extends StatelessWidget {
  const YieldPredictor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yield Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const PredictorScreen(),
    );
  }
}


class PredictorScreen extends StatefulWidget {
  const PredictorScreen({Key? key}) : super(key: key);

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final _countryController = TextEditingController();
  final _productController = TextEditingController();
  final _seasonController = TextEditingController();
  final _systemController = TextEditingController();
  final _areaController = TextEditingController();
  final _yearController = TextEditingController();
  final _plantingMonthController = TextEditingController();
  final _harvestMonthController = TextEditingController();

  bool? _isApiOnline;
  bool _isLoading = false;
  String _displayMessage = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _productController.dispose();
    _seasonController.dispose();
    _systemController.dispose();
    _areaController.dispose();
    _yearController.dispose();
    _plantingMonthController.dispose();
    _harvestMonthController.dispose();
    super.dispose();
  }

  Future<void> _checkApiHealth() async {
    setState(() => _isApiOnline = null);
    final isOnline = await ApiService.checkHealth();
    if (mounted) {
      setState(() => _isApiOnline = isOnline);
    }
  }

  Future<void> _handlePredict() async {
    final ValidatedCropInput validInput;
    try {
      validInput = InputValidator.validate(
        country: _countryController.text,
        product: _productController.text,
        seasonName: _seasonController.text,
        productionSystem: _systemController.text,
        areaText: _areaController.text,
        yearText: _yearController.text,
        plantingMonthText: _plantingMonthController.text,
        harvestMonthText: _harvestMonthController.text,
      );
    } on FormatException catch (e) {
      setState(() {
        _isError = true;
        _displayMessage = e.message;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isError = false;
      _displayMessage = 'Requesting prediction from server...';
    });

    try {
      final result = await ApiService.predictYield(
        country: validInput.country,
        product: validInput.product,
        seasonName: validInput.seasonName,
        productionSystem: validInput.productionSystem,
        area: validInput.area,
        plantingYear: validInput.plantingYear,
        plantingMonth: validInput.plantingMonth,
        harvestMonth: validInput.harvestMonth,
      );

      if (mounted) {
        setState(() {
          _isApiOnline = true;
          _isError = false;
          _displayMessage =
              'Predicted Yield for ${validInput.product} in ${validInput.country}:\n$result tonnes per hectare';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _displayMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool decimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yield Predictor'),
        centerTitle: true,
        actions: [
          Center(
            child: HealthIndicator(
              isApiOnline: _isApiOnline,
              onTap: _checkApiHealth,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Welcome to the Yield Predictor App!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Hybrid Dropdown + Text Inputs
                HybridDropdownField(
                  controller: _countryController,
                  options: CropOptions.countries,
                  label: 'Country',
                  hint: 'Select or type country e.g. Rwanda',
                  icon: Icons.flag,
                ),
                HybridDropdownField(
                  controller: _productController,
                  options: CropOptions.products,
                  label: 'Product',
                  hint: 'Select or type product e.g. Maize, Rice',
                  icon: Icons.agriculture,
                ),
                HybridDropdownField(
                  controller: _seasonController,
                  options: CropOptions.seasonNames,
                  label: 'Season Name',
                  hint: 'Select or type season e.g. Main, Season A',
                  icon: Icons.calendar_today,
                ),
                HybridDropdownField(
                  controller: _systemController,
                  options: CropOptions.productionSystems,
                  label: 'Crop Production System',
                  hint: 'Select or type system e.g. All (PS)',
                  icon: Icons.settings_suggest,
                ),

                // Numeric Inputs
                _buildNumberField(
                  controller: _areaController,
                  label: 'Area',
                  hint: 'Enter the area planted in hectares e.g. 4.0',
                  icon: Icons.area_chart,
                  decimal: true,
                ),
                _buildNumberField(
                  controller: _yearController,
                  label: 'Planting Year',
                  hint: 'Enter the planting year e.g. 2023',
                  icon: Icons.calendar_today,
                ),
                _buildNumberField(
                  controller: _plantingMonthController,
                  label: 'Planting Month',
                  hint: 'Enter the planting month e.g. 1 for January',
                  icon: Icons.calendar_today,
                ),
                _buildNumberField(
                  controller: _harvestMonthController,
                  label: 'Harvest Month',
                  hint: 'Enter the harvest month e.g. 10',
                  icon: Icons.calendar_today,
                ),

                const SizedBox(height: 4),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePredict,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Predict', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
                PredictionDisplay(
                  message: _displayMessage,
                  isError: _isError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}