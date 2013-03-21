Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class H264Encode extends Encoder
    do: (@job, @callback) ->
        super(@job, @callback)
                
    encode: () =>
        @filename = path.basename(@currentFile, path.extname(@currentFile)) + ".mp4"

#        @job.durationraw = "00:00:31.00"
#        @job.durationsec = 31

        @job.filename = @filename

        @job.queue.addJob @job
        
        new Ffmpeg(
            source: @currentFile
            timeout: 10800
        ).withVideoBitrate("700k")
         .withVideoCodec("libx264")
         .withAudioCodec("libfaac")
         .withAudioBitrate("192k")
         .withAudioChannels(2)
         .toFormat("mp4")
         .addOption('-threads', '0')
         .addOption("-ar", "48000")
         .addOption("-vpre", "baseline")
         .onProgress(@progress)
         .saveToFile(path.join(@destination, @filename), @saveFileCallback)
        
module.exports = H264Encode