import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_flutter/home_page.dart';
import 'package:news_flutter_data_newsapi/entity/news_response_entity.dart';
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

  test("News entity parse test", () {
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
      ],
    };
    NewsResponseEntity responseEntity = NewsResponseEntity.fromJson(response);
    expect(responseEntity.articles.first.title,
        "Chinese EV maker Nio to launch its lower-priced brand Onvo on May 15");
    expect(
        responseEntity.articles.first.title, response['articles'][0]['title']);
    expect(responseEntity.articles[1].urlToImage,
        "https://img.etimg.com/thumb/msid-109963888,width-1200,height-630,imgsize-93376,overlay-ettech/photo.jpg");
    expect(responseEntity.articles[1].urlToImage,
        response['articles'][1]['urlToImage']);
  });
}
