struct SetSolution
    solutionmatrix::BitMatrix
    n::Integer
    k::Integer

    function SetSolution(matrix::BitMatrix)
        return new(matrix, size(matrix, 2), size(matrix, 1))
    end

    function SetSolution(rows::Vector{<:Vector{<:Integer}})
        matrix = BitMatrix(
            map(
                x -> x > 0 ? 1 : 0,
                reduce(hcat, a)'
            ))

        return new(matrix, size(matrix, 2), size(matrix, 1))
    end
end

function getN(s::SetSolution)
    return s.n
end

function getK(s::SetSolution)
    return s.k
end