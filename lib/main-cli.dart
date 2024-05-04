import 'package:either_dart/either.dart';
import 'package:news_flutter_data_newsapi/di.dart';
import 'package:news_flutter_domain/NewsDI.dart';
import 'package:news_flutter_domain/usecase/get_news_usecase.dart';

void main(List<String> args) async{
  if(args.isEmpty){
    print("please pass news api key as command line argument");
    return;
  }
  NewsDI newsDI = NewsApiDI(apiKey: args[0]);
  late GetNewsUseCase getNewsUseCase = newsDI.createGetNewsUseCase();
  var response = getNewsUseCase.execute(GetNewsUseCaseParams());
  response.fold((left) {
    for(var news in left){
      print("\n ${news.title}");
    }
  }, (right) => null);
}