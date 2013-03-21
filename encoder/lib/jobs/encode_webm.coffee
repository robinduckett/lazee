Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class WebMEncode extends Encoder
    do: (@job, @callback) ->        
        super(@job, @callback)
    
    encode: () =>        
        @filename = path.basename(@currentFile, path.extname(@currentFile)) + ".webm"

        @job.filename = @filename

        @job.queue.addJob @job

        new Ffmpeg(
            source: @currentFile
            timeout: 10800
        ).withVideoBitrate("700k")
         .withVideoCodec("libvpx")
         .withAudioCodec("libvorbis")
         .withAudioBitrate("192k")
         .withAudioChannels(2)
         .toFormat("webm")
         .addOption('-threads', '16')
         .addOption("-ar", "48000")
         .onProgress(@progress)
         .saveToFile(path.join(@destination, @filename), @saveFileCallback)
        
module.exports = WebMEncode