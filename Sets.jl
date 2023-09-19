using Combinatorics

function printSolution(solution::BitMatrix)
    sizes = size(solution)
    height = sizes[1]
    width = sizes[2]
    cellWidth = ceil(Int,log(10,width))

    print(lpad("",cellWidth))
    for i in 1:width
        print("|")
        print(lpad(string(i),cellWidth))
    end
    println()
    print(lpad("",width * (cellWidth + 1) + cellWidth, '-'))

    for i in 1:height
        println()
        print(lpad(string(i),cellWidth))
        for j in 1:width
            print("|")
            c = solution[i,j] ? string(j) : ""
            print(lpad(c,cellWidth))
        end
    end
end 

function BruteForceSearch(n::Integer,k::Integer) 
    solutions = Vector{BitMatrix}()
    vectors = Vector{Vector{<:Integer}}()
    for i in 0:2^k-1
        push!(vectors,digits(i,base = 2, pad=k))
    end

    combinations = Vector{Vector{<:Integer}}()
    for i in 0:length(vectors)^n-1
        push!(combinations,digits(i,base=length(vectors),pad=n))
    end

    for x in combinations
        z = Vector{Vector{<:Integer}}()
        for i in x
            push!(z,vectors[i+1])
        end
        y = vcat(transpose.(z)...)
        correct = true

        for i in 1:n
            for j in i+1:n
                if y[i,:]' * y[j,:] != j-i
                    correct = false
                end 
            end
        end

        if correct
            push!(solutions,BitArray(y))
        end
    end

    return solutions
end

