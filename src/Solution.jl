struct SetSolution
    solutionmatrix::BitMatrix
    n::Integer
    k::Integer

    function SetSolution(matrix::BitMatrix)
        return new(matrix, size(matrix, 1), size(matrix, 2))
    end

    function SetSolution(rows::Vector{<:Vector{<:Integer}})
        matrix = BitMatrix(
            map(
                x -> x > 0 ? 1 : 0,
                reduce(hcat, rows)'
            ))

        return new(matrix, size(matrix, 1), size(matrix, 2))
    end

    function SetSolution(rows::Vector{BitVector})
        matrix = BitMatrix(reduce(hcat, rows)')
        return new(matrix, size(matrix, 1), size(matrix, 2))
    end
end

function GetN(s::SetSolution)
    return s.n
end

function GetK(s::SetSolution)
    return s.k
end

function IsCorrect(s::SetSolution)
    for i in 1:GetN(s)
        for j in i+1:GetN(s)
            if s.solutionmatrix[i, :]' * s.solutionmatrix[j, :] != j - i
                return false
            end
        end
    end
    return true
end

function Base.getindex(s::SetSolution, row::Integer, column::Integer)
    if 1 ≤ row ≤ GetN(s) && 1 ≤ column ≤ GetK(s)
        return s.solutionmatrix[row, column]
    end
    throw(BoundsError(s.solutionmatrix, [row, column]))
end

function Base.show(io::IO, s::SetSolution)
    k = GetK(s)
    n = GetN(s)

    println(io, "SetSolution with n = $n and k = $k :")

    if n == 0
        return
    end

    # To make the output aligned, we calculate the maximum width a cell could need
    # The display of the chosen numbers in the sets takes up the number of digits as width
    cellwidth = 0

    if n != 1
        cellwidth = ceil(Int, log(10, k))
    end

    # The width of the first column is 1 + number of digits in the indices, the first one being for the 'A'
    setnumberingwidth = 1 + ceil(Int, log(10, n))

    for i in 1:n
        print(io, rpad("A" * SubscriptNumber(i), setnumberingwidth))
        print(io, ":")

        for j in 1:k
            print(io, " ")
            c = s[i, j] ? string(j) : ""
            print(io, lpad(c, cellwidth))
        end

        if i != n
            println(io, "")
        end
    end
end

function ASCIIPrintSolution(s::SetSolution)
    k = GetK(s)
    n = GetN(s)

    if n == 0
        return
    end

    # To make the output aligned, we calculate the maximum width a cell could need
    # The display of the chosen numbers in the sets takes up the number of digits as width
    cellwidth = 0

    if n != 1
        cellwidth = ceil(Int, log(10, k))
    end

    # The width of the first column is 1 + number of digits in the indices, the first one being for the 'A'
    setnumberingwidth = 1 + ceil(Int, log(10, n))

    for i in 1:n
        print(rpad("A_$i", setnumberingwidth))
        print(" = {")

        elements = []

        for j in 1:k
            if s[i, j]
                push!(elements, j)
            end
        end

        print(join(elements, ","))

        print("}")

        if i == n
            print(".")
            continue
        end

        print(",")
        println()
    end
end

# Taken from https://stackoverflow.com/a/64758370
function SubscriptNumber(i::Int)
    if i < 0
        c = [Char(0x208B)]
    else
        c = []
    end
    for d in reverse(digits(abs(i)))
        push!(c, Char(0x2080 + d))
    end
    return join(c)
end