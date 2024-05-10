import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:news_flutter/base_page/base_page.dart';
import 'package:news_flutter/home_page_view_model.dart';
import 'package:news_flutter/news_details_page.dart';
import 'package:news_flutter/router.dart';
import 'package:news_flutter_data_newsapi/di.dart';
import 'package:news_flutter_domain/NewsDI.dart';
import 'package:news_flutter_domain/errors/base_error.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:news_flutter_domain/usecase/get_news_usecase.dart';
import 'package:provider/provider.dart';

import 'main.dart';
//test
class HomePage extends BasePage {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends BasePageState<HomePage> {
  @override
  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('News App'),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Provider<HomePageViewModel>(
      create: (BuildContext context) {
        NewsDI newsDI = NewsApiDI(apiKey: dotEnv.env['NEWS_API_KEY'] ?? '');
        GetNewsUseCase getNewsUseCase = newsDI.createGetNewsUseCase();
        return HomePageViewModel(getNewsUseCase);
      },
      child: Consumer<HomePageViewModel>(
          builder: (BuildContext context, model, child) =>
              HomePageView(model: model)),
    );
  }
}

class HomePageView extends StatelessWidget {
  final HomePageViewModel model;

  const HomePageView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Either<List<NewsModel>, BaseError>>(
        stream: model.news_list_stream,
        builder: (context, newsList) {
          return ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              String imageUrl = newsList.data?.left[index].imageUrl ?? '';
              return InkWell(
                onTap: () {
                  NewsModel? news = newsList.data?.left[index];
                  if (news != null) {
                    Navigator.pushNamed(context, AppRoutePaths.newsDetails,
                        arguments: NewsDetailsPageArgs(news: news));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Visibility(visible: imageUrl.isNotEmpty, child: Hero(tag: "newsImg$imageUrl", child: Image.network(imageUrl))),
                      Text(newsList.data?.left[index].title ?? ''),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
            itemCount: newsList.data?.left.length ?? 0,
          );
        });
  }
}
