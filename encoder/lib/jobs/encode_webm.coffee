Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class WebMEncode extends Encoder
    do: (@job, @callback) ->        
        super(@job, @callback)
    
    encode: () =>        
        @filename = path.basename(@currentFile, path.extname(@currentFile)) + ".webm"

        @job.durationraw = "00:00:31.00"
        @job.durationsec = 31

        new Ffmpeg(
            source: @currentFile
            timeout: 10800
        ).withVideoBitrate("700k")
         .withVideoCodec("libvpx")
         .withAudioCodec("libvorbis")
         .withAudioBitrate("192k")
         .withAudioChannels(2)
         .toFormat("webm")
         .addOption("-t", "00:00:31")
         .addOption("-ar", "48000")
         .onProgress(@progress)
         .saveToFile(path.join(@destination, @filename), @saveFileCallback)
        
module.exports = WebMEncode