using UnitfulDual
using Unitful
using Test
using Suppressor

@testset "UnitfulDual.jl" begin

    # Creation of UnitDual numbers with tuple and args
    a = 1.0u"mol/L"
    da = UnitDual(a, 1.0)
    da2 = UnitDual(a, (1.0, ))
    @test da === da2
    @test da isa UnitDual
    @test value(da) === a
    @test partials(da) === UnitPartials((1.0))

    # Dual numbers with several partials
    a = 1.0u"mol/L"
    b = 0.5u"mol/L"
    c = 1.0u"1/s"
    da = UnitDual(a, 1.0, 0.0, zero(a/c))
    db = UnitDual(b, 0.0, 1.0, zero(b/c))
    dc = UnitDual(c, zero(c/a), zero(c/b), 1.0)
    @test length(partials(da)) == 3
    @test partials(da)[1] == 1.0
    @test partials(da)[3] isa Quantity

    du = UnitDual(1.0, 1.0)

    # Addition of Dual Numbers
    dd = da + db
    @test dd isa UnitDual
    @test length(partials(dd)) == 3
    @test value(dd) == a + b
    @test partials(dd) === UnitPartials(1.0, 1.0, zero(a/c))
    @test_throws Unitful.DimensionError da + dc
    @test_throws Unitful.DimensionError da + 1
    ddu = du + 1.0
    @test value(ddu) == 2.0
    @test partials(ddu) === UnitPartials(1.0)
    @test du + 1.0 === 1.0 + du


    # Substraction of Dual Numbers
    dd = da - db
    @test dd isa UnitDual
    @test length(partials(dd)) == 3
    @test value(dd) == a - b
    @test partials(dd) === UnitPartials(1.0, -1.0, zero(a/c))
    @test_throws Unitful.DimensionError da - dc
    @test_throws Unitful.DimensionError da - 1
    ddu = du - 1.0
    @test value(ddu) == 0.0
    @test partials(ddu) === UnitPartials(1.0)
    ddu = 1.0 - du
    @test value(ddu) == 0.0
    @test partials(ddu) === UnitPartials(-1.0)

    # Negation of Dual Numbers
    dd = -da
    @test dd isa UnitDual
    @test length(partials(dd)) == 3
    @test value(dd) == -a
    @test partials(dd) === UnitPartials((-t for t in partials(da))...)

    # Multiplication of Dual Numbers
    dd = da*db
    @test dd isa UnitDual
    @test length(partials(dd)) == 3
    @test value(dd) == a*b
    @test partials(dd) === UnitPartials(b, a, zero(a*b/c))
    ddr = da*3
    ddl = 3*da
    @test ddr === ddl
    @test ddr isa UnitDual
    @test value(ddr) == 3*a
    @test partials(ddr) == UnitPartials((3*t for t in partials(da))...)
    ddu = du*3
    @test value(ddu) == 3.0
    @test partials(ddu) === UnitPartials(3.0)

    # Division of Dual Numbers
    dd = da/db
    @test dd isa UnitDual
    @test length(partials(dd)) == 3
    @test value(dd) == a/b
    @test partials(dd) === UnitPartials(1/b, -a/b^2, zero(1/c))
    ddr = da/2
    ddl = 2/da
    @test typeof(ddr) != typeof(ddl)
    @test value(ddr) == a/2
    @test value(ddl) == 2/a
    @test partials(ddr) === UnitPartials((t/2 for t in partials(da))...)
    @test partials(ddl) === UnitPartials((-2/a^2*t for t in partials(da))...)
    ddur = du/3
    ddul = 3/du
    @test typeof(ddur) == typeof(ddul)
    @test value(ddur) == 1/3
    @test value(ddul) == 3.0
    @test partials(ddur) === UnitPartials(1/3)
    @test partials(ddul) === UnitPartials(-3.0)
    @test inv(db) === 1/db

    # Power
    dd = db^2
    @test dd isa UnitDual
    @test value(dd) === b^2
    @test partials(dd) === UnitPartials((2*b*t for t in partials(db))...)

    # Logical operators
    @test da >= db
    @test da >= b
    @test_throws Unitful.DimensionError da >= b.val
    @test db <= da
    @test b <= da
    @test_throws Unitful.DimensionError b.val <= da
    @test da == 2*db
    @test da == 2*b
    @test da ≈ UnitDual(a*(1.0 +  + eps(Float64)), 1.0, 0.0, zero(a/c))
    @test da != 2*b.val
    @test du >= 0.5
    @test du <= 1.5
    @test 0.5 <= du
    @test du == 1.0
    @test 1.0 == du
    @test du ≈ 1.0 + eps(Float64)
    @test 1.0 + eps(Float64) ≈ du

    # Unary mathematical functions (most of them only works with unitless variables)
    @test sqrt(db) ≈ db^(1//2)
    @test cbrt(db) ≈ db^(1//3)
    @test abs(-db) === db
    @test abs2(-db) === db^2
    @test_throws MethodError log(db)
    @test log(du) == log(1.0)
    @test_throws MethodError log10(db)
    @test log10(du) == log10(1.0)
    @test_throws MethodError log2(db)
    @test log2(du) == log2(1.0)
    @test_throws MethodError exp(db)
    @test exp(du) == exp(1.0)
    @test_throws MethodError sin(db)
    @test sin(du) == sin(1.0)
    @test_throws MethodError cos(db)
    @test cos(du) == cos(1.0)
    @test_throws MethodError tan(db)
    @test tan(du) == tan(1.0)
    @test_throws MethodError sec(db)
    @test sec(du) == sec(1.0)
    @test_throws MethodError csc(db)
    @test csc(du) == csc(1.0)
    @test_throws MethodError cot(db)
    @test cot(du) == cot(1.0)
    @test_throws MethodError acos(db)
    @test acos(du) == acos(1.0)
    @test_throws MethodError atan(db)
    @test atan(du) == atan(1.0)
    @test_throws MethodError asec(db)
    @test asec(du) == asec(1.0)
    @test_throws MethodError acsc(db)
    @test acsc(du) == acsc(1.0)
    @test_throws MethodError acot(db)
    @test acot(du) == acot(1.0)

    # Printing
    printdual = @capture_out print(da)
    @test '{' in printdual
    @test occursin("mol" , printdual)
    
end
