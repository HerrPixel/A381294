global happened = false

function isSolution(solution::BitMatrix)
    for i in axes(solution, 1)
        for j in i+1:size(solution, 1)
            if solution[i, :]' * solution[j, :] != j - i
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
    cellWidth = ceil(Int, log(10, width))

    print(lpad("", cellWidth))
    for i in 1:width
        print("|")
        print(lpad(string(i), cellWidth))
    end
    println()
    print(lpad("", width * (cellWidth + 1) + cellWidth, '-'))

    for i in 1:height
        println()
        print(lpad(string(i), cellWidth))
        for j in 1:width
            print("|")
            c = solution[i, j] ? string(j) : ""
            print(lpad(c, cellWidth))
        end
    end
end

function BruteForceSearch(n::Integer, k::Integer)
    solutions = Vector{BitMatrix}()
    vectors = Vector{Vector{<:Integer}}()
    for i in 0:2^k-1
        push!(vectors, digits(i, base=2, pad=k))
    end

    combinations = Vector{Vector{<:Integer}}()
    for i in 0:length(vectors)^n-1
        push!(combinations, digits(i, base=length(vectors), pad=n))
    end

    for x in combinations
        z = Vector{Vector{<:Integer}}()
        for i in x
            push!(z, vectors[i+1])
        end
        y = vcat(transpose.(z)...)
        correct = true

        for i in 1:n
            for j in i+1:n
                if y[i, :]' * y[j, :] != j - i
                    correct = false
                end
            end
        end

        if correct
            push!(solutions, BitArray(y))
        end
    end

    return solutions
end

function canonicalize(solution::BitMatrix)
    numbering = [collect(1:size(solution, 2))]
    for i in axes(solution, 1)

        newNumbering = empty(numbering)
        for s in eachindex(numbering)
            set = numbering[s]
            intersection = empty(set)
            complement = empty(set)
            for j in set
                if solution[i, j]
                    push!(intersection, j)
                else
                    push!(complement, j)
                end
            end

            if !isempty(intersection)
                push!(newNumbering, intersection)
            end

            if !isempty(complement)
                push!(newNumbering, complement)
            end

        end

        numbering = newNumbering
    end

    target = collect(Iterators.flatten(numbering))

    result = BitMatrix(undef, size(solution, 1), 0)
    for i in target
        result = hcat(result, solution[:, i])
    end

    return result
end

function shrink(solution::BitMatrix)
    result = Vector{BitMatrix}()
    for i in axes(solution, 1)
        target = solution[1:size(solution, 1).≠i, :]

        important = Vector{Integer}()
        for j in axes(target, 2)
            if sum(target[:, j]) != 1
                push!(important, j)
            end
        end

        target = target[:, important]
        if isSolution(target)
            push!(result, target)
        end
    end

    return result
end

function splitSets(sets::Vector{<:Vector{<:Integer}}, entry::BitVector)
    #println("here")
    #println(sets)
    #println(entry)
    newNumbering = empty(sets)
    for s in eachindex(sets)
        set = sets[s]
        intersection = empty(set)
        complement = empty(set)
        for j in set
            if entry[j]
                push!(intersection, j)
            else
                push!(complement, j)
            end
        end

        if !isempty(intersection)
            push!(newNumbering, intersection)
        end

        if !isempty(complement)
            push!(newNumbering, complement)
        end

    end

    return newNumbering
end

function splitSets(sets::Vector{<:Vector{<:Integer}}, entry::Vector{<:Integer})
    newNumbering = empty(sets)
    for s in eachindex(sets)
        set = sets[s]
        intersection = empty(set)
        complement = empty(set)
        cocaCola = empty(set)
        for j in set
            if entry[j] == -1
                push!(intersection, j)
            elseif entry[j] == 1
                push!(complement, j)
            else
                push!(cocaCola, j)
            end
        end

        if !isempty(intersection)
            push!(newNumbering, intersection)
        end

        if !isempty(complement)
            push!(newNumbering, complement)
        end

        if !isempty(cocaCola)
            push!(newNumbering, cocaCola)
        end

    end

    return newNumbering
end

function uniqueSolutions(n::Integer, k::Integer)
    allSolutions = BruteForceSearch(n, k)
    result = Set{BitMatrix}()
    for s in allSolutions
        push!(result, canonicalize(s))
    end
    return result
end

function smartSolutionFinder(n::Integer, k::Integer)
    template = falses(k, n)

    return SatisfyLayer([collect(1:k)], zeros(Int, k), template, 1, n, 1, Vector{BitMatrix}(), k)
