Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class WebMEncode extends Encoder
    do: (@job, @callback) ->        
        super(@job, @callback)
    
    encode: () =>        
        @filename = path.basename(@currentFile, path.extname(@currentFile)) + ".webm"
        
        ffmpeg = new Ffmpeg(
            source: @currentFile
            timeout: 3000
        ).withVideoBitrate("700k")
         .withVideoCodec("libvpx")
         .withAudioCodec("libvorbis")
         .withAudioBitrate("192k")
         .withAudioChannels(2)
         .toFormat("webm")
         .addOption("-t", "00:00:31")
         .addOption("-ar", "48000")
         .onProgress(@progress)
         .saveToFile(path.join(@destination, @filename), (stdout, stderr) =>            
            @job.done = true
            @job.stdout = stdout
            @job.stderr = stderr
            @callback(null, null, @job)
        )
        
module.exports = WebMEncode