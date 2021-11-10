module EasyArgs

export get_arg, ARG_DICT

const ARG_DICT = Dict{Any,String}()

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

function __init__()
    parse_args!(ARG_DICT, ARGS)
end

function parse_args!(output, input)
    position = 1
    for curr in input
        if startswith(curr, "--")
            # Long named argument
            sp = split(curr[3:end], '='; limit=2)
            name = sp[1]
            value = get(sp, 2, "")
            put_arg!(output, name, value)
        elseif startswith(curr, "-")
            name = curr[2:end]
            put_arg!(output, name[1:1], name[nextind(name, 1):end])
        else
            # Positional argument
            put_arg!(output, position, curr)
            position += 1
        end
    end
    return output
end

function put_arg!(dict, key, value)
    if haskey(dict, key)
        @warn "Duplicate argument $key"
    end
    dict[key] = value
end

"""
    get_arg(arg, default)

Get the command line argument `arg`. If `arg` was not given, the `default` value is returned.
If the argument exists, its value is parsed to be the same type as `default`.
"""
function get_arg(key, default::S) where {S<:AbstractString}
    if haskey(ARG_DICT, key)
        return S(ARG_DICT[key])
    else
        return default
    end
end
function get_arg(key, default::Bool)
    if haskey(ARG_DICT, key)
        value = ARG_DICT[key]
        if value == ""
            return true
        else
            return parse(Bool, value)
        end
    else
        return default
    end
end
function get_arg(key, default::T) where {T}
    if haskey(ARG_DICT, key)
        return parse(T, ARG_DICT[key])
    else
        return default
    end
end

end
