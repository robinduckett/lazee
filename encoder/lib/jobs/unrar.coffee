class Unrar
    constructor: () ->
    
    do: (job, @callback) ->
        console.log job
        
        setTimeout () =>
            @callback(null, null);
        , 5000