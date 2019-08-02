module UnitfulDual

import DiffRules
import NamedTupleTools
import Base: show, inv, getindex, getproperty, length, iterate, zero, zeros,
       +, *, -, /, ^, ==, isequal, isless, inv, isapprox,
       sqrt, cbrt, abs, abs2, log, log10, log2, exp, 
       sin, cos, tan, sec, csc, cot, acos, atan, asec, acsc, acot
export UnitDual, UnitPartials, value, partials, initialize_dual

include("Types.jl")
include("UnitPartialsFunctions.jl")
include("UnitDualFunctions.jl")
include("Convenience.jl")

end # module