end

function SatisfyLayer(sets::Vector{<:Vector{<:Integer}}, chosen::Vector{<:Integer}, currSolution::BitMatrix, depth::Integer, maxdepth::Integer, curr::Integer, solutions::Vector{<:BitMatrix}, k::Integer)

    if depth == maxdepth == curr
        currSolution[:, depth] = normalize(chosen)
        printSolution(BitMatrix(currSolution'))
        #push!(solutions, currSolution)
        #return solutions
        return true
    end

    if depth == curr

        newSets2 = splitSets(sets, chosen)

        zeroIndex = findfirst(x -> chosen[x[1]] == 0, newSets2)

        zeroSet = isnothing(zeroIndex) ? Vector{Int8}() : newSets2[zeroIndex]

        #println(zeroSet)
        for i in 0:length(zeroSet)
            entryCopy = copy(chosen)
            currSolutionCopy = copy(currSolution)



            for j in eachindex(zeroSet)
                entryCopy[zeroSet[j]] = j <= i ? 1 : -1
            end

            currSolutionCopy[:, depth] = normalize(entryCopy)
            newSets = splitSets(sets, currSolutionCopy[:, depth])

            #solutions = SatisfyLayer(newSets, zeros(Int, k), currSolutionCopy, depth + 1, maxdepth, 1, solutions, k)

            if SatisfyLayer(newSets, zeros(Int, k), currSolutionCopy, depth + 1, maxdepth, 1, solutions, k)
                return true
            end
        end


        #return solutions
        return false
    end

    remaining = depth - curr - overlap(normalize(chosen), currSolution[:, curr])

    if remaining < 0
        #return solutions
        return false
    end

    #if remaining == 0

    #    return SatisfyLayer(sets, chosen, currSolution, depth, maxdepth, curr + 1, solutions, k)
    #end

    choosable = beepBoop(sets, currSolution[:, curr], chosen)
    sizes = map(x -> length(x), choosable)
    combinations = CombinationChoices(remaining, sizes)

    for c in combinations

        entryCopy = copy(chosen)

        for setIndex in eachindex(choosable)
            set = choosable[setIndex]
            for i in eachindex(set)
                entryCopy[set[i]] = (i <= c[setIndex]) ? 1 : -1
            end
        end

        #maybe even split the -1 and 0
        newSets = splitSets(sets, normalize(entryCopy))
        #solutions = SatisfyLayer(newSets, entryCopy, currSolution, depth, maxdepth, curr + 1, solutions, k)

        if SatisfyLayer(newSets, entryCopy, currSolution, depth, maxdepth, curr + 1, solutions, k)
            return true
        end
    end

    #return solutions
    return false
end

function lol(a::BitVector, b::Vector{<:Integer})
    count = 0
    for j in eachindex(b)
        if a[j] && b[j] == 0
            count += 1
        end
    end
    return count
end

function CombinationChoices(number::Integer, sizes::Vector{<:Integer})
    return recursiveCombinations(number, 0, Vector{Vector{Int}}(), sizes, 1, Vector{Int}())
end

function recursiveCombinations(target::Integer, current::Integer, solutions::Vector{<:Vector{<:Integer}}, sizes::Vector{<:Integer}, index::Integer, combination::Vector{<:Integer})
    if current > target
        return solutions
    end

    if index > length(sizes)
        if current == target
            push!(solutions, combination)
        end
        return solutions
    end

    for i in 0:sizes[index]
        c = copy(combination)
        push!(c, i)
        solutions = recursiveCombinations(target, current + i, solutions, sizes, index + 1, c)
    end

    return solutions
end

function overlap(a::BitVector, b::BitVector)
    return a' * b
end

function beepBoop(sets::Vector{<:Vector{<:Integer}}, selected::BitVector, entries::Vector{<:Integer})
    result = empty(sets)
    for s in sets
        intersect = empty(s)
        for i in s
            if selected[i] && entries[i] == 0
                push!(intersect, i)
            end
        end
        if !isempty(intersect)
            push!(result, intersect)
        end
    end
    return result
end

function normalize(vec::Vector{<:Integer})
    return BitVector(map(x -> x == 1 ? 1 : 0, vec))
end

function getUnclaimed(target::BitVector, claimer::Vector{<:Integer})

end
# memory leak in uniqueSolutions

#smartSolutionFinder(6, 15)