module UnitfulDual

import DiffRules
import Base: +, *, -, /, ^, ==, isequal, isless, show, inv, getindex,
       sqrt, cbrt, abs, abs2, log, log10, log2, exp, 
       sin, cos, tan, sec, csc, cot, acos, atan, asec, acsc, acot
export UnitDual, UnitPartials, value, partials

include("Types.jl")
include("UnitPartialsFunctions.jl")
include("UnitDualFunctions.jl")

end # module
