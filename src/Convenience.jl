# Functions that take as first input a named tuple or dictionary with different values
# and as second argument


# Note: I copy the Dict -> Tuple transfrom from NamedTupleTools.jl as it was not dispatching to the correct method...
function initialize_dual(values::NamedTuple, names::NTuple)
    d = initialize_dual(NamedTupleTools.dictionary(values), names)
    parts = (d...,)
    names = first.(parts)
    vals  = last.(parts)
    return NamedTuple{names}(vals)
end

# Note: This function is type unstable
function initialize_dual(values::Dict, names)
    # Check the inputs
    @assert length(values) >= length(names)
    all_names = Symbol.(keys(values))
    for name in names
        @assert name in all_names
    end
    # Convert to UnitDual with partials
    ref_values = [values[name] for name in names]
    new_values = [initialize_dual(values, names, name, ref_values) for name in all_names]
    # Return as named tuple
    Dict(zip(all_names, new_values))
end

function initialize_dual(values, names, name, ref_values)
    val = values[name]
    partials_values = [zero(val/refval) for refval in ref_values]
    if name in names
        partials_values[findfirst(x -> x == name, names)] = 1.0
    end
    partials = UnitPartials(NamedTupleTools.namedtuple(names, partials_values))
    UnitDual(val, partials)
end