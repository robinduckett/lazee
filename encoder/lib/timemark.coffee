class Timemark
    constructor: (mark) ->
        split = mark.split(':')

        @hours = 0
        @minutes = 0
        @seconds = 0
        @totalSeconds = 0

        if split.length is 2
            @minutes = parseInt(split[0])
            @seconds = parseFloat(split[1])

            @totalSeconds = (@minutes * 60) + @seconds

        if split.length is 3
            @hours = parseInt(split[0])
            @minutes = parseInt(split[1])
            @seconds = parseFloat(split[2])

            @totalSeconds = (@hours * 60 * 60) + (@minutes * 60) + @seconds

    toSeconds: () ->
        return Math.ceil(@totalSeconds)

module.exports = Timemark