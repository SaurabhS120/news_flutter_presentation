import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_flutter/home_page.dart';
import 'package:news_flutter_domain/errors/base_error.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:news_flutter_domain/repo/news_repo.dart';
import 'package:news_flutter_domain/usecase/get_news_usecase.dart';

import 'home_page_test.mocks.dart';

// Annotation which generates the cat.mocks.dart library and the MockCat class.
@GenerateNiceMocks([MockSpec<NewsRepo>()])
void main() async {
  NewsRepo newsRepo = MockNewsRepo();
  Either<List<NewsModel>, BaseError> dummyResponse = const Left([]);
  provideDummy(dummyResponse);
  GetNewsUseCase getNewsUseCase = GetNewsUseCase(newsRepo);

  test("News repo test", () async {
    when(newsRepo.getNews()).thenAnswer((_) => Future(() => dummyResponse));
    newsRepo.getNews();
    verify(newsRepo.getNews()).called(1);
  });

  test("News use case test", () async {
    Either<List<NewsModel>, BaseError> response =
        await getNewsUseCase.execute(GetNewsUseCaseParams());
    expect(response.isLeft, isTrue);
  });

  test("Homepage View model fetch news on load", () async {
    clearInteractions(newsRepo);
    HomePageViewModel(getNewsUseCase);
    verify(newsRepo.getNews()).called(1);
  });
}
