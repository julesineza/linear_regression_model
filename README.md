# Crop Yield Prediction

> A machine-learning project that predicts crop yield across Sub-Saharan Africa through a hosted API and Flutter mobile application.

## Mission, Problem, and Solution

**Mission:** Improve food security across Sub-Saharan Africa by using my software engineering skills to build prediction tools that help agricultural decision makers plan better.
**Problem:** Sub-Saharan Africa faces high food insecurity and a scarcity of reliable agricultural data, so planners often lack a quick estimate of how productive a crop will be before the season.
**Solution:** This project predicts crop yield (tonnes per hectare) from the country, crop, season, production system, planted area and planting/harvest timing, and serves it through an API and a mobile app for extension officers and food-security planners.

## Quick Links

- [Swagger API documentation](https://linear-regression-model-w79d.onrender.com/docs)
- [Video demonstration](https://youtu.be/tYfdmQTcb1E)
- [Flutter mobile application](summative/FlutterApp)
- [Prediction API](summative/API)

## Dataset

**HarvestStat Africa** is an open-access collection of harmonized subnational crop statistics for Sub-Saharan Africa. It is built from agricultural statistics collected by USAID's Famine Early Warning Systems Network (FEWS NET), which were standardized and calibrated across changing administrative boundaries. The paper describes 574,204 records, mainly from 1980 to 2022, covering 33 countries and 94 crop types, with quantity produced, harvested area and yield.

The file I used (`hvstat_africa_data_v1_2.csv`) has 217,487 rows and 16 columns: country, regions (`admin_1`, `admin_2`), crop product, season, planting and harvest dates, production system, area (ha), production (t), yield (t/ha) and a quality-control flag. I predict **yield**, and after cleaning I kept 198,872 rows and 8 input features (4 categorical and 4 numeric).

> [!IMPORTANT]
> Some countries were dropped because they had no yield data. Predictions for these countries may be inaccurate or unavailable with this dataset:
>
> | Country | Share of yield missing |
> | --- | ---: |
> | Guinea | 100% |
> | Sierra Leone | 91% |
> | Burundi | 78% |
> | DRC | 67% |

- Paper: https://www.nature.com/articles/s41597-025-05001-z
- Data: https://datadryad.org/dataset/doi:10.5061/dryad.vq83bk42w
- Direct link to data with automatic download - https://datadryad.org/downloads/file_stream/4864223

## Hosted API

https://linear-regression-model-w79d.onrender.com/docs
 
## Video Demo

https://youtu.be/tYfdmQTcb1E

## Running the Mobile Application

The mobile application is located in the summative/FlutterApp directory. The app can use the hosted prediction API, so the backend does not need to be started for a normal run. Or you can also run the API locally with uv.

### Requirements

You need the following tools:

- Git
- Flutter SDK with the Dart SDK included
- A supported mobile target such as Android Studio, an Android emulator, an iOS simulator, or a physical device
- uv if you want to run the prediction API locally
- Python 3.13 or newer if you want to run the prediction API locally

> [!NOTE]
> On macOS, Xcode is required for iOS or macOS builds. Android Studio and the Android SDK are required for Android builds.

### Step 1: Get the project

Open a terminal and move into the project directory:

```bash
cd "/path/to/linear_regression_model"
```

Verify that the Flutter application directory exists:

```bash
ls summative/FlutterApp
```

### Step 2: Install and verify Flutter

Install Flutter by following the official Flutter installation instructions for your operating system:

https://docs.flutter.dev/get-started/install

Open a new terminal and verify the installation:

```bash
flutter --version
flutter doctor
```

Resolve any errors reported for Android or iOS before continuing. You can also run flutter doctor -v for more detailed information.

For Android, enable USB debugging on a physical device or create an Android emulator from Android Studio. For iOS, open Xcode and accept the required licenses and component downloads, then start a simulator.

### Step 3: Open the Flutter application directory

```bash
cd summative/FlutterApp
```

### Step 4: Download Flutter dependencies

```bash
flutter pub get
```

This reads pubspec.yaml and downloads packages used by the app.

### Step 5: Check available devices

```bash
flutter devices
```

For a physical device, connect it with a USB cable and confirm that it appears in this list. For an emulator or simulator, start it first and then run flutter devices again.

### Step 6: Run the application

Start the app on the selected device:

```bash
flutter run
```

If multiple devices are available, choose the required device from the terminal prompt. You can also select a device directly:

```bash
flutter run -d DEVICE_ID
```

Replace DEVICE_ID with an identifier from flutter devices.

The app connects by default to:

`https://linear-regression-model-w79d.onrender.com`

> [!WARNING]
> The application needs a network connection to make predictions. The hosted service may take approximately 90 seconds to respond after it has been inactive.

### Using the Application

1. Wait for the API status indicator in the app bar to confirm that the API is available.
2. Select or type a country.
3. Select or type a crop product.
4. Select or type a season name.
5. Select or type a crop production system.
6. Enter the planted area in hectares.
7. Enter the planting year.
8. Enter the planting month as a number from 1 to 12.
9. Enter the harvest month as a number from 1 to 12.
10. Tap Predict.
11. Read the predicted crop yield in tonnes per hectare.

The country, crop, season, and production system must correspond to categories accepted by the model. The app provides common options, and custom values are validated through the API.

### Running with Hot Reload

While `flutter run` is active, press `r` in the terminal to hot reload the app. Press `R` to hot restart it. Press `q` to stop the app.

### Running on Specific Platforms

#### Android

Start an Android emulator or connect a physical device:

```bash
flutter run -d android
```

#### Web

```bash
flutter run -d chrome
```

#### macOS

```bash
flutter run -d macos
```

#### iOS

Start an iOS simulator or connect a physical device:

```bash
flutter run -d ios
```

The iOS simulator and macOS application require macOS and the Apple development tools.

## Running the Prediction API Locally with uv

The API source is in the summative/API directory. It uses a uv-managed Python environment and a saved machine-learning model.

### Step 1: Move to the API directory

From the repository root:

```bash
cd summative/API
```

### Step 2: Install uv

If uv is not installed, install it using the official installation instructions:

https://docs.astral.sh/uv/getting-started/installation/

Verify the installation:

```bash
uv --version
```

### Step 3: Install the API dependencies

Return to the summative directory, because that directory contains the main uv project file:

```bash
cd ..
uv sync
```

This creates or updates the .venv environment and installs the dependencies listed in pyproject.toml and uv.lock.

> [!NOTE]
> Python 3.13 or newer is required. uv can normally install the required Python version automatically:

```bash
uv python install 3.13
```

### Step 4: Start the API

```bash
cd API
uv run uvicorn prediction:app --host 0.0.0.0 --port 8000 --reload
```

Keep this terminal open. The API should be available at:

`http://127.0.0.1:8000`

The interactive Swagger documentation should be available at:

`http://127.0.0.1:8000/docs`

You can verify the health endpoint from another terminal:

```bash
curl http://127.0.0.1:8000/
```

A successful response contains a message stating that the Crop Yield Prediction API is running.

### Step 5: Configure the Flutter app for the local API

Open the file:

`summative/FlutterApp/lib/services/api_services.dart`

Change the baseUrl value to match the device or emulator environment:

#### Local API base URLs

**Web browser, macOS application, or iOS simulator:**

```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```

**Android emulator:**

```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**Physical Android or iOS device:**

> [!IMPORTANT]
> Replace `127.0.0.1` or `10.0.2.2` with the computer's LAN IP address. The phone and computer must be connected to the same network.
>
> ```dart
static const String baseUrl = 'http://YOUR_COMPUTER_LAN_IP:8000';
> ```

Find a LAN IP address on macOS with:

```bash
ipconfig getifaddr en0
```

Save the file and restart the Flutter app.

### Starting the API with plain uv

An alternative direct start command from the summative directory is:

```bash
uv run --directory API uvicorn prediction:app --host 0.0.0.0 --port 8000 --reload
```

### Useful uv Commands

Update the environment after pyproject.toml or uv.lock changes:

```bash
uv sync
```

Run a command in the project environment:

```bash
uv run COMMAND
```

Run the API directly from the summative directory:

```bash
uv run --directory API uvicorn prediction:app --host 0.0.0.0 --port 8000 --reload
```

Export production requirements:

```bash
uv export --format requirements.txt --no-hashes --no-dev -o API/requirements.txt
```


