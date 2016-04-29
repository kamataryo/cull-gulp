request = require 'request'
BLACKLIST_URL = 'http://gulpjs.com/plugins/blackList.json'

# call if defined as function
call = (func, args) ->
    if typeof func is 'function'
        func.apply null, args


getBlacklist = (arg1, arg2) ->
    if typeof arg1 is 'string'
        [url, callback] = [arg1, arg2]
    else if typeof arg1 is 'function'
        [url, callback] = [BLACKLIST_URL, arg1]
    else
        throw new Error 'invalid argument(s).'

    request url, (error, res, body) ->
        if !error and res.statusCode is 200
            call callback, [null, JSON.parse body]
        else
            call callback, [error, null]


check = (arg1, arg2)->
    if typeof arg1 is 'object'
        [{mode, path, names, blacklistURL}, callback] = [arg1, arg2]
    else if typeof arg1 is 'function'
        [{mode, path, names, blacklistURL}, callback] = [{}, arg1]
    else
        throw new Error 'invalid argument(s).'

    if names?
        if typeof names isnt Array
            names = [names]
    else
        unless path? then path = './'
        {dependencies, devDependencies} =
            dependencies: Object.keys require("#{path}package.json").dependencies
            devDependencies: Object.keys require("#{path}package.json").devDependencies
        names = dependencies.concat devDependencies


    url = if blacklistURL? then blacklistURL else BLACKLIST_URL
    getBlacklist url, (error, list) ->
        if error?
            call callback, [error, null]
        else
            message = ''
            result = false
            for name in names
                isBlacklisted = name in Object.keys list
                result = result and isBlacklisted
                if isBlacklisted
                    message += "[notice] package `#{name}` is blacklisted, for #{list[name]}\n"
                else
                    message += "[information] package `#{name}` is not blacklisted.\n"

            console.log message
            call callback, [null, result]



module.exports = {BLACKLIST_URL, call, getBlacklist, check}
