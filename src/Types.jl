
####################################################################################
############################### UnitPartials #######################################
####################################################################################

# Tuple with partial derivatives for an UnitDual Number
# Note: Each partial derivative will have a different concrete type because
# they are expected to be Quantities. 
# N reflects the length of the tuple
struct UnitPartials{N, TT <: Union{Tuple, NamedTuple}}
    partials::TT
end

# Check if the an UnitPartials type contains a named tuple
isnamed(::Type{UnitPartials{N,TT}}) where {N,TT} = length(TT.parameters) > 0 && TT.parameters[1] isa Tuple

# Constructors
UnitPartials(t::T) where T <: Union{Tuple, NamedTuple} = UnitPartials{length(t), typeof(t)}(t)
UnitPartials(args...) = UnitPartials(args)
UnitPartials(;kwargs...) = UnitPartials(values(kwargs))

# Pretty printing -> includes names for named tuples
function show(io::IO, up::T) where {T <: UnitPartials}
    if isnamed(T)
        names = keys(up.partials)
        vals = values(up.partials)
        pairs = string.(names) .* " = " .* string.(vals)
        print(io, '{', join(pairs, ", "), '}')
    else
        print(io, '{', join(up.partials, ", "), '}')
    end
end

# Forwarding getter methods to the underlying tuple
function getindex(up::UnitPartials, i::Integer)
    @boundscheck i > length(up.partials) && throw(BoundsError(up, i))
    up.partials[i]
end
function getindex(up::T, n::Symbol) where {T <: UnitPartials}
    !isnamed(T) && throw(DomainError(n, "Attempt to access named partial from an UnitPartials object that does not have named partials"))
    getproperty(up.partials, n)
end
function getproperty(up::T, n::Symbol) where {T <: UnitPartials}
    if n == :partials
        getfield(up, :partials)
    else
        !isnamed(T) && throw(DomainError(up, "Attempt to access named partial from an UnitPartials object that does not have named partials"))
        getfield(up.partials, n)
    end
end

# Iterator interface
length(up::UnitPartials) = length(up.partials)
iterate(up::UnitPartials) = iterate(up.partials)
iterate(up::UnitPartials, state) = iterate(up.partials, state)

# Zero UnitPartials (by type or instance)
zero(up::T) where {T <: UnitPartials} = zero(T)

zero(::Type{UnitPartials{N,TT}}) where {N,TT <: Tuple} = UnitPartials((zero(p) for p in TT.parameters)...)

function zero(::Type{UnitPartials{N,TT}}) where {N,TT <: NamedTuple}
    z = Tuple((zero(p) for p in TT.parameters[2].parameters))
    UnitPartials(NamedTupleTools.namedtuple(TT.parameters[1], z))
end

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
UnitDual(val; kwargs...) = UnitDual(val, UnitPartials(; kwargs...)) 

# Setters and getters
value(x::UnitDual) = x.value
partials(x::UnitDual) = x.partials

# Convenience functions
zero(x::T) where {T <: UnitDual} = zero(T)
zero(::Type{UnitDual{DT, PT}}) where {DT, PT} = UnitDual(zero(DT), zero(PT))

# Pretty printing
function show(io::IO, x::UnitDual)
    print(io, "$(value(x)) ")
    show(io, partials(x))
end

# Iterator interface
length(x::UnitDual) = 1
iterate(x::UnitDual) = (x, nothing)
iterate(x::UnitDual, state::Nothing) = nothing