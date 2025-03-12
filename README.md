# A381294

Given a number $n \in ℕ$, find the minimal number $k \in ℕ$, such that there are $n$ Sets $A_{1}, \dots, A_{n}$ containing some numbers from $1$ to $k$, i.e $A_i \subseteq \lbrace 1,\dots, k \rbrace$ satisfying:

$$ | A_i \cap A_j | = |i - j| \text{ for all } 1 \leq i < j \leq n$$

For example, for $n = 4$, the answer would be $k = 5$, with which we could pick the $4$ sets as:  
$A_1 = \lbrace 1,2,3,4 \rbrace$  
$A_2 = \lbrace 1,5 \rbrace$  
$A_3 = \lbrace 1,2 \rbrace$  
$A_4 = \lbrace 1,3,4,5 \rbrace$  
or a more visual representation:

```raw
A₁:  1  2  3  4
A₂:  1           5
A₃:  1  2
A₄:  1     3  4  5
```

This repo contains the code we used to find the optimal values for $k$ up to $n=22$. One optimal solution for each $n$ can also be found in the solutions.txt file.
The found values is sequence [A381294](https://oeis.org/A381294) in the OEIS. You can also find a paper with current results on my website: [jonasseiler.de/A381294](https://jonasseiler.de/A381294).

## Current known values and bounds

Lower bounds are found by solving the relaxed LP problem. In all cases where the exact value of $k$ is known, it coincides with the optimal LP solution.

Where an upper bound for $k$ is given, it is known from a constructed (albeit possibly not optimal) solution.

| $n$  | $k$        |
| ---- | ---------- |
| $0$  | $0$        |
| $1$  | $0$        |
| $2$  | $1$        |
| $3$  | $2$        |
| $4$  | $5$        |
| $5$  | $9$        |
| $6$  | $16$       |
| $7$  | $24$       |
| $8$  | $36$       |
| $9$  | $50$       |
| $10$ | $70$       |
| $11$ | $91$       |
| $12$ | $120$      |
| $13$ | $150$      |
| $14$ | $189$      |
| $15$ | $231$      |
| $16$ | $280$      |
| $17$ | $336$      |
| $18$ | $398$      |
| $19$ | $468$      |
| $20$ | $547$      |
| $21$ | $630$      |
| $22$ | $728$      |
| $23$ | $\le 827$  |
| $24$ | $\le 944$  |
| $25$ | $\le 1064$ |
| $26$ | $\le 1198$ |
| $27$ | $\le 1341$ |
| $28$ | $\le 1493$ |
| $29$ | $\le 1661$ |
| $30$ | $\le 1838$ |
| $31$ | $\le 2027$ |
| $32$ | $\le 2232$ |
| $33$ | $\le 2442$ |
| $34$ | $\le 2677$ |
| $35$ | $\le 2915$ |
| $36$ | $\le 3176$ |
| $37$ | $\le 3446$ |
| $38$ | $\le 3732$ |
| $39$ | $\le 4036$ |
| $40$ | $\le 4350$ |
| $41$ | $\le 4688$ |
| $42$ | $\le 5039$ |
| $43$ | $\le 5405$ |
| $44$ | $\le 5795$ |
| $45$ | $\le 6191$ |
| $46$ | $\le 6621$ |
| $47$ | $\le 7058$ |
| $48$ | $\le 7520$ |
| $49$ | $\le 8008$ |

For a few values of $n$, the number of different optimal solutions, up to renaming of elements, is known as well. The last column also counts solutions obtained by reversing the order of $A_{1}, \dots, A_{n}$ as the same.

| $n$  | $k$        | # of solutions | # up to symmetry |
| ---- | ---------- | -------------- | ---------------- |
| $2$  | $1$        | $1$            | $1$              |
| $3$  | $2$        | $1$            | $1$              |
| $4$  | $5$        | $1$            | $1$              |
| $5$  | $9$        | $3$            | $3$              |
| $6$  | $16$       | $25$           | $15$             |
| $7$  | $24$       | $110$          | $69$             |
| $8$  | $36$       | $4373$         | $2260$           |
| $9$  | $50$       | $147289$       | $74421$          |
| $10$ | $70$       | $\ge 582517$   |                  |

## Trying it out yourself

The solver is written as a MIP in [Julia](https://julialang.org/) with [JuMP](https://jump.dev/).

To run it yourself, install Julia, for example with [Juliaup](https://github.com/JuliaLang/juliaup).

You then first need to instantiate the project to set up the environment and download all the dependencies:

```bash
$ julia --project=.

julia>

# Press ] to get into pkg

(SetProblem) pkg> instantiate
```

You only need to do this once, afterwards you can always run the solver by using the `SetProblem` module and calling `solve(n)`:

```bash
$ julia --project=.

julia> using A381294

julia> solve(3)
[...]
SetSolution with n = 3 and k = 2 :
A₁: 1 2
A₂: 1
A₃: 1 2
```
