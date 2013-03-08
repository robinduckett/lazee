Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class H264Encode extends Encoder
    do: (@job, @callback) ->
        console.log "h264"
        super(@job, @callback)
                
    encode: () =>
        ffmpeg = new Ffmpeg(
            source: @currentFile
            timeout: 3000
        ).withVideoBitrate("1024k")
         .withVideoCodec("libx264")
         .withAudioCodec("libfaac")
         .withAudioBitrate("128k")
         .withAudioChannels(2)
         .toFormat("mp4")
         .addOption("-t", "00:5:00")
         .addOption("-ar", "48000")
         .saveToFile(path.join(@destination, path.basename(@currentFile, path.extname(@currentFile))) + ".mp4", (stdout, stderr) =>
            console.log stdout
            console.log stderr
            
            @job.done = true
            @callback(null, null, @job)
        )
        
module.exports = H264Encode