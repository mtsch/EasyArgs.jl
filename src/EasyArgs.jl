module EasyArgs

export get_arg, ARG_DICT, check_unused_args

const ARG_DICT = Dict{Any,String}()
const USED_ARGS = Set{Any}()

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@compiler_options"))
    @eval Base.Experimental.@compiler_options compile=min optimize=0 infer=false
end

function __init__()
    _parse_args!(ARG_DICT, ARGS)
end

function _parse_args!(output, input)
    position = 1
    for curr in input
        if startswith(curr, "--")
            # Long named argument
            sp = split(curr[3:end], '='; limit=2)
            name = sp[1]
            value = get(sp, 2, "")
            _put_arg!(output, name, value)
        elseif startswith(curr, "-")
            name = curr[2:end]
            _put_arg!(output, name[1:1], name[nextind(name, 1):end])
        else
            # Positional argument
            _put_arg!(output, position, curr)
            position += 1
        end
    end
    return output
end

function _put_arg!(dict, key, value)
    if haskey(dict, key)
        @warn "Duplicate argument \"$key\". Only the first occurenece will be used"
    else
        dict[key] = value
    end
end

"""
    get_arg(arg, default)

Get the command line argument `arg`. If `arg` was not given, the `default` value is returned.
If the argument exists, its value is parsed to be the same type as `default`.
"""
function get_arg(key, default::Bool)
    if haskey(ARG_DICT, key)
        if ARG_DICT[key] == ""
            push!(USED_ARGS, key)
            return true
        else
            return _get_arg(key, Bool)
        end
    else
        return default
    end
end
function get_arg(key, default::T) where {T}
    if haskey(ARG_DICT, key)
        return _get_arg(key, T)
    else
        return default
    end
end
function get_arg(key, T::Type)
    if !haskey(ARG_DICT, key)
        if key isa Int
            throw(ArgumentError("required positional argument $key not given"))
        else
            throw(ArgumentError("required argument `$key` not given"))
        end
    else
        return _get_arg(key, T)
    end
end

function _get_arg(key, T::Type)
    push!(USED_ARGS, key)
    if T <: AbstractString
        return T(ARG_DICT[key])
    else
        return parse(T, ARG_DICT[key])
    end
end

function check_unused_args(; error=false)
    unused = Pair[]
    for (k, v) in ARG_DICT
        (k ∉ USED_ARGS) && push!(unused, k => v)
    end
    if !isempty(unused)
        msg = "the following arguments were given, but not used: "
        if error
            Base.error(msg, "`", join(unused, "`, `"), "`")
        else
            @warn msg unused
        end
    end
end

end
