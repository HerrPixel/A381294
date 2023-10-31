#set heading(numbering: "1.")
#set text(font: "New Computer Modern")
#show heading: set block(above: 1.4em, below: 1em)

= Problem definition

Given a number $n in NN$, find the minimal number $k in NN$ such that there are $n$ sets $A_1, dots, A_n$ containing numbers in $[k]$, i.e $A_i subset.eq \{1, dots, k\}$ satisfying:

$ |A_i sect A_j| = |i - j| text("for all") 1 <= i < j <= n $

For example, for $n = 4$, the answer would be $k = 5$, with which we could pick the $4$ sets as:

#table(
    columns: (30%,40%,30%),
    stroke: none,
    align: center + horizon,
    [
       $
        A_1 &= \{1,2,3,4\} \
        A_2 &= \{1,5\} \
        A_3 &= \{1,2\} \
        A_4 &= \{1,3,4,5\}
        $ 
    ],
    [
        or a more visual alternative:
    ],
    [
```
A₁:  1  2  3  4
A₂:  1           5
A₃:  1  2
A₄:  1     3  4  5
```
    ]
)

You can try to find sets which only use the numbers $1$ to $4$ but will hopefully be convinced that $k = 5$ is optimal.

#pagebreak()

= Best known bounds

In the following table, we record our best known values for $k$.

#table(
    columns: (10%,30%,30%),
    align: horizon + center,
    inset: 4pt,
    stroke: 0.5pt + black,
    [*n*],[*optimal value with combinatorial solver*],[*optimal value with LP solver*],
    [0],[0],[0],
    [1],[0],[0],
    [2],[1],[1],
    [3],[2],[2],
    [4],[5],[5],
    [5],[9],[9],
    [6],[16],[16],
    [7],[24],[24],
    [8],[],[36],
    [9],[],[50],
    [10],[],[70],
    [11],[],[91],
    [12],[],[120],
    [13],[],[150],
    [14],[],[189],
    [15],[],[231],
    [16],[],[280],
    [17],[],[336],
    [18],[],[398],
    [19],[],[468],
    [20],[],[547],
    [21],[],[630],
    [22],[],[728],
    [23],[],[$<=$ 827],
    [24],[],[$<=$ 944],
    [25],[],[$<=$ 1064],
    [26],[],[$<=$ 1198],
    [27],[],[$<=$ 1341],
    [28],[],[$<=$ 1493],
    [29],[],[$<=$ 1661],
    [30],[],[$<=$ 1838],
    [31],[],[$<=$ 2027],
    [32],[],[$<=$ 2232],
    [33],[],[$<=$ 2442],
    [34],[],[$<=$ 2680],
    [35],[],[$<=$ 2918],
    [36],[],[$<=$ 3179],
)

Our strategy in solving this problem combinatorically will be explained in @combinatorialApproach.
Our formulation of this problem as an (I-)LP will be explained in @LPApproach

#pagebreak()

= Upper Bounds

= Lower Bounds

= Combinatorial approach <combinatorialApproach>

= Linear Programming approach <LPApproach>