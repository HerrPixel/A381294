module SetProblem

include("Solution.jl")
include("CombinatorialSolver.jl")

include("Solver.jl")
export CombinatorialSolver
export PrettyPrintSolution
export ASCIIPrintSolution
export solve

end