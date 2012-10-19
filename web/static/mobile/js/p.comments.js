S.pages['comments'] = function() {
    var page = S.DOM.content,
        storyid = page.data('storyid');

    new S.blockComments({
        storyid: storyid
    }).init();
};
