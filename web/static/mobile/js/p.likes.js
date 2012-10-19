S.pages['likes'] = function() {
    var page = S.DOM.content,
        storyid = page.data('storyid');

    new S.blockLikes({
        storyid: storyid
    }).init();  
};
