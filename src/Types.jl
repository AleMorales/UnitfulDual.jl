
####################################################################################
############################### UnitPartials #######################################
####################################################################################

# Tuple with partial derivatives for an UnitDual Number
# Note: Each partial derivative will have a different concrete type because
# they are expected to be Quantities. 
# N reflects the length of the tuple
struct UnitPartials{N, TT <: Tuple}
    partials::TT
end

# Constructors
UnitPartials(t::Tuple) = UnitPartials{length(t), typeof(t)}(t)
UnitPartials(args...) = UnitPartials(args)

# Pretty printing
function show(io::IO, up::UnitPartials)
    print(io, '{', join(up.partials, ", "), '}')
end

# Forwarding methods to the underlying tuple
function getindex(up::UnitPartials, i)
    @boundscheck i > length(up.partials) && throw(BoundsError(up, i))
    up.partials[i]
end

length(up::UnitPartials) = length(up.partials)
iterate(up::UnitPartials) = iterate(up.partials)
iterate(up::UnitPartials, state) = iterate(up.partials, state)

####################################################################################
################################# UnitDual #########################################
####################################################################################

# An UnitDual is composed of a value and a tuple of partial derivatives
struct UnitDual{DT <: Number, PT <: UnitPartials}
    value::DT
    partials::PT
end

# Constructors
UnitDual(val, partials::Tuple) = UnitDual(val, UnitPartials(partials))
UnitDual(val, args...) = UnitDual(val, UnitPartials(args)) 

# Setters and getters
value(x::UnitDual) = x.value
partials(x::UnitDual) = x.partials

# Pretty printing
function show(io::IO, z::UnitDual)
    print(io, "$(value(z))")
    show(io, partials(z))
end
