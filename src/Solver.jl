using JuMP
using HiGHS

function solve(n::Integer, solver, arguments::Vector{Tuple{T,S}} where {T,S})
    model = Model(solver)

    for (attribute, value) in arguments
        set_attribute(model, attribute, value)
    end

    # TODO: add upper bound, warm start

    set_string_names_on_creation(model, false)

    sets_containing_i, sets_containing_i_and_j = precompute(n)

    @variable(model, sets[1:(2^n)] >= 0, Int)

    for i in 1:n
        for j in (i+1):n
            @constraint(model, sum(sets .* sets_containing_i_and_j[i, j, :]) == j - i)
        end
    end

    #= 
    Elements can only be contained in at most 5 sets.
    Heuristically, this produces at least one optimal solution for all n <= 25

    for i in 1:2^n
        if count_ones(i) > 5
            @constraint(model, sets[i] == 0)
        end
    end
    =#

    @constraint(model, sets[2^n] == 0)

    @objective(model, Min, sum(sets))

    optimize!(model)


    return convertToSetSolution(n, round(Int, objective_value(model)), [round(Int, value(x)) for x in all_variables(model)])
end

solve(n::Integer) = solve(n, HiGHS.Optimizer, [("presolve", "off"), ("mip_max_leaves", 100)])
solve(n::Integer, solver) = solve(n, solver, Tuple{Any,Any}[])

function precompute(n::Integer)
    sets_containing_i = falses(n, 2^n)
    sets_containing_i_and_j = falses(n, n, 2^n)

    for i in 1:n
        i_vector = falses(n)
        i_vector[i] = true

        for j in (i+1):n
            j_vector = falses(n)
            j_vector[j] = true

            for index in 1:(2^n-1)
                bitvector = transpose(BitVector(digits(index, base=2, pad=n)))

                if bitvector * i_vector == 1
                    sets_containing_i[i, index] = true
                end

                if bitvector * j_vector == 1
                    sets_containing_i[j, index] = true
                end

                if bitvector * (i_vector + j_vector) == 2
                    sets_containing_i_and_j[i, j, index] = true
                end
            end
        end
    end

    return sets_containing_i, sets_containing_i_and_j
end

function convertToSetSolution(n::Integer, k::Integer, sets)
    curr_index = 1
    solution = falses(n, k)

    for (subset, number_of_elements) in enumerate(sets)
        if number_of_elements == 0
            continue
        end

        subsetvector = transpose(BitVector(digits(subset, base=2, pad=n)))

        for setnumber in 1:n
            setvector = falses(n)
            setvector[setnumber] = true

            if subsetvector * setvector == 1
                for k in 0:number_of_elements-1
                    solution[setnumber, curr_index+k] = true
                end
            end
        end

        curr_index += number_of_elements
    end

    return SetSolution(sortslices(solution, dims=2, rev=true))
end