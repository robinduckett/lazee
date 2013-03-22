var torrents = [];
var refreshTimeout = null
var template = null;
var toggled = [];

function getTorrents(done) {
    $.getJSON('/admin/torrents/get', function(result) {
        torrents = result;
        
        if (typeof(callback) == "function") {
            done()
        }
    });
}

function showUI() {
    var frame = $('<iframe class="rounded" src="' + $('#transmission_url').val() + '" frameborder="0" width="940" height="400"></iframe>');

    $('#torrents').addClass('iframe');
    
    $('#torrents').html(frame);
}

function showMain() {
    getTorrents();
    
    var torrentlist = [];
    
    torrents.forEach(function(torrent) {
        torrent.fileList = template.render('filelist', torrent);
        torrent_template = template.render('torrent', torrent);
        torrentlist.push(torrent_template);
    });
        
    $('#torrents').html(template.render('torrentlist', {torrents: torrentlist.join('\n')}));
    
    $('.showfiles').off();
    $('.encode').off();
    
    $('.encode').click(function() {
        var id = $(this).data('torrentid');
        
        var torrent = _.findWhere(torrents, {id: id});
        
        var files = _.map(torrent.files, function(file) {
            return torrent.downloadDir + '/' + file.name;
        });
        
        if (torrent.id === id) {
            console.log('posting');

            $.post("/admin/encoder/create", {name: torrent.name, files: files}, function(data, status, xhr) {
                if (data.success) {
                    location.href = '/admin/encoder';
                } else {
                    $('.encode').addClass('danger');
                }
            }, 'json');
        }
    });
    
    $('.showfiles').click(function() {
        var id = $(this).data('torrentid');
        
        if (toggled.indexOf(id) > -1) {
            toggled.splice(toggled.indexOf(id), 1);
            $('#fileList' + id).addClass('collapsed');
        } else {
            toggled.push(id);
            $('#fileList' + id).removeClass('collapsed');
        }
    });
    
    refreshTimeout = setTimeout(showMain, 2000);
}

function showTidy() {
    
}

var panes = {
    main: {func: showMain},
    webui: {func: showUI},
    tidy: {func: showTidy}
};

$(function() {
    template = new Template();
        
    template.add("torrent", "admin/torrent.html");
    template.add("torrentlist", "admin/torrentlist.html");
    template.add("filelist", "admin/filelist.html");

    template.load(function() {
        torrents = JSON.parse($('#torrents_json').html());    
        
        _.each(panes, function(opts, pane) {
            $('#' + pane).click(function() {
                clearTimeout(refreshTimeout);
                $(this).parent().children().removeClass('active')
                $('#torrents').removeClass('iframe');
                $(this).addClass('active');
                $('#torrents').empty();
                opts.func();
            });
        });
    
        showMain();
    });
});