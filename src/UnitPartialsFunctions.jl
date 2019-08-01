# This is modified from ForwardDiff in order to allow
# partials to be a tuple of heterogeneous types.
# It is basically unrolling a loop over all partial derivatives
# and performing the basic operations that required

function partialexpr(f, N)
    ex = Expr(:tuple, [f(i) for i=1:N]...)
    return quote
        $(Expr(:meta, :inline))
        @inbounds return $ex
    end
end


@generated function add_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2})  where {N, T1, T2}
    return partialexpr(i -> :(a.partials[$i] + b.partials[$i]), N)
end
@generated function sub_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2})  where {N, T1, T2}
    return partialexpr(i -> :(a.partials[$i] - b.partials[$i]), N)
end
@generated function neg_partials(a::UnitPartials{N,T1})  where {N, T1, T2}
    return partialexpr(i -> :(-a.partials[$i]), N)
end
@generated function mul_partials(a::UnitPartials{N,T1}, b::UnitPartials{N,T2}, afactor, bfactor)  where {N, T1, T2}
    return partialexpr(i -> :( (afactor*a.partials[$i]) + (bfactor*b.partials[$i])), N)
end
@generated function scale_partials(a::UnitPartials{N,T1}, x)  where {N, T1, T2}
    return partialexpr(i -> :( x*a.partials[$i] ), N)
end