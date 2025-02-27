import 'package:flutter/foundation.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - CommentsProvider - ";

class CommentsProvider extends ChangeNotifier {
  bool _isProcessing = true;
  Feed? _feed = null;
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

  bool get isProcessing => _isProcessing;

  setIsProcessing(bool value, {bool notify = true}) {
    log("$TAG setIsProcessing(): called ---");
    _isProcessing = value;
    if (notify) notifyListeners();
  }

  Feed? get feed => _feed;

  setFeed(Feed mFeed, {bool notify = true}) {
    log("$TAG setFeedsList(): called ---");
    _feed = mFeed;
    if (notify) notifyListeners();
  }

  // mergeFeedsList(Feed list, {bool notify = true}) {
  //   log("$TAG mergeFeedsList(): called ---");
  //   _feed.addAll(list);
  //   if (notify) notifyListeners();
  // }
  //
  // addFeed(Feed feed, {bool notify = true}) {
  //   log("$TAG addFeed(): called ---");
  //   _feed.add(feed);
  //   if (notify) notifyListeners();
  // }

  // Feed getFeedByIndex(int index) => _feed[index];

  // int get feedLength => _feed.length;
}