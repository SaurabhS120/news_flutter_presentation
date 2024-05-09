import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_flutter/home_page.dart';
import 'package:news_flutter_data_newsapi/api_service.dart';
import 'package:news_flutter_data_newsapi/entity/news_response_entity.dart';
import 'package:news_flutter_domain/errors/base_error.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:news_flutter_domain/repo/news_repo.dart';
import 'package:news_flutter_domain/usecase/get_news_usecase.dart';

import 'home_page_test.mocks.dart';

/// This is the implementation of Repo in domain layer

// Annotation which generates the cat.mocks.dart library and the MockCat class.
@GenerateNiceMocks([MockSpec<NewsRepo>(), MockSpec<ApiService>(), MockSpec<GetNewsUseCase>()])
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

  group("News entity parse test", () {
    Map<String, dynamic> response = {
      "status": "ok",
      "totalResults": 9154,
      "articles": [
        {
          "source": {"id": null, "name": "CNBC"},
          "author": null,
          "title":
              "Chinese EV maker Nio to launch its lower-priced brand Onvo on May 15",
          "description":
              "Chinese electric car company Nio said Thursday it will launch its lower-priced brand called Onvo on May 15.",
          "url":
              "https://www.cnbc.com/2024/05/09/chinese-ev-maker-nio-to-launch-its-lower-priced-brand-onvo-on-may-15.html",
          "urlToImage": null,
          "publishedAt": "2024-05-09T02:51:49Z",
          "content":
              "BEIJING Chinese electric car company Nio said Thursday it will launch its lower-priced brand called Onvo on May 15.\r\nThe announcement comes amid a price war in China's highly competitive electric car… [+820 chars]"
        },
        {
          "source": {"id": "the-times-of-india", "name": "The Times of India"},
          "author": "Bloomberg",
          "title":
              "Elon Musk’s xAI nears funding at \$18 billion value soon as this week",
          "description":
              "The size of the round hasn’t been finalised, the people said, asking not to be identified as the information isn’t public. The maker of AI chatbot assistant Grok was set to raise \$6 billion in the round, whose participants include Sequoia Capital, Bloomberg N…",
          "url":
              "https://economictimes.indiatimes.com/tech/funding/elon-musks-xai-nears-funding-at-18-billion-value-soon-as-this-week/articleshow/109963893.cms",
          "urlToImage":
              "https://img.etimg.com/thumb/msid-109963888,width-1200,height-630,imgsize-93376,overlay-ettech/photo.jpg",
          "publishedAt": "2024-05-09T02:23:59Z",
          "content":
              "Elon Musks artificial intelligence startup X.AI Corp. is set to close its funding round at a valuation of about \$18 billion as soon as this week, according to people familiar with the matter.The size… [+1413 chars]"
        },
        {
          "source": {"id": null, "name": "Ducttapemarketing.com"},
          "author": "John Jantsch",
          "title":
              "How to Win The Consumer Boredom-Span: The Key to Cutting Through Clutter",
          "description":
              "How to Win The Consumer Boredom-Span: The Key to Cutting Through Clutter written by John Jantsch read more at Duct Tape Marketing\nThe Duct Tape Marketing Podcast with John Jantsch In this episode of the Duct Tape Marketing Podcast, I interviewed Alan Dibb. Th…",
          "url":
              "https://ducttapemarketing.com/win-consumer-boredom-span-lean-marketing/",
          "urlToImage":
              "https://i0.wp.com/ducttapemarketing.com/wp-content/uploads/2024/05/magnet-me-LDcC7aCWVlo-unsplash-scaled.jpg?fit=2558%2C1706&ssl=1",
          "publishedAt": "2024-05-09T01:53:50Z",
          "content":
              "Speaker 1 (00:00): I was like, I found it. I found it. This is what I've been looking for. I can honestly say it has genuinely changed the way I run my business. It's changed the results that I'm see… [+22550 chars]"
        },
      ],
    };
    NewsResponseEntity responseEntity = NewsResponseEntity.fromJson(response);
    String? expected = "";

    test("News title parsing test", () {
      expect(responseEntity.articles.first.title,
          "Chinese EV maker Nio to launch its lower-priced brand Onvo on May 15");
      expected = response['articles'][0]['title'];
      debugPrint("title : $expected");
      expect(responseEntity.articles.first.title, expected);
      expected = response['articles'][1]['title'];
      debugPrint("title : $expected");
      expect(responseEntity.articles[1].title, expected);
      expected = response['articles'][2]['title'];
      debugPrint("title : $expected");
      expect(responseEntity.articles[2].title, expected);
    });

    test("News image url parse test", () {
      expected = response['articles'][0]['urlToImage'];
      debugPrint("imageUrl : $expected");
      expect(responseEntity.articles[0].urlToImage, expected);

      expected = response['articles'][1]['urlToImage'];
      debugPrint("imageUrl : $expected");
      expect(responseEntity.articles[1].urlToImage,
          "https://img.etimg.com/thumb/msid-109963888,width-1200,height-630,imgsize-93376,overlay-ettech/photo.jpg");
      expect(responseEntity.articles[1].urlToImage, expected);

      expected = response['articles'][2]['urlToImage'];
      debugPrint("imageUrl : $expected");
      expect(responseEntity.articles[2].urlToImage, expected);
    });

    test("Api testing", () async {
      MockApiService apiService = MockApiService();

      when(apiService.everything(
        q: anyNamed('q'),
        from: anyNamed('from'),
        sortBy: anyNamed('sortBy'),
        apiKey: anyNamed('apiKey'),
      )).thenAnswer((realInvocation) => Future(() => responseEntity));
      NewsRepo newsRepo = NewsApiRepoImpl(apiKey: '', apiService: apiService);
      NewsResponseEntity? apiResponse = await apiService.everything(q: '', from: '', sortBy: '', apiKey: '');
      debugPrint(apiResponse.articles.first.title);
    });

    test("Get news use case mocking", () {
      MockGetNewsUseCase mockGetNewsUseCase = MockGetNewsUseCase();
      when(mockGetNewsUseCase.execute(any)).thenAnswer((realInvocation) => Future(() => const Left([])));
      mockGetNewsUseCase.execute(GetNewsUseCaseParams());
    });

    test("get news api should be called on app load", () {
      MockGetNewsUseCase mockGetNewsUseCase = MockGetNewsUseCase();
      HomePageViewModel(mockGetNewsUseCase);
      verify(mockGetNewsUseCase.execute(any)).called(1);
    });
  });
}

/// This will be the actual implementation which will be responsible for api or
/// database call in order to fetch data
class NewsApiRepoImpl implements NewsRepo {
  final String apiKey;

  NewsApiRepoImpl({required this.apiKey, required this.apiService});

  final ApiService apiService;

  // ApiService apiService = ApiService(Dio()..interceptors.add(PrettyDioLogger()), baseUrl: 'https://newsapi.org/v2');
  ///This is the implementation for function of domain layer repo
  /// This will be the actual implementation which will be responsible for api or
  /// database call in order to fetch data
  @override
  Future<Either<List<NewsModel>, BaseError>> getNews() async {
    DateTime dateTime = DateTime.now();
    String dd = dateTime.day.toString().padLeft(2, '0');
    String mm = (dateTime.month - 1).toString().padLeft(2, '0');
    String yyyy = dateTime.year.toString();
    final List<NewsModel> newsList = (await apiService.everything(q: 'tesla', from: '$yyyy-$mm-$dd', sortBy: 'publishedAt', apiKey: apiKey)).transform();
    return Left(newsList);
  }
}