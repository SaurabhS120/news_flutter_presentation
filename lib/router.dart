import 'package:flutter/material.dart';
import 'package:news_flutter/home_page.dart';
import 'package:news_flutter/news_details_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutePaths.home:
        return _createMaterialPageRoute(settings: settings, child: HomePage());
      case AppRoutePaths.newsDetails:
        return _createMaterialPageRoute(
            settings: settings,
            child: NewsDetailsPage(
                args: settings.arguments as NewsDetailsPageArgs));
    }
    return null;
  }

  static MaterialPageRoute _createMaterialPageRoute(
      {required RouteSettings settings, required Widget child}) {
    return MaterialPageRoute(builder: (BuildContext context) {
      return child;
    });
  }
}

class AppRoutePaths {
  static const String home = "/Home";
  static const String newsDetails = "/NewsDetails";
}
