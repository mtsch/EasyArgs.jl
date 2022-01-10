using EasyArgs

required_pos = get_arg(1, String)
required_opt = get_arg("o", Float64) # -o<num> or --o=<num>

optional_pos = get_arg(2, 3)
optional_opt = get_arg("flag", false) # --flag

@show required_pos
@show required_opt
@show optional_pos
@show optional_opt

check_unused_args() # pass error=true to throw an error instead
