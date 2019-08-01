# Operators and mathematical functions overloaded for UnitDuals

# Binary operators for UnitDuals
+(a::UnitDual, b::UnitDual) = UnitDual(value(a) + value(b), add_partials(partials(a), partials(b)))
-(a::UnitDual, b::UnitDual) = UnitDual(value(a) - value(b), sub_partials(partials(a), partials(b)))
-(a::UnitDual) = UnitDual(-value(a), neg_partials(partials(a)))
*(a::UnitDual, b::UnitDual) = UnitDual(value(a)*value(b), mul_partials(partials(a), partials(b), value(b), value(a)))
/(a::UnitDual, b::UnitDual) = UnitDual(value(a)/value(b), mul_partials(partials(a), partials(b), inv(value(b)),-(value(a)/(value(b)*value(b)))))

# Binary operators for UnitDuals & Number
+(a::UnitDual, b::Number) = UnitDual(value(a) + b, partials(a))
+(a::Number, b::UnitDual) = b + a
-(a::UnitDual, b::Number) = UnitDual(value(a) - b, partials(a))
-(a::Number, b::UnitDual) = a + (-b)
*(a::UnitDual, b::Number) = UnitDual(value(a)*b, scale_partials(partials(a), b))
*(a::Number, b::UnitDual) = b*a
/(a::UnitDual, b::Number) = UnitDual(value(a)/b, scale_partials(partials(a), 1/b))
/(a::Number, b::UnitDual) = UnitDual(a/value(b), scale_partials(partials(b), -a/value(b)^2))
inv(a::UnitDual) =  UnitDual(inv(value(a)), scale_partials(partials(a), -1/value(a)^2))
^(a::UnitDual, b::Number) = UnitDual(value(a)^b, scale_partials(partials(a), b*value(a)^(b - 1)))

# Unary mathematical functions using DiffRules
for fun in (:sqrt, :cbrt, :abs, :abs2, :log, :log10, :log2, :exp, :sin, :cos, :tan, :sec, :csc, :cot,
            :acos, :atan, :asec, :acsc, :acot)
    f = :($fun(value(a)))
    fp = DiffRules.diffrule(:Base, fun, :(value(a)))
    @eval function $fun(a::UnitDual)
        UnitDual($f, scale_partials(partials(a), $fp))
    end
end


# Logical operators for UnitDuals
==(a::UnitDual, b::UnitDual) = value(a) == value(b)
==(a::UnitDual, b::Number) = value(a) == b
==(a::Number, b::UnitDual) = a == value(b)
isless(a::UnitDual, b::UnitDual) = isless(value(a), value(b))
isless(a::UnitDual, b::Number) = isless(value(a), b)
isless(a::Number, b::UnitDual) = isless(a, value(b))
isapprox(a::UnitDual, b::UnitDual) = value(a) ≈ value(b) && all(partials(a)[i] ≈ partials(b)[i] for i in 1:length(partials(a)))
isapprox(a::UnitDual, b::Number) = value(a) ≈ b
isapprox(a::Number, b::UnitDual) = a ≈ value(b)