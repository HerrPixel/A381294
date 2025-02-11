using JuMP
using GLPK

function solve(n::Integer)
    model = Model(GLPK.Optimizer)

    sets_containing_i, sets_containing_i_and_j = precompute(n)

    @variable(model, sets[1:(2^n)] >= 0, Int)

    for i in 1:n
        for j in (i+1):n
            @constraint(model, sum(sets .* sets_containing_i_and_j[i, j, :]) == j - i)
        end
    end

    @constraint(model, sets[2^n] == 0)

    @objective(model, Min, sum(sets))

    optimize!(model)

    return solution_summary(model)
end

function precompute(n::Integer)
    sets_containing_i = falses(n, 2^n)
    sets_containing_i_and_j = falses(n, n, 2^n)

    for i in 1:n
        i_vector = falses(n)
        i_vector[i] = true

        if y

        end

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