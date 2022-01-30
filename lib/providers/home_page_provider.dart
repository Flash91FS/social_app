import 'package:flutter/foundation.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - HomePageProvider - ";

class HomePageProvider extends ChangeNotifier {
  bool _isHomePageProcessing = true;
  List<Feed> _feedsList = [];
  // int _currentPage = 1;
  // bool _shouldRefresh = true;

  // bool get shouldRefresh => _shouldRefresh;
  //
  // setShouldRefresh(bool value) => _shouldRefresh = value;
  //
  // int get currentPage => _currentPage;
  //
  // setCurrentPage(int page) {
  //   _currentPage = page;
  // }

  bool get isHomePageProcessing => _isHomePageProcessing;

  setIsHomePageProcessing(bool value, {bool notify = true}) {
    log("$TAG setIsHomePageProcessing(): called ---");
    _isHomePageProcessing = value;
    if (notify) notifyListeners();
  }

  List<Feed> get feedsList => _feedsList;

  setFeedsList(List<Feed> list, {bool notify = true}) {
    log("$TAG setFeedsList(): called ---");
    _feedsList = list;
    if (notify) notifyListeners();
  }

  mergeFeedsList(List<Feed> list, {bool notify = true}) {
    log("$TAG mergeFeedsList(): called ---");
    _feedsList.addAll(list);
    if (notify) notifyListeners();
  }

  addFeed(Feed feed, {bool notify = true}) {
    log("$TAG addFeed(): called ---");
    _feedsList.add(feed);
    if (notify) notifyListeners();
  }

  Feed getFeedByIndex(int index) => _feedsList[index];

  int get feedsListLength => _feedsList.length;
}