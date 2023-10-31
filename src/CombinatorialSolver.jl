const EquivalenceClasses = Vector{<:Vector{<:Integer}}

function trivialClasses(k::Integer)
    return [collect(1:k)]
end

function splitEquivalenceClasses(c::EquivalenceClasses, b::BitVector)
    resultingClasses = empty(c)

    for class in c
        chosenElements = empty(class)
        rejectedElements = empty(class)

        for i in class
            if b[i]
                push!(chosenElements, i)
            else
                push!(rejectedElements, i)
            end
        end

        if !isempty(chosenElements)
            push!(resultingClasses, chosenElements)
        end

        if !isempty(rejectedElements)
            push!(resultingClasses, rejectedElements)
        end
    end

    return resultingClasses
end

function CombinatorialSolver(n::Integer, k::Integer, printAllSolutions=false)
    lowerBounds, upperBounds = calculateBounds(n, k)
    return CombinatorialSolverRecursion(
        n,
        k,
        lowerBounds,
        upperBounds,
        trivialClasses(k),
        Vector{BitVector}(),
        Vector{SetSolution}(),
        printAllSolutions
    )
end

function CombinatorialSolverRecursion(
    N::Integer,
    K::Integer,
    lowerBounds::Vector{<:Integer},
    upperBounds::Vector{<:Integer},
    DigitEquivalenceClasses::EquivalenceClasses,
    Layers::Vector{BitVector},
    #CurrentLayer::PartialLayer,
    #CurrentLayerIndex::Integer,
    #ReferenceLayerIndex::Integer,
    Solutions::Vector{SetSolution},
    printAllSolutions::Bool
)

    if length(Layers) == N
        push!(Solutions, SetSolution(Layers))
        return Solutions
    end

    for b in NextLayers(Layers, DigitEquivalenceClasses, K, lowerBounds[length(Layers)+1], upperBounds[length(Layers)+1])

        #LayersCopy = copy(Layers)
        push!(Layers, b)

        eqClasses = splitEquivalenceClasses(DigitEquivalenceClasses, b)

        Solutions = CombinatorialSolverRecursion(N, K, lowerBounds, upperBounds, eqClasses, Layers, Solutions, printAllSolutions)

        if !isempty(Solutions) && !printAllSolutions
            return Solutions
        end

        pop!(Layers)
    end

    return Solutions
end

function NextLayers(
    Layers::Vector{BitVector},
    DigitEquivalenceClasses::EquivalenceClasses,
    k::Integer,
    LowerBoundForFreeElements::Integer,
    UpperBoundForFreeElements::Integer
)
    return NextLayersRecursion(
        Layers,
        DigitEquivalenceClasses,
        1,
        Vector{BitVector}(), # possible next Layers
        falses(k), # temporary variable to store currently building layer
        zeros(Int, length(Layers)), # temporary variable to store current overlap with previous layers
        !mapreduce(x -> x[end], |, Layers, init=false), # if no previous layer has chosen the last element, we have still have an unchosen equivalence class
        LowerBoundForFreeElements,
        UpperBoundForFreeElements
    )
end

function NextLayersRecursion(
    Layers::Vector{BitVector},
    DigitEquivalenceClasses::EquivalenceClasses,
    CurrentClassIndex::Integer,
    Solutions::Vector{BitVector},
    CurrentCombination::BitVector,
    CurrentOverlaps::Vector{<:Integer},
    HasFreeElements::Bool,
    LowerBoundForFreeElements::Integer,
    UpperBoundForFreeElements::Integer
)

    # we have chosen for every equivalence class, now we need to verify our solution
    if CurrentClassIndex > length(DigitEquivalenceClasses)
        for j in 1:length(CurrentOverlaps)

            if CurrentOverlaps[end-(j-1)] != j
                return Solutions
            end

        end
        push!(Solutions, CurrentCombination)
        return Solutions
    end

    # if we still have free elements, choose an appropriate amount
    if CurrentClassIndex == length(DigitEquivalenceClasses) && HasFreeElements

        # premature verification of our solution
        for j in 1:length(CurrentOverlaps)
            if CurrentOverlaps[end-(j-1)] != j
                return Solutions
            end
        end

        for i in LowerBoundForFreeElements:min(UpperBoundForFreeElements, length(DigitEquivalenceClasses[end]))

            CurrentCombinationCopy = copy(CurrentCombination)

            for j in 1:i
                CurrentCombinationCopy[DigitEquivalenceClasses[end][j]] = true
            end

            push!(Solutions, CurrentCombinationCopy)
        end

        return Solutions
    end

    # otherwise pick some elements of the current equivalence class that do not oversaturate the overlap
    for i in 0:length(DigitEquivalenceClasses[CurrentClassIndex])

        CurrentCombinationCopy = copy(CurrentCombination)
        CurrentOverlapsCopy = copy(CurrentOverlaps)

        for j in 1:i
            # pick the chosen element
            CurrentCombinationCopy[DigitEquivalenceClasses[CurrentClassIndex][j]] = true

            # add the now gained overlap to our Vector
            CurrentOverlapsCopy += map(x -> x[DigitEquivalenceClasses[CurrentClassIndex][j]], Layers)
        end

        # check, that we didn't oversaturate 
        isValid = true
        for j in 1:length(CurrentOverlapsCopy)
            if CurrentOverlapsCopy[end-(j-1)] > j
                isValid = false
                break
            end
        end

        if !isValid
            break
        end

        Solutions = NextLayersRecursion(
            Layers,
            DigitEquivalenceClasses,
            CurrentClassIndex + 1,
            Solutions,
            CurrentCombinationCopy,
            CurrentOverlapsCopy,
            HasFreeElements,
            LowerBoundForFreeElements,
            UpperBoundForFreeElements)
    end

    return Solutions
end

# see our document for the validity of this bound
function calculateBounds(n::Integer, k::Integer)
    lowerBounds = Vector{Int}()
    upperBounds = Vector{Int}()

    for i in 1:n
        lowerBound = -1 * triangularNumber(i - 1)
        for j in 0:div(n, 2)
            lowerBound += max(0, n - i - j - triangularNumber(j))
        end
        push!(lowerBounds, max(0, lowerBound))
    end

    for i in 1:n
        push!(upperBounds, k - sum(lowerBounds) + lowerBounds[i])
    end

    return lowerBounds, upperBounds
end

function triangularNumber(n::Integer)
    return n * (n + 1) / 2
end