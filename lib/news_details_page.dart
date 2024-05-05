import 'package:flutter/material.dart';
import 'package:news_flutter/base_page/base_page.dart';
import 'package:news_flutter_domain/model/news_model.dart';
import 'package:provider/provider.dart';

class NewsDetailsPage extends BasePage {
  final NewsDetailsPageArgs args;

  const NewsDetailsPage({super.key, required this.args});

  @override
  NewsDetailsPageState createState() => NewsDetailsPageState();
}

class NewsDetailsPageArgs {
  final NewsModel news;

  NewsDetailsPageArgs({required this.news});
}

class NewsDetailsPageState extends BasePageState<NewsDetailsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<NewsDetailsPageViewModel>(context).arguments = widget.args;
  }

  @override
  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('home page'),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Consumer<NewsDetailsPageViewModel>(
        builder: (BuildContext context, model, child) =>
            NewsDetailsPageView(model: model));
  }
}

class NewsDetailsPageView extends StatelessWidget {
  final NewsDetailsPageViewModel model;

  const NewsDetailsPageView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    NewsModel? news = model.arguments?.news;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Visibility(
              visible: news?.imageUrl.isNotEmpty ?? false,
              child: Image.network(news!.imageUrl)),
          Text(news.title),
        ],
      ),
    );
  }
}

/// View model will handle communication between UI and data layer
/// Responsibilities:
/// Fetching data from data layer and notifying its response to UI
/// To hold UI state, required controllers
/// Calculations like validation, data filtration, sorting
class NewsDetailsPageViewModel {
  NewsDetailsPageArgs? arguments;
}
