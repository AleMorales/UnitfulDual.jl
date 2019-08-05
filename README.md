# UnitfulDual

[![Build Status](https://travis-ci.com/AleMorales/UnitfulDual.jl.svg?branch=master)](https://travis-ci.com/AleMorales/UnitfulDual.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/AleMorales/UnitfulDual.jl?svg=true)](https://ci.appveyor.com/project/AleMorales/UnitfulDual-jl)
[![Codecov](https://codecov.io/gh/AleMorales/UnitfulDual.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/AleMorales/UnitfulDual.jl)

**This package is in development**

UntifulDual implements a dual number that can hold physical quantities (i.e. numbers with physical dimensions and units) building upon [Unitful](https://github.com/PainterQubits/Unitful.jl). An `UnitDual` number is created from physical quantities and the partial derivatives with respect to every other UnitDual number in the computation (in the same order for every UnitDual number):

```julia
julia> using UnitfulDual

julia> using Unitful

julia> r₁ = 1.0u"mol/L"
1.0 mol L^-1

julia> r₂ = 1.0u"mol/L"
1.0 mol L^-1

julia> k = 0.1u"L/mol/s"
0.1 L mol^-1 s^-1

julia> dr₁ = UnitDual(r₁, 1.0, zero(r₁/r₂), zero(r₁/k))
1.0 mol L^-1 {1.0, 0.0, 0.0 mol^2 s L^-2}

julia> dr₂ = UnitDual(r₂, zero(r₂/r₁), 1.0, zero(r₂/k))
1.0 mol L^-1 {0.0, 1.0, 0.0 mol^2 s L^-2}

julia> dk  = UnitDual(k,  zero(k/r₁), zero(k/r₂), 1.0)
0.1 L mol^-1 s^-1 {0.0 L^2 mol^-2 s^-1, 0.0 L^2 mol^-2 s^-1, 1.0}
```

Note that, even though the partial derivative of `r₁` with respect to `k` is just 0, we need to assign it the correct physical dimensions associated to the expression $\partial r_1 / \partial k$. The partial derivatives are printed within "{}" after the value of the number. Dual numbers can then be used as part of any (supported) expression and it will take care of propagating the partial derivatives and their physical units automatically:

```julia
julia> rate = dr₁*dr₂*dk
0.1 mol L^-1 s^-1 {0.1 s^-1, 0.1 s^-1, 1.0 mol^2 L^-2}
```

You can also assign names to the partial derivatives and use different order for different dual numbers:

```julia
julia> dr₁ = UnitDual(r₁, r₁ = 1.0, r₂ = zero(r₁/r₂), k = zero(r₁/k))
1.0 mol L^-1 {r₁ = 1.0, r₂ = 0.0, k = 0.0 mol^2 s L^-2}

julia> dr₂ = UnitDual(r₂, r₂ = 1.0, r₁ = zero(r₂/r₁), k = zero(r₂/k))
1.0 mol L^-1 {r₂ = 1.0, r₁ = 0.0, k = 0.0 mol^2 s L^-2}

julia> dk  = UnitDual(k, k = 1.0,  r₁ = zero(k/r₁), r₂ = zero(k/r₂))
0.1 L mol^-1 s^-1 {k = 1.0, r₁ = 0.0 L^2 mol^-2 s^-1, r₂ = 0.0 L^2 mol^-2 s^-1}

julia> rate = dr₁*dr₂*dk
0.1 mol L^-1 s^-1 {r₁ = 0.1 s^-1, r₂ = 0.1 s^-1, k = 1.0 mol^2 L^-2}

julia> partials(rate).k
1.0 mol^2 L^-2
```

UnitfulDual is strongly inspired by [ForwardDiff](https://github.com/JuliaDiff/ForwardDiff.jl). The main difference is that the tuple of partial derivatives in an `UnitDual` number is heterogeneous, as different physical dimensions result in different types. Thus, the implementation is simply:

```julia
struct UnitPartials{N, TT <: Union{Tuple, NamedTuple}}
    partials::TT
end

struct UnitDual{DT <: Number, PT <: UnitPartials}
    value::DT
    partials::PT
end
```

As can be seen, the heterogenity of partial derivatives propagates to the `UnitDual` object. This means that a homogeneous container of `UnitDual` numbers will cause type instability (see example below) so it is better to store them in tuples or using an [SOA](https://en.wikipedia.org/wiki/AOS_and_SOA) approach:

```julia
julia> @inbounds get_first(v) = v[1]
get_first (generic function with 1 method)

@code_warntype get_first([rate, dk])
Body::UnitDual
1 ─ %1 = (Base.arrayref)(true, v, 1)::UnitDual
└──      return %1
```

Many features such as tagging are not implemented for `UnitDual` numbers yet. This package is being developed primarily to support calculation of sensitivities in scientific models that already make use of Unitful. Application to automatic differentiation to compute gradients, Jacobians, etc will probably require removing physical units when extracting partials to avoid type instability issues.
