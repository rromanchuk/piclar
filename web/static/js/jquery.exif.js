// @require 'js/jpegmeta.js'

/* Author:
    Max Degterev @suprMax
    based on http://benno.id.au/blog/2009/12/30/html5-fileapi-jpegmeta
    JpegMeta must be loaded first
*/

;(function($) {
    var getFilePart = function(file) {
        if (file.slice) {
            filePart = file.slice(0, 131072);
        } else if (file.webkitSlice) {
            filePart = file.webkitSlice(0, 131072);
        } else if (file.mozSlice) {
            filePart = file.mozSlice(0, 131072);
        } else {
            filePart = file;
        }
    
        return filePart;
    };

    var parseEXIF = function(file, callback) {
        var reader = new FileReader();

        reader.onload = function(e) {
            callback(new JpegMeta.JpegFile(e.target.result, file.name));
        };
        
        reader.readAsBinaryString(getFilePart(file));
    };

    $.parseEXIF = parseEXIF;
})(jQuery);
