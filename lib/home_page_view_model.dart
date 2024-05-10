import 'package:either_dart/either.dart';
import 'package:news_flutter_domain/errors/base_error.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:news_flutter_domain/usecase/get_news_usecase.dart';
import 'package:rxdart/rxdart.dart';

/// View model will handle communication between UI and data layer
/// Responsibilities:
/// Fetching data from data layer and notifying its response to UI
/// To hold UI state, required controllers
/// Calculations like validation, data filtration, sorting
class HomePageViewModel {
  final GetNewsUseCase getNewsUseCase;

  HomePageViewModel(this.getNewsUseCase) {
    getNewsList();
  }

  /// Response subject will be private so data can only added so we can restrict adding data from this page only
  PublishSubject<Either<List<NewsModel>, BaseError>> _news_list_subject = PublishSubject<Either<List<NewsModel>, BaseError>>();

  /// This getter will generate stream from private response subject
  /// This stream will be used in page in order to make UI changes as per response
  Stream<Either<List<NewsModel>, BaseError>> get news_list_stream => _news_list_subject.stream;

  /// This function will be called from UI to fetch data from data layer
  /// After fetching data it will add data into stream which UI will listen and update UI
  void getNewsList() async {
    _news_list_subject.add(await getNewsUseCase.execute(GetNewsUseCaseParams()));
  }
}
