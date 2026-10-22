import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor_restaurant/api/api_client.dart';
import 'package:stackfood_multivendor_restaurant/features/language/domain/repositories/language_repository_interface.dart';
import 'package:stackfood_multivendor_restaurant/util/app_constants.dart';

class LanguageRepository implements LanguageRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  LanguageRepository({required this.apiClient, required this.sharedPreferences});

  @override
  void updateHeader(Locale locale){
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      locale.languageCode,
      sharedPreferences.getString(AppConstants.type),
    );
  }

  @override
  Locale getLocaleFromSharedPref() {
    return _supportedLocale(
      sharedPreferences.getString(AppConstants.languageCode),
      sharedPreferences.getString(AppConstants.countryCode),
    );
  }

  @override
  void saveLanguage(Locale locale) {
    sharedPreferences.setString(AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.countryCode, locale.countryCode!);
  }

  @override
  void saveCacheLanguage(Locale locale) {
    sharedPreferences.setString(AppConstants.cacheLanguageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.cacheCountryCode, locale.countryCode!);
  }

  @override
  Locale getCacheLocaleFromSharedPref() {
    return _supportedLocale(
      sharedPreferences.getString(AppConstants.cacheLanguageCode),
      sharedPreferences.getString(AppConstants.cacheCountryCode),
    );
  }

  Locale _supportedLocale(String? languageCode, String? countryCode) {
    final bool supported = AppConstants.languages.any((language) => language.languageCode == languageCode);
    if (languageCode == null || !supported) {
      return Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode);
    }
    return Locale(languageCode, countryCode ?? AppConstants.languages[0].countryCode);
  }


  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete({int? id}) {
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}