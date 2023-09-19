function isSolution(solution::BitMatrix)
    for i in axes(solution,1)
        for j in i+1:size(solution,1)
            if solution[i,:]' * solution[j,:] != j-i
                return false
            end
        end
    end
    return true
end

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

function canonicalize(solution::BitMatrix) 
    numbering = [collect(1:size(solution,2))]
    for i in axes(solution,1)

        newNumbering = empty(numbering)
        for s in eachindex(numbering)
            set = numbering[s]
            intersection = empty(set)
            complement = empty(set)
            for j in set
                if solution[i,j]
                    push!(intersection,j)
                else
                    push!(complement,j)
                end
            end

            if !isempty(intersection) 
                push!(newNumbering,intersection)
            end

            if !isempty(complement) 
                push!(newNumbering,complement)
            end

        end

        numbering = newNumbering
    end

    target = collect(Iterators.flatten(numbering))

    result = BitMatrix(undef,size(solution,1),0)
    for i in target
        result = hcat(result,solution[:,i])
    end

    return result
end

function shrink(solution::BitMatrix)
    result = Vector{BitMatrix}()
    for i in axes(solution,1)
        target = solution[1:size(solution,1) .≠ i, :]

        important = Vector{Integer}()
        for j in axes(target,2)
            if sum(target[:,j]) != 1
                push!(important,j)
            end
        end

        target = target[:,important]
        if isSolution(target)
            push!(result,target)
        end
    end

    return result
end

function uniqueSolutions(n::Integer,k::Integer)
    allSolutions = BruteForceSearch(n,k)
    result = Set{BitMatrix}()
    for s in allSolutions
        push!(result,canonicalize(s))
    end
    return result
end