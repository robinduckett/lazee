Ffmpeg = require('fluent-ffmpeg')
path = require('path')

Encoder = require('./encoder')

class H264Encode extends Encoder
    do: (@job, @callback) ->
        super(@job, @callback)
                
    encode: () =>
        @filename = path.basename(@currentFile, path.extname(@currentFile)) + ".mp4"
        
        ffmpeg = new Ffmpeg(
            source: @currentFile
            timeout: 3000
        ).withVideoBitrate("700k")
         .withVideoCodec("libx264")
         .withAudioCodec("libfaac")
         .withAudioBitrate("192k")
         .withAudioChannels(2)
         .toFormat("mp4")
         .addOption("-t", "00:00:31")
         .addOption("-ar", "48000")
         .addOption("-vpre", "baseline")
         .onProgress(@progress)
         .saveToFile(path.join(@destination, @filename), (stdout, stderr) =>
            @job.done = true
            @job.stdout = stdout
            @job.stderr = stderr
            if stderr then @callback(stderr, null, @job) else @callback(null, null, @job)
        )
        
module.exports = H264Encode