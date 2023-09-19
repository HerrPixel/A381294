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