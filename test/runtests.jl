using UnitfulDual
using Unitful
using Test
using Suppressor

@testset "UnitfulDual.jl" begin

    # Creation of UnitDual numbers with tuple and args - unnamed
    a = 1.0u"mol/L"
    da = UnitDual(a, 1.0)
    da2 = UnitDual(a, (1.0, ))
    @test da === da2
    @test da isa UnitDual
    @test value(da) === a
    @test partials(da) === UnitPartials((1.0))

    # Creation of UnitDual numbers with tuple and args - named
    nda = UnitDual(a, a = 1.0)
    @test nda isa UnitDual
    @test value(nda) === a
    @test partials(nda) === UnitPartials((a = 1.0,))

    # Dual numbers with several partials - unnamed
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

    # Dual numbers with several partials - named
    nda = UnitDual(a, a = 1.0, b = 0.0, c = zero(a/c))
    ndb = UnitDual(b, a = 0.0, b = 1.0, c = zero(b/c))
    ndc = UnitDual(c, a = zero(c/a), b = zero(c/b), c = 1.0)
    @test length(partials(nda)) == 3
    @test partials(nda)[1] == 1.0
    @test partials(nda)[3] isa Quantity

    ndu = UnitDual(1.0, u = 1.0)

    # Addition of Dual Numbers - unnamed
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

    # Addition of Dual Numbers - named
    ndd = nda + ndb
    @test ndd isa UnitDual
    @test length(partials(ndd)) == 3
    @test value(ndd) == a + b
    @test partials(ndd) === UnitPartials(a = 1.0, b = 1.0, c = zero(a/c))
    @test_throws Unitful.DimensionError nda + ndc
    @test_throws Unitful.DimensionError nda + 1
    nddu = ndu + 1.0
    @test value(nddu) == 2.0
    @test partials(nddu) === UnitPartials(u = 1.0)
    @test ndu + 1.0 === 1.0 + ndu

    # Substraction of Dual Numbers - unnamed
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

    # Substraction of Dual Numbers - named
    ndd = nda - ndb
    @test ndd isa UnitDual
    @test length(partials(ndd)) == 3
    @test value(ndd) == a - b
    @test partials(ndd) === UnitPartials(a = 1.0, b = -1.0, c = zero(a/c))
    @test_throws Unitful.DimensionError nda - ndc
    @test_throws Unitful.DimensionError nda - 1
    nddu = ndu - 1.0
    @test value(nddu) == 0.0
    @test partials(nddu) === UnitPartials(u = 1.0)
    nddu = 1.0 - ndu
    @test value(nddu) == 0.0
    @test partials(nddu) === UnitPartials(u = -1.0)

    # Negation of Dual Numbers - unnamed
    dd = -da
    @test dd isa UnitDual
    @test length(partials(dd)) == 3
    @test value(dd) == -a
    @test partials(dd) === UnitPartials((-t for t in partials(da))...)

    # Negation of Dual Numbers - named
    ndd = -nda
    @test ndd isa UnitDual
    @test length(partials(ndd)) == 3
    @test value(ndd) == -a
    @test partials(ndd) === UnitPartials(a = -partials(nda).a, 
                    b = -partials(nda).b, c = -partials(nda).c)


    # Multiplication of Dual Numbers - unnamed
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


    # Multiplication of Dual Numbers - named
    ndd = nda*ndb
    @test ndd isa UnitDual
    @test length(partials(ndd)) == 3
    @test value(ndd) == a*b
    @test partials(ndd) === UnitPartials(a = b, b = a, c = zero(a*b/c))
    nddr = nda*3
    nddl = 3*nda
    @test nddr === nddl
    @test nddr isa UnitDual
    @test value(nddr) == 3*a
    @test partials(nddr) == UnitPartials(a = 3*partials(nda).a, 
    b = 3*partials(nda).b, c = 3*partials(nda).c)
    nddu = ndu*3
    @test value(nddu) == 3.0
    @test partials(nddu) === UnitPartials(u = 3.0)

    # Division of Dual Numbers - unnamed
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

    # Division of Dual Numbers - named
    ndd = nda/ndb
    @test ndd isa UnitDual
    @test length(partials(ndd)) == 3
    @test value(ndd) == a/b
    @test partials(ndd) === UnitPartials(a = 1/b, b = -a/b^2, c = zero(1/c))
    nddr = nda/2
    nddl = 2/da
    @test typeof(nddr) != typeof(nddl)
    nddur = ndu/3
    nddul = 3/ndu
    @test typeof(nddur) == typeof(nddul)
    @test value(nddur) == 1/3
    @test value(nddul) == 3.0
    @test partials(nddur) === UnitPartials(u = 1/3)
    @test partials(nddul) === UnitPartials(u = -3.0)
    @test inv(ndb) === 1/ndb

    # Power - unnamed
    dd = db^2
    @test dd isa UnitDual
    @test value(dd) === b^2
    @test partials(dd) === UnitPartials((2*b*t for t in partials(db))...)

    # Power - named
    ndd = ndb^2
    @test ndd isa UnitDual
    @test value(ndd) === b^2
    @test partials(ndd) === UnitPartials(a = 2*b*partials(ndb).a, 
                    b = 2*b*partials(ndb).b, c = 2*b*partials(ndb).c)


    # Logical operators - unnamed
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


    # Logical operators - named
    @test nda >= ndb
    @test nda >= b
    @test_throws Unitful.DimensionError nda >= b.val
    @test ndb <= nda
    @test b <= nda
    @test_throws Unitful.DimensionError b.val <= nda
    @test nda == 2*ndb
    @test nda == 2*b
    @test nda ≈ UnitDual(a*(1.0 +  + eps(Float64)), a = 1.0, b = 0.0, c = zero(a/c))
    @test nda != 2*b.val
    @test ndu >= 0.5
    @test ndu <= 1.5
    @test 0.5 <= ndu
    @test ndu == 1.0
    @test 1.0 == ndu
    @test ndu ≈ 1.0 + eps(Float64)
    @test 1.0 + eps(Float64) ≈ ndu


    # Unary mathematical functions (most of them only works with unitless variables) - unnamed
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

    # Unary mathematical functions (most of them only works with unitless variables) - named
    @test sqrt(ndb) ≈ ndb^(1//2)
    @test cbrt(ndb) ≈ ndb^(1//3)
    @test abs(-ndb) === ndb
    @test abs2(-ndb) === ndb^2
    @test_throws MethodError log(ndb)
    @test log(ndu) == log(1.0)
    @test_throws MethodError log10(ndb)
    @test log10(ndu) == log10(1.0)
    @test_throws MethodError log2(ndb)
    @test log2(ndu) == log2(1.0)
    @test_throws MethodError exp(ndb)
    @test exp(ndu) == exp(1.0)
    @test_throws MethodError sin(ndb)
    @test sin(ndu) == sin(1.0)
    @test_throws MethodError cos(ndb)
    @test cos(ndu) == cos(1.0)
    @test_throws MethodError tan(ndb)
    @test tan(ndu) == tan(1.0)
    @test_throws MethodError sec(ndb)
    @test sec(ndu) == sec(1.0)
    @test_throws MethodError csc(ndb)
    @test csc(ndu) == csc(1.0)
    @test_throws MethodError cot(ndb)
    @test cot(ndu) == cot(1.0)
    @test_throws MethodError acos(ndb)
    @test acos(ndu) == acos(1.0)
    @test_throws MethodError atan(ndb)
    @test atan(ndu) == atan(1.0)
    @test_throws MethodError asec(ndb)
    @test asec(ndu) == asec(1.0)
    @test_throws MethodError acsc(ndb)
    @test acsc(ndu) == acsc(1.0)
    @test_throws MethodError acot(ndb)
    @test acot(ndu) == acot(1.0)

    # Printing - unnamed
    printdual = @capture_out print(da)
    @test '{' in printdual
    @test occursin("mol" , printdual)

    # Printing - named
    printdual = @capture_out print(nda)
    @test '{' in printdual
    @test '=' in printdual
    @test occursin("mol" , printdual)
    
    # Convenience functions  - unnamed
    da0 = zero(da)
    @test da0 isa UnitDual
    @test value(da0) === zero(a)
    @test partials(da0) === UnitPartials((zero(p) for p in partials(da))...)
    @test zeros(typeof(da), 2) == [da0, da0]
    @test zeros(typeof(da), 2)  == [da0, da0]

    # Convenience functions  - named
    nda0 = zero(nda)
    @test nda0 isa UnitDual
    @test value(nda0) === zero(a)
    # The following tests have some issues with conversion of FreeUnits into Float64
    @test_broken partials(nda0) == UnitPartials(a = zero(a/a), b = zero(a/b), c = zero(a/c))
    @test_broken zeros(typeof(nda), 2) == [nda0, nda0]
    @test_broken zeros(typeof(nda), 2)  == [nda0, nda0]

    # Iteration- unnamed
    @test length(da) === 1
    @test da.*[1,2] == [da, 2*da]

    # Iteration- named
    @test length(nda) === 1
    @test nda.*[1,2] == [nda, 2*nda]

end
