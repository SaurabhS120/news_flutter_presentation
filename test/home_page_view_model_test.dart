import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_flutter/home_page_view_model.dart';
import 'package:news_flutter_domain/errors/base_error.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:news_flutter_domain/usecase/get_news_usecase.dart';

import 'home_page_test.mocks.dart';

void main(){
  group("HomePage viewmodel tests", () {
    late MockGetNewsUseCase getNewsUseCase;
    late HomePageViewModel homePageViewModel;
    setUp(() {
      // Additional setup code
      getNewsUseCase = MockGetNewsUseCase();
      provideDummy<Either<List<NewsModel>, BaseError>>(const Left([]));
      when(getNewsUseCase.execute(any)).thenAnswer((_) async => Left<List<NewsModel>, BaseError>([]));
      homePageViewModel = HomePageViewModel(getNewsUseCase);
    });

    test("HomePageViewModel news list on create ", () {
      verify(getNewsUseCase.execute(any)).called(1);
    });

    test("Test 2", () {
      // Test 2 code
    });
    test("HomePageViewModel fetches news list successfully", () async {
      when(getNewsUseCase.execute(any)).thenAnswer((_) async => Left<List<NewsModel>, BaseError>([]));
      homePageViewModel.getNewsList();
      verify(getNewsUseCase.execute(any)).called(2);
    });

    test("HomePageViewModel propagates news list to stream", () async {
      var newsList = [NewsModel(imageUrl: 'url1', title: 'title1'), NewsModel(imageUrl: 'url2', title: 'title2')];
      when(getNewsUseCase.execute(any)).thenAnswer((_) async => Left<List<NewsModel>, BaseError>(newsList));
      homePageViewModel.getNewsList();
      expectLater(homePageViewModel.news_list_stream, emitsInOrder([Left<List<NewsModel>, BaseError>(newsList)]));
    });

    test("HomePageViewModel propagates error to stream when fetching news list fails", () async {
      var error = BaseError();
      when(getNewsUseCase.execute(any)).thenAnswer((_) async => Right<List<NewsModel>, BaseError>(error));
      homePageViewModel.getNewsList();
      expectLater(homePageViewModel.news_list_stream, emitsInOrder([Right<List<NewsModel>, BaseError>(error)]));
    });

  });
}