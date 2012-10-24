S.pages['checkin'] = function() {
    var page = S.DOM.content,
        story = page.find('.b-activity-story'),

        storyid = story.data('storyid');

    new S.blockComments({
        storyid: storyid
    }).init();
};
