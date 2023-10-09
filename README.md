# Linear Set Intersection with minimal support

Given a number $n \in \N$, find the minimal number $k \in \N$, such that there are $n$ Sets $A_{1}, \dots, A_{n}$ containing some numbers from $1$ to $k$, i.e $A_i \subseteq \{1,\dots, k\}$ satisfying:

$$ | A_i \cap A_j | = |i - j| \text{ for all } 1 \leq i < j \leq n$$

For example, for $n = 4$, the answer would be $k = 5$, with which we could pick the $4$ sets as:  
$A_1 = \{1,2,3,4\}$  
$A_2 = \{1,5\}$  
$A_3 = \{1,2\}$  
$A_4 = \{1,3,4,5\}$  
or a more visual representation:

```
A₁:  1  2  3  4
A₂:  1           5
A₃:  1  2
A₄:  1     3  4  5
```

## Current known values and bounds

Where a lower bound for $k$ is given, it is known from the optimal solution of the equivalent LP problem. In all cases with the exact value of $k$ known, it coincides with that optimal solution.

Where an upper bound for $k$ is given, it is known from a constructed solution.

| $n$  | estimate for $k$ | Confirmed optimal? | Nr of unique solutions |
| ---- | ---------------- | ------------------ | ---------------------- |
| $0$  | $0$              | yes                | $1$                    |
| $1$  | $0$              | yes                | $1$                    |
| $2$  | $1$              | yes                | $1$                    |
| $3$  | $2$              | yes                | $1$                    |
| $4$  | $5$              | yes                | $1$                    |
| $5$  | $9$              | yes                | $3$                    |
| $6$  | $16$             | yes                | $15$                   |
| $7$  | $24$             | -                  | -                      |
| $8$  | $36$             | -                  | -                      |
| $9$  | $50$             | -                  | -                      |
| $10$ | $70$             | -                  | -                      |
| $11$ | $91$             | -                  | -                      |
| $12$ | $120$            | -                  | -                      |
| $13$ | $150$            | -                  | -                      |
| $14$ | $189$            | -                  | -                      |
| $15$ | $231$            | -                  | -                      |
| $16$ | $280$            | -                  | -                      |
| $17$ | $336$            | -                  | -                      |
| $18$ | $398$            | -                  | -                      |
| $19$ | $468$            | -                  | -                      |
| $20$ | $547$            | -                  | -                      |
| $21$ | $630$            | -                  | -                      |
| $22$ | $728$            | -                  | -                      |
| $23$ | $\le 827$        | -                  | -                      |
| $24$ | $\le 944$        | -                  | -                      |
| $25$ | $\le 1064$       | -                  | -                      |
| $26$ | $\le 1198$       | -                  | -                      |
| $27$ | $\le 1341$       | -                  | -                      |
| $28$ | $\le 1493$       | -                  | -                      |
| $29$ | $\le 1661$       | -                  | -                      |
| $30$ | $\le 1838$       | -                  | -                      |
| $31$ | $\le 2028$       | -                  | -                      |
| $32$ | $\le 2235$       | -                  | -                      |
| $33$ | $\le 2444$       | -                  | -                      |
| $34$ | $\le 2680$       | -                  | -                      |

-   `n`:
    Number of Sets as described in the introduction above
-   `estimate of k`:
    Current best solution found by solving a linear optimization problem over the number of used numbers
-   `Confirmed optimal?`:
    Independently found the same lower bound by checking all possibilities with a combinatorial approach and then finding a solution for $k$
-   `Nr or unique solutions`:
    Given a solution, you can rename the used numbers to get another solution that is "equivalent", i.e. if a set contained a $2$, it now instead contains a $5$ and if a set contained a $5$, it now contains a $2$. You can also invert the set numbering, such that $A_1 = A'_n$, $A_2 = A'_{n-1}$, $\dots$ and so on to also get another solution. Ignoring all those equivalent solution and just counting the number of equivalence classes of minimal solutions we arrive at the number of unique solutions

## Trying out the solver yourself

The combinatorial solver is written in [Julia](https://julialang.org/).

To run it yourself, install Julia, for example with [Juliaup](https://github.com/JuliaLang/juliaup).

You then first need to instantiate the project to set up the environment and download all the dependencies:

```bash
$ julia --project=.

julia>

# Press ] to get into pkg

(SetProblem) pkg> instantiate
```

You only need to do this once, afterwards you can always run the solver by using the `SetProblem` module and calling the `smartSolutionFinder(n,k)`:

```bash
$ julia --project=.

julia> using SetProblem

julia> smartSolutionFinder(4,5)
A₁:  1  2  3  4
A₂:  1           5
A₃:  1  2
A₄:  1     3  4  5
```
