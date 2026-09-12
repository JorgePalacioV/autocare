import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Map<String, String> _translations = {};
  late String _locale;

  AppLocalizations(String locale) {
    _locale = locale;
  }

  static AppLocalizations of(String locale) {
    return AppLocalizations(locale);
  }

  Future<bool> load() async {
    try {
      final String jsonString =
          await rootBundle.loadString('lib/l10n/app_$_locale.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _translations.addAll(jsonMap.cast<String, String>());
      return true;
    } catch (e) {
      print('Error loading translations: $e');
      return false;
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String value = _translations[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }

    return value;
  }

  String get appName => translate('appName');
  String get appTitle => translate('appTitle');

  // Auth
  String get authEmail => translate('auth_email');
  String get authPassword => translate('auth_password');
  String get authDisplayName => translate('auth_displayName');
  String get authSignUp => translate('auth_signUp');
  String get authSignIn => translate('auth_signIn');
  String get authSignOut => translate('auth_signOut');
  String get authConfirmSignOut => translate('auth_confirmSignOut');
  String get authCancel => translate('auth_cancel');
  String get authErrorInvalidEmail => translate('auth_errorInvalidEmail');
  String get authErrorWeakPassword => translate('auth_errorWeakPassword');
  String get authErrorUserExists => translate('auth_errorUserExists');

  // Home
  String homeWelcome(String name) =>
      translate('home_welcome', params: {'name': name});
  String get homeSummary => translate('home_summary');
  String get homeQuickActions => translate('home_quickActions');
  String get homeViewVehicles => translate('home_viewVehicles');
  String get homeAddVehicle => translate('home_addVehicle');
  String get homeConfigureAlerts => translate('home_configureAlerts');
  String get homeGenerateReports => translate('home_generateReports');
  String get homeProfileInfo => translate('home_profileInfo');

  // Vehicles
  String get vehiclesTitle => translate('vehicles_title');
  String get vehiclesSearch => translate('vehicles_search');
  String get vehiclesEmpty => translate('vehicles_empty');
  String get vehiclesEmptySubtitle => translate('vehicles_emptySubtitle');
  String get vehiclesNoResults => translate('vehicles_noResults');
  String get vehiclesNoResultsSubtitle =>
      translate('vehicles_noResultsSubtitle');
  String get vehiclesAdd => translate('vehicles_add');
  String get vehiclesEdit => translate('vehicles_edit');
  String get vehiclesDelete => translate('vehicles_delete');
  String vehiclesConfirmDelete(String vehicle) =>
      translate('vehicles_confirmDelete', params: {'vehicle': vehicle});
  String get vehiclesDeleted => translate('vehicles_deleted');
  String get vehiclesBrand => translate('vehicles_brand');
  String get vehiclesModel => translate('vehicles_model');
  String get vehiclesPlate => translate('vehicles_plate');
  String get vehiclesYear => translate('vehicles_year');
  String get vehiclesKm => translate('vehicles_km');
  String get vehiclesPhoto => translate('vehicles_photo');
  String get vehiclesNoDriver => translate('vehicles_noDriver');
  String vehiclesDriverAssigned(String name) =>
      translate('vehicles_driverAssigned', params: {'name': name});

  // Maintenance
  String get maintenanceTitle => translate('maintenance_title');
  String get maintenanceRegister => translate('maintenance_register');
  String get maintenanceHistory => translate('maintenance_history');
  String get maintenanceSchedule => translate('maintenance_schedule');
  String get maintenanceType => translate('maintenance_type');
  String get maintenanceDate => translate('maintenance_date');
  String get maintenanceKm => translate('maintenance_km');
  String get maintenanceCost => translate('maintenance_cost');
  String get maintenanceWorkshop => translate('maintenance_workshop');
  String get maintenanceNotes => translate('maintenance_notes');
  String get maintenanceEmpty => translate('maintenance_empty');
  String get maintenanceRecorded => translate('maintenance_recorded');
  String get maintenanceUpdated => translate('maintenance_updated');
  String get maintenanceDeleted => translate('maintenance_deleted');
  String get maintenanceStatistics => translate('maintenance_statistics');
  String get maintenanceTotalCount => translate('maintenance_totalCount');
  String get maintenanceAverageCost => translate('maintenance_averageCost');
  String get maintenanceMostExpensive =>
      translate('maintenance_mostExpensive');
  String get maintenanceLeastExpensive =>
      translate('maintenance_leastExpensive');
  String get maintenanceFilterByType => translate('maintenance_filterByType');

  // Drivers
  String get driversTitle => translate('drivers_title');
  String get driversAdd => translate('drivers_add');
  String get driversEmpty => translate('drivers_empty');
  String get driversEmptySubtitle => translate('drivers_emptySubtitle');
  String get driversName => translate('drivers_name');
  String get driversPhone => translate('drivers_phone');
  String get driversEmail => translate('drivers_email');
  String get driversLicense => translate('drivers_license');
  String get driversLicenseExpiry => translate('drivers_licenseExpiry');
  String get driversPhoto => translate('drivers_photo');
  String get driversLicensePhoto => translate('drivers_licensePhoto');
  String get driversLicenseExpired => translate('drivers_licenseExpired');
  String get driversLicenseValid => translate('drivers_licenseValid');
  String get driversEdit => translate('drivers_edit');
  String get driversDelete => translate('drivers_delete');
  String get driversConfirmDelete => translate('drivers_confirmDelete');
  String get driversDeleted => translate('drivers_deleted');
  String get driversAddedSuccessfully =>
      translate('drivers_addedSuccessfully');

  // Profile
  String get profileTitle => translate('profile_title');
  String get profileName => translate('profile_name');
  String get profileEmail => translate('profile_email');
  String get profilePhone => translate('profile_phone');
  String get profileMemberSince => translate('profile_memberSince');
  String get profileUpdate => translate('profile_update');
  String get profileUpdated => translate('profile_updated');
  String get profileEdit => translate('profile_edit');

  // Reports
  String get reportsTitle => translate('reports_title');
  String get reportsGenerate => translate('reports_generate');
  String get reportsSelectVehicle => translate('reports_selectVehicle');
  String get reportsSelectVehicleHint =>
      translate('reports_selectVehicleHint');
  String get reportsTimePeriod => translate('reports_timePeriod');
  String get reportsFrom => translate('reports_from');
  String get reportsTo => translate('reports_to');
  String get reportsSelectDateHint => translate('reports_selectDateHint');
  String get reportsPdfTitle => translate('reports_pdfTitle');
  String get reportsSummary => translate('reports_summary');
  String get reportsTotalMaintenances =>
      translate('reports_totalMaintenances');
  String get reportsTotalCost => translate('reports_totalCost');
  String get reportsAverage => translate('reports_average');
  String get reportsHistory => translate('reports_history');
  String get reportsDate => translate('reports_date');
  String get reportsType => translate('reports_type');
  String get reportsNoRecords => translate('reports_noRecords');
  String get reportsGeneratedBy => translate('reports_generatedBy');
  String get reportsCompleteAllFields =>
      translate('reports_completeAllFields');
  String get reportsGeneratedSuccessfully =>
      translate('reports_generatedSuccessfully');

  // Stats
  String get statsTotalVehicles => translate('stats_totalVehicles');
  String get statsTotalMaintenances => translate('stats_totalMaintenances');
  String get statsTotalExpense => translate('stats_totalExpense');
  String get statsAverageExpense => translate('stats_averageExpense');
  String get statsLastMaintenance => translate('stats_lastMaintenance');
  String get statsAvgPerVehicle => translate('stats_avgPerVehicle');

  // Alerts
  String get alertsOk => translate('alerts_ok');
  String get alertsWarning => translate('alerts_warning');
  String get alertsOverdue => translate('alerts_overdue');
  String get alertsTitle => translate('alerts_title');
  String get alertsNoAlerts => translate('alerts_noAlerts');

  // Maintenance Types
  String get oil => translate('oil');
  String get airFilter => translate('airFilter');
  String get fuelFilter => translate('fuelFilter');
  String get brakes => translate('brakes');
  String get tires => translate('tires');
  String get alignment => translate('alignment');
  String get inspection => translate('inspection');
  String get antifreeze => translate('antifreeze');
  String get transmission => translate('transmission');
  String get suspension => translate('suspension');
  String get electrical => translate('electrical');
  String get bodywork => translate('bodywork');
  String get other => translate('other');

  // Common
  String get commonError => translate('common_error');
  String get commonErrorLoading => translate('common_errorLoading');
  String get commonRetry => translate('common_retry');
  String get commonLoading => translate('common_loading');
  String get commonRequired => translate('common_required');
  String get commonOptional => translate('common_optional');
  String get commonSave => translate('common_save');
  String get commonUpdate => translate('common_update');
  String get commonDelete => translate('common_delete');
  String get commonAdd => translate('common_add');
  String get commonClose => translate('common_close');
  String get commonSuccess => translate('common_success');
}
