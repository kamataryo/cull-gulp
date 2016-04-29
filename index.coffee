request = require 'request'
blacklistURL = 'http://gulpjs.com/plugins/blackList.json'

# call if defined as function
call = (func, args) ->
    if typeof func is 'function'
        func.apply null, args


getBlacklist = (arg1, arg2) ->
    if typeof arg1 is 'string'
        [url, callback] = [arg1, arg2]
    else if typeof arg1 is 'function'
        [url, callback] = [blacklistURL, arg1]

    request url, (error, res, body) ->
        if !error and res.statusCode is 200
            call callback, [null, JSON.parse body]
        else
            call callback, [error, null]


check = ({mode, path, name, failure, success})->
    unless path? and name?
        error = new Error 'one of path or name properties is required in the argument.'
        if mode is 'strict' then throw error
        call failure, [error]

    else
        getBlacklist {
            success: (list) ->
                result = name in Object.keys list
                if result
                    reason = list[name]
                    message = "[notice] package `#{name}` is blacklisted, for #{reason}"
                else
                    message = "[information] package `#{name}` is not blacklisted."
                if typeof this.arguments[0].callback is 'function'
                    console.log message
                    arguments[0].callback result
        }


module.exports = {blacklistURL, call, getBlacklist, check}
