Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class WebMEncode extends Encoder
    do: (@job, @callback) ->
        console.log "webm"
        super(@job, @callback)
    
    encode: () =>
        ffmpeg = new Ffmpeg(
            source: @currentFile
            timeout: 3000
        ).withVideoBitrate("1024k")
         .withVideoCodec("libvpx")
         .withAudioCodec("libvorbis")
         .withAudioBitrate("128k")
         .withAudioChannels(2)
         .toFormat("webm")
         .addOption("-t", "00:5:00")
         .addOption("-ar", "48000")
         .saveToFile(path.join(@destination, path.basename(@currentFile, path.extname(@currentFile))) + ".webm", (stdout, stderr) =>
            console.log stdout
            console.log stderr
            
            @job.done = true
            @callback(null, null, @job)
        )
        
module.exports = WebMEncode