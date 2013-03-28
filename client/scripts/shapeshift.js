var Shapeshift;

Shapeshift = (function() {

    function Shapeshift(str) {
        this.str = str;

        this.str = this.str.replace(/[\[\]]+/ig, '.');
        this.parsed = null;
    }

    Shapeshift.prototype.parse = function() {
        var matchers = {
            video_formats: /[\. ](xvid|x264|ntsc|pal)/ig,
            audio_formats: /[\. ](ac3|dolby|surround)/ig,
            video_types:   /[\. ]?(dvdrip|brrip|bdrip|bd9|dvdr|dvd9|hddvd|hdtv|bluray|cam|pdtv|dvdscr)/ig,
            year:          /[\. ]((18|19|20|21)\d\d)/ig,
            quality:       /[\. ](\d\d\d+(p|i))/ig,
            platform:      /[\. ](xbox360|ps3|wii)/ig,
            season:        /[\. ]S(\d\d\d?)/ig,
            episode:       /[\. ]?E(\d\d\d?)/ig,
            release_group: /-[\s+]?([\w\d\.]+)$/i,
            language:      /[\. ]?(ENG|SWE|ESP|MULTI)/ig,
            remastered:    /[\. ]?REMASTERED/ig,
            unrated:       /[\. ]?(Unrated Edition|UNRATED)/g
        };

        var parsed = this.str;
        var parsedobj = {};

        for (var matcher in matchers) {
            if (matchers.hasOwnProperty(matcher)) {
                if (parsed.match(matchers[matcher])) {
                    parsedobj[matcher] = matchers[matcher].exec(parsed)[1];
                    parsed = parsed.replace(matchers[matcher], '');
                }
            }
        }

        parsed = parsed.replace(/[\.-]+/ig, ' ');

        // Tidy up metadata from title
        for (var matcher in matchers) {
            if (matchers.hasOwnProperty(matcher)) {
                if (parsed.match(matchers[matcher])) {
                    parsed = parsed.replace(matchers[matcher], '');
                }
            }
        }

        this.parsed = parsedobj;
        this.parsed.name = parsed;

        return this;
    };


    Shapeshift.prototype.toString = function() {
        var str = "";

        if (this.parsed.episode && this.parsed.season)
            str = this.parsed.name + " (Season " + this.parsed.season + ", Episode " + this.parsed.episode + ")";

        if (this.parsed.season)
            str = this.parsed.name + " (Season " + this.parsed.season + ")";

        if (this.parsed.year)
            str = this.parsed.name + " (" + this.parsed.year + ")";

        if (this.parsed.quality)
            str = str + " " + this.parsed.quality + "";

        if (str.length === 0) str = this.parsed.name;

        return "<strong style=\"font-weight: 400\">" + str + "</strong><br><small><small>" + this.str + "</small></small>";
    };

    Shapeshift.prototype.toObject = function() {
        return this.parsed;
    };

    return Shapeshift;

})();