import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_drug_registry/constants.dart';
import 'package:flutter_drug_registry/core/services/shared_preferences_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewPromptCubit extends Cubit<ReviewPromptState> {
  ReviewPromptCubit(this._sharedPreferencesService)
    : super(const ReviewPromptState());

  static const _minimumDistinctDetailViewDays = 3;

  final SharedPreferencesService _sharedPreferencesService;

  void refresh() {
    emit(ReviewPromptState(shouldShow: _shouldShowPrompt()));
  }

  Future<void> recordDetailView() async {
    if (_sharedPreferencesService.getIsReviewPromptHandled()) return;

    await _sharedPreferencesService.registerReviewPromptDetailView(
      DateTime.now(),
    );
    refresh();
  }

  Future<void> dismiss() async {
    await _sharedPreferencesService.setIsReviewPromptHandled(true);
    refresh();
  }

  Future<void> openReview() async {
    await dismiss();

    final marketUri = Uri.parse(
      'market://details?id=${Constants.androidPackageId}',
    );
    final playStoreUri = Uri.parse(Constants.playStoreUrl);

    await _launchWithFallback(marketUri, playStoreUri);
  }

  Future<void> sendFeedback() async {
    await dismiss();

    final feedbackUri = Uri(
      scheme: 'mailto',
      path: Constants.contactEmail,
      query: _encodeQueryParameters({
        'subject': 'Фидбек за Регистар на лекови',
        'body': 'Здраво,\n\n',
      }),
    );

    await _launch(feedbackUri);
  }

  bool _shouldShowPrompt() {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isFirstTime = _sharedPreferencesService.getIsFirstTime() ?? true;
    final distinctDetailViewDays =
        _sharedPreferencesService.getReviewPromptDetailViewDates().length;

    return isAndroid &&
        !isFirstTime &&
        !_sharedPreferencesService.getIsReviewPromptHandled() &&
        distinctDetailViewDays >= _minimumDistinctDetailViewDays;
  }

  Future<void> _launchWithFallback(Uri primaryUri, Uri fallbackUri) async {
    try {
      final didLaunchPrimary = await launchUrl(
        primaryUri,
        mode: LaunchMode.externalApplication,
      );

      if (didLaunchPrimary) return;
    } catch (_) {
      // Fall back to the web listing when the Play Store app is unavailable.
    }

    await _launch(fallbackUri);
  }

  Future<void> _launch(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // The prompt is already handled; a missing external app should not crash.
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }
}

class ReviewPromptState extends Equatable {
  const ReviewPromptState({this.shouldShow = false});

  final bool shouldShow;

  @override
  List<Object> get props => [shouldShow];
}
