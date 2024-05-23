import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:news_flutter/news_details_page.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:mockito/mockito.dart';

void main(){
  const String imageUrl = 'https://scx2.b-cdn.net/gfx/news/hires/2024/ev-maker-tesla-breaks.jpg';
  group("News details page tests", () {
    test("NewsDetailsPageViewModel initializes with correct arguments", () {
      var newsModel = NewsModel(imageUrl: imageUrl, title: 'title');
      var viewModel = NewsDetailsPageViewModel(arguments: NewsDetailsPageArgs(news: newsModel));
      expect(viewModel.arguments.news, equals(newsModel));
    });

    testWidgets("NewsDetailsPageView displays news details correctly", (WidgetTester tester) async {
      var newsModel = NewsModel(imageUrl: imageUrl, title: 'title');
      var viewModel = NewsDetailsPageViewModel(arguments: NewsDetailsPageArgs(news: newsModel));

      await tester.pumpWidget(MaterialApp(
        home: NewsDetailsPageView(model: viewModel),
      ));

      expect(find.text('title'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets("NewsDetailsPageView does not display image when imageUrl is empty", (WidgetTester tester) async {
      var newsModel = NewsModel(imageUrl: '', title: 'title');
      var viewModel = NewsDetailsPageViewModel(arguments: NewsDetailsPageArgs(news: newsModel));

      await tester.pumpWidget(MaterialApp(
        home: NewsDetailsPageView(model: viewModel),
      ));

      expect(find.text('title'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}