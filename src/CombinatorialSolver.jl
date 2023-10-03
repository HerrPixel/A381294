struct EquivalenceClasses
    classes::Vector{<:Vector{<:Integer}}

    function EquivalenceClasses(v::Vector{<:Vector{<:Integer}})
        return new(v)
    end
end

function Base.length(c::EquivalenceClasses)
    return Base.length(c.classes)
end

function Base.lastindex(c::EquivalenceClasses)
    return Base.lastindex(c.classes)
end

function Base.getindex(c::EquivalenceClasses, i::Integer)
    return c.classes[i]
end

mutable struct PartialLayer
    layer::Vector{<:Integer}

    function PartialLayer(v::Vector{<:Integer})
        return new(v)
    end
end

function chosen(p::PartialLayer, i::Integer)
    return p.layer[i] > 0
end

function undecided(p::PartialLayer, i::Integer)
    return p.layer[i] == 0
end

function rejected(p::PartialLayer, i::Integer)
    return p.layer[i] < 0
end

function set!(p::PartialLayer, i::Integer, v::Integer)
    p.layer[i] = v
end

function Base.setindex!(p::PartialLayer, v::Integer, i::Integer)
    set!(p, i, v)
end

function normalize(p::PartialLayer)
    b = falses(length(p.layer))

    for i in 1:length(p.layer)
        b[i] = chosen(p, i)
    end
    return b
end

function overlap(a::BitVector, b::BitVector)
    return a' * b
end

function choosableEquivalenceClasses(p::PartialLayer, referenceLayer::BitVector, classes::EquivalenceClasses)
    resultingClasses = empty(classes.classes)
    for class in classes.classes
        if referenceLayer[class[1]] && undecided(p, class[1])
            push!(resultingClasses, class)
        end
    end
    return EquivalenceClasses(resultingClasses)
end

function splitEquivalenceClasses(c::EquivalenceClasses, b::BitVector)
    resultingClasses = empty(c.classes)

    for class in c.classes
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

    return EquivalenceClasses(resultingClasses)
end

function CombinatorialSolver(n::Integer, k::Integer)
    return CombinatorialSolverRecursion(
        n,
        k,
        EquivalenceClasses([collect(1:k)]),
        Vector{BitVector}(),
        PartialLayer(zeros(Int, k)),
        1,
        1,
        Vector{SetSolution}()
    )
end

function CombinatorialSolverRecursion(
    N::Integer,
    K::Integer,
    DigitEquivalenceClasses::EquivalenceClasses,
    Layers::Vector{BitVector},
    CurrentLayer::PartialLayer,
    CurrentLayerIndex::Integer,
    ReferenceLayerIndex::Integer,
    Solutions::Vector{SetSolution}
)

    # End of Search-Tree: We have found a solution!
    if N == CurrentLayerIndex == ReferenceLayerIndex
        push!(Layers, normalize(CurrentLayer))
        push!(Solutions, SetSolution(Layers))
        return Solutions
    end

    # We have satisfied all restrictions with previous sets and are ready to recurse onto the next Layer
    if CurrentLayerIndex == ReferenceLayerIndex

        return FinishLayer(
            N,
            K,
            DigitEquivalenceClasses,
            Layers,
            CurrentLayer,
            CurrentLayerIndex,
            ReferenceLayerIndex,
            Solutions
        )
    end

    return SatisfyReferenceLayer(
        N,
        K,
        DigitEquivalenceClasses,
        Layers,
        CurrentLayer,
        CurrentLayerIndex,
        ReferenceLayerIndex,
        Solutions
    )
end

function FinishLayer(N::Integer,
    K::Integer,
    DigitEquivalenceClasses::EquivalenceClasses,
    Layers::Vector{BitVector},
    CurrentLayer::PartialLayer,
    CurrentLayerIndex::Integer,
    ReferenceLayerIndex::Integer,
    Solutions::Vector{SetSolution}
)
    # After all constraints with previous sets are satisfied, there might still be choices we can make
    # If there are choices we can make, that must mean that there are undecided elements in the last equivalence class
    # since all equivalence classes with elements that were chosen at some point, appear before the last class
    HasUndecidedElements = undecided(CurrentLayer, DigitEquivalenceClasses[end][1])

    # If there are choices left, we recurse for each possibility 
    # and if there aren't, we just recurse into the next Layer
    if HasUndecidedElements
        UndecidedElements = DigitEquivalenceClasses[end]

        # choose some amount of undecided elements to pick and recurse for each possibility
        for i in 0:length(UndecidedElements)

            # Optimizations possible, maybe with a mapping function on PartialLayers
            CurrentLayerCopy = deepcopy(CurrentLayer)
            for j in eachindex(UndecidedElements)
                set!(CurrentLayerCopy, UndecidedElements[j], Int(j ≤ i))
            end

            LayersCopy = copy(Layers)

            push!(LayersCopy, normalize(CurrentLayerCopy))

            resultingEquivalenceClasses = splitEquivalenceClasses(DigitEquivalenceClasses, normalize(CurrentLayerCopy))

            Solutions = CombinatorialSolverRecursion(
                N,
                K,
                resultingEquivalenceClasses,
                LayersCopy,
                PartialLayer(zeros(Int, K)),
                CurrentLayerIndex + 1,
                1,
                Solutions
            )
        end

        return Solutions
    else
        LayersCopy = copy(Layers)
        push!(LayersCopy, normalize(CurrentLayer))

        return CombinatorialSolverRecursion(
            N,
            K,
            DigitEquivalenceClasses,
            LayersCopy,
            PartialLayer(zeros(Int, K)),
            CurrentLayerIndex + 1,
            1,
            Solutions
        )
    end
end

function SatisfyReferenceLayer(
    N::Integer,
    K::Integer,
    DigitEquivalenceClasses::EquivalenceClasses,
    Layers::Vector{BitVector},
    CurrentLayer::PartialLayer,
    CurrentLayerIndex::Integer,
    ReferenceLayerIndex::Integer,
    Solutions::Vector{SetSolution}
)
    remainingDistance = CurrentLayerIndex - ReferenceLayerIndex - overlap(Layers[ReferenceLayerIndex], normalize(CurrentLayer))

    if remainingDistance < 0
        return Solutions
    end

    ChoosableClasses = choosableEquivalenceClasses(CurrentLayer, Layers[ReferenceLayerIndex], DigitEquivalenceClasses)
    ChoosableClassSizes = Vector{Int}()

    for i in 1:length(ChoosableClasses)
        push!(ChoosableClassSizes, length(ChoosableClasses[i]))
    end

    PossibleCombinations = CombinationsToN(remainingDistance, ChoosableClassSizes)

    for combination in PossibleCombinations
        CurrentLayerCopy = deepcopy(CurrentLayer)

        for ClassIndex in 1:length(ChoosableClasses)
            Class = ChoosableClasses[ClassIndex]
            for i in eachindex(Class)
                CurrentLayerCopy[Class[i]] = (i <= combination[ClassIndex]) ? 1 : -1
            end
        end

        resultingEquivalenceClasses = splitEquivalenceClasses(DigitEquivalenceClasses, normalize(CurrentLayerCopy))

        Solutions = CombinatorialSolverRecursion(
            N,
            K,
            resultingEquivalenceClasses,
            Layers,
            CurrentLayerCopy,
            CurrentLayerIndex,
            ReferenceLayerIndex + 1,
            Solutions
        )
    end

    return Solutions

end

function CombinationsToN(N::Integer, Elements::Vector{<:Integer})
    return CombinationsToNRecursion(N, 0, 1, Vector{Int}(), Vector{Vector{Int}}(), Elements)
end

function CombinationsToNRecursion(
    N::Integer, CurrentValue::Integer,
    CurrentIndex::Integer,
    CurrentCombination::Vector{<:Integer},
    Solutions::Vector{<:Vector{<:Integer}},
    Elements::Vector{<:Integer}
)
    if CurrentValue > N
        return Solutions
    end

    if CurrentIndex > length(Elements)
        if CurrentValue == N
            push!(Solutions, CurrentCombination)
        end
        return Solutions
    end

    for i in 0:Elements[CurrentIndex]
        CurrentCombinationCopy = copy(CurrentCombination)
        push!(CurrentCombinationCopy, i)
        Solutions = CombinationsToNRecursion(
            N,
            CurrentValue + i,
            CurrentIndex + 1,
            CurrentCombinationCopy,
            Solutions,
            Elements
        )
    end

    return Solutions
end