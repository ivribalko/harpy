import 'package:harpy/api/twitter/data/tweet.dart';
import 'package:harpy/api/twitter/twitter_error_handler.dart';
import 'package:harpy/models/timeline_model.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class HomeTimelineModel extends TimelineModel {
  static HomeTimelineModel of(context) {
    return Provider.of<HomeTimelineModel>(context);
  }

  static final Logger _log = Logger("HomeTimelineModel");

  @override
  Future<List<Tweet>> getCachedTweets() =>
      timelineDatabase.findHomeTimelineTweets();

  @override
  Future<void> updateTweets({
    Duration timeout,
    bool silentError = false,
  }) async {
    _log.fine("updating tweets");

    List<Tweet> updatedTweets =
        await tweetService.getHomeTimeline(timeout: timeout).catchError(
              silentError ? silentErrorHandler : twitterClientErrorHandler,
            );

    if (updatedTweets != null) {
      final List<Tweet> cachedTweets = await getCachedTweets();
      updatedTweets = await copyHarpyData(
        origin: cachedTweets,
        target: updatedTweets,
      );

      tweets = updatedTweets;
      timelineDatabase.addHomeTimelineIds(updatedTweets, limit: 500);
      tweetDatabase
          .recordTweetList(updatedTweets)
          .then((_) => tweetDatabase.limitRecordedTweets(
                limit: 1000,
                targetAmount: 500,
              ));

      if (onTweetsUpdated != null) {
        onTweetsUpdated();
      }
    }

    notifyListeners();
  }

  @override
  Future<List<Tweet>> requestMoreTweets() => tweetService
      .getHomeTimeline(maxId: "${tweets.last.id - 1}")
      .catchError(twitterClientErrorHandler);

  void updateTweet(Tweet tweet) {
    final int index = tweets.indexOf(tweet);
    if (index != -1) {
      _log.fine("updating home timeline tweet");
      tweets[index].harpyData = tweet.harpyData;
    }
    notifyListeners();
  }
}
