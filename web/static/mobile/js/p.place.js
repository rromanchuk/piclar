S.pages['place'] = function() {
    var page = S.DOM.content,

        photos = page.find('.p-p-imgfeed');

    photos.length && photos.mod_photoFeed();
};
