// @require 'blocks/block-activity-feed/b-activity-feed.js'
// @require 'blocks/block-suggested-friends/b-suggested-friends.js'

(function($){
    var feed = new S.blockActivityFeed({
            collection: S.data.feed
        });//,
        //friends = new S.blockSuggestedFriends();

    feed.init();
    //friends.init();
})(jQuery);
