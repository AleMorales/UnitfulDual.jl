# This is modified from ForwardDiff in order to allow
# partials to be a tuple of heterogeneous types.
# It is basically unrolling a loop over all partial derivatives
# and performing the basic operations that required


# Switch to the right generated function depending on type
function add_partials(a::T1, b::T2)  where {T1, T2}
    if isnamed(T1)
        add_named_partials(a,b)
    else
        add_unnamed_partials(a,b)
    end
end
function sub_partials(a::T1, b::T2)  where {T1, T2}
    if isnamed(T1)
        sub_named_partials(a,b)
    else
        sub_unnamed_partials(a,b)
    end
end
function neg_partials(a::T1)  where T1
    if isnamed(T1)
        neg_named_partials(a)
    else
        neg_unnamed_partials(a)
    end
end
function mul_partials(a::T1, b::T2, afactor, bfactor) where {T1, T2}
    if isnamed(T1)
        mul_named_partials(a,b, afactor, bfactor)
    else
        mul_unnamed_partials(a,b, afactor, bfactor)
    end
end
function scale_partials(a::T1, x)  where T1
    if isnamed(T1)
        scale_named_partials(a, x)
    else
        scale_unnamed_partials(a, x)
    end
end

# Operations on partial derivatives that are not named
function partialexpr(f, N)
    ex = Expr(:tuple, [f(i) for i=1:N]...)
    return quote
        $(Expr(:meta, :inline))
        @inbounds return $ex
    end
end

@generated function add_unnamed_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2})  where {N, T1 <: Tuple, T2 <: Tuple}
    return partialexpr(i -> :(a.partials[$i] + b.partials[$i]), N)
end
@generated function sub_unnamed_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2})  where {N, T1 <: Tuple, T2 <: Tuple}
    return partialexpr(i -> :(a.partials[$i] - b.partials[$i]), N)
end
@generated function neg_unnamed_partials(a::UnitPartials{N,T1})  where {N, T1 <: Tuple, T2 <: Tuple}
    return partialexpr(i -> :(-a.partials[$i]), N)
end
@generated function mul_unnamed_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2}, afactor, bfactor)  where {N, T1 <: Tuple, T2 <: Tuple}
    return partialexpr(i -> :( (afactor*a.partials[$i]) + (bfactor*b.partials[$i])), N)
end
@generated function scale_unnamed_partials(a::UnitPartials{N,T1}, x)  where {N, T1 <: Tuple, T2 <: Tuple}
    return partialexpr(i -> :( x*a.partials[$i] ), N)
end


# Operations on partial derivatives that are named
function namedpartialexpr(f, ::Val{names}) where names
    ex = :(UnitPartials(;$((f(i) for i in names)...)))
    return quote
        $(Expr(:meta, :inline))
        @inbounds return $ex
    end
end

@generated function add_named_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2})  where {N, T1 <: NamedTuple, T2 <: NamedTuple}
    return namedpartialexpr(i -> :($i = a.partials.$i + b.partials.$i), Val(T1.parameters[1]))
end
@generated function sub_named_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2})  where {N, T1 <: NamedTuple, T2 <: NamedTuple}
    return namedpartialexpr(i -> :($i = a.partials.$i - b.partials.$i), Val(T1.parameters[1]))
end
@generated function neg_named_partials(a::UnitPartials{N,T1})  where {N, T1 <: NamedTuple, T2 <: NamedTuple}
    return namedpartialexpr(i -> :($i = -a.partials.$i), Val(T1.parameters[1]))
end
@generated function mul_named_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2}, afactor, bfactor)  where {N, T1 <: NamedTuple, T2 <: NamedTuple}
    return namedpartialexpr(i -> :($i = (afactor*a.partials.$i) + (bfactor*b.partials.$i)), Val(T1.parameters[1]))
end
@generated function scale_named_partials(a::UnitPartials{N,T1}, x)  where {N, T1 <: NamedTuple, T2 <: NamedTuple}
    return namedpartialexpr(i -> :($i = x*a.partials.$i), Val(T1.parameters[1]))
end