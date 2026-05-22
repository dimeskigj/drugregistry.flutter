import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'theme';
const _savedDrugsKey = 'saved-drugs';
const _savedPharmaciesKey = 'saved-pharmacies';
const _isFirstTimeKey = 'is-first-time';
const _recentPharmacySearchesKey = 'recent-pharmacy-searches';
const _recentDrugSearchesKey = 'recent-drug-searches';
const _reviewPromptHandledKey = 'review-prompt-handled';
const _reviewPromptDetailViewCountKey = 'review-prompt-detail-view-count';
const _reviewPromptDetailViewDatesKey = 'review-prompt-detail-view-dates';

class SharedPreferencesService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool? getIsLightTheme() => _prefs.getBool(_themeKey);

  Future<bool> setIsLightTheme(bool value) async =>
      await _prefs.setBool(_themeKey, value);

  List<String>? getSavedDrugsIds() => _prefs.getStringList(_savedDrugsKey);

  Future<bool> setSavedDrugsIds(List<String> value) =>
      _prefs.setStringList(_savedDrugsKey, value);

  List<String>? getSavedPharmaciesIds() =>
      _prefs.getStringList(_savedPharmaciesKey);

  Future<bool> setSavedPharmaciesIds(List<String> value) =>
      _prefs.setStringList(_savedPharmaciesKey, value);

  bool? getIsFirstTime() => _prefs.getBool(_isFirstTimeKey);

  Future<bool> setIsFirstTime(bool value) async =>
      await _prefs.setBool(_isFirstTimeKey, value);

  List<String>? getRecentPharmacySearches() =>
      _prefs.getStringList(_recentPharmacySearchesKey);

  Future<bool> setRecentPharmacySearches(List<String> value) =>
      _prefs.setStringList(_recentPharmacySearchesKey, value);

  List<String>? getRecentDrugSearches() =>
      _prefs.getStringList(_recentDrugSearchesKey);

  Future<bool> setRecentDrugSearches(List<String> value) =>
      _prefs.setStringList(_recentDrugSearchesKey, value);

  bool getIsReviewPromptHandled() =>
      _prefs.getBool(_reviewPromptHandledKey) ?? false;

  Future<bool> setIsReviewPromptHandled(bool value) =>
      _prefs.setBool(_reviewPromptHandledKey, value);

  int getReviewPromptDetailViewCount() =>
      _prefs.getInt(_reviewPromptDetailViewCountKey) ?? 0;

  List<String> getReviewPromptDetailViewDates() =>
      _prefs.getStringList(_reviewPromptDetailViewDatesKey) ?? [];

  Future<void> registerReviewPromptDetailView(DateTime viewedAt) async {
    final viewedDate = _dateKey(viewedAt);
    final viewedDates =
        getReviewPromptDetailViewDates().toSet()..add(viewedDate);
    final sortedViewedDates = viewedDates.toList()..sort();

    await Future.wait([
      _prefs.setInt(
        _reviewPromptDetailViewCountKey,
        getReviewPromptDetailViewCount() + 1,
      ),
      _prefs.setStringList(_reviewPromptDetailViewDatesKey, sortedViewedDates),
    ]);
  }

  String _dateKey(DateTime value) {
    final localValue = value.toLocal();
    final year = localValue.year.toString().padLeft(4, '0');
    final month = localValue.month.toString().padLeft(2, '0');
    final day = localValue.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
