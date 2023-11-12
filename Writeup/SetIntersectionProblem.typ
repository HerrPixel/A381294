#import "@preview/algo:0.3.3": algo, i, d, comment, code

#set heading(numbering: "1.")
#set text(font: "New Computer Modern")
#show heading: set block(above: 1.4em, below: 1em)

#let titlepage(title:[],authors: ()) = {
    set align(center+horizon)
    page(margin:0pt,
    [

        #place(top + left,
            line(start: (100pt,0pt),end: (0pt,100pt))
        )

        #place(top + right,
            line(start: (-100pt,0pt),end: (0pt,100pt))
        )

        #place(bottom + left,
            line(start: (0pt,-100pt),end: (100pt,0pt))
        )

        #place(bottom + right,
            line(start: (0pt,-100pt),end: (-100pt,0pt))
        )

        #set text(size:20pt)
        #strong(title) \

        #if authors.len() != 0 {
            set text(size:15pt)
            "By " + authors.join(", ", last: " and ")
        }
    ])
}

#titlepage(
    title: [
        Set Intersection with Minimal Support \        
        The SIMS-Problem
    ],
    authors: ("Jonas Seiler", "Cecilia Knäbchen")
)

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

Our current best upper bound comes from an explicit construction. This bound is not tight, there are more optimal solutions starting from $n=6$, but we have not yet been able to derive a pattern out of those.

Our construction works as follows:

For each set-distance $i in {1,dots,n-1}$, and for each coset representative $a in {0,dots,i-1}$, if there are atleast $2$ two set indices $b,c in {1,dots,n}$ with $b mod i = c mod i = a$, i.e. they lie in the same coset, then define $phi(i)$ new unused numbers to add to all sets with indices in that coset and increase $k$ by $phi(i)$, the number of newly added and used numbers.

For example, for $n = 6$, this constructions yields the following:
```
    i=1| i=2  |        i=3       |       i=4      |       i=5
A₁:  1 | 2    | 4  5             | 10  11         | 14  15  16  17 
A₂:  1 |    3 |       6  7       |         12  13 |
A₃:  1 | 2    |             8  9 |                |
A₄:  1 |    3 | 4  5             |                |
A₅:  1 | 2    |       6  7       | 10  11         |
A₆:  1 |    3 |             8  9 |         12  13 | 14  15  16  17
```
From this we can also see that this is not optimal, since for $n=6$, there is a solution with $k = 16$.

#algo(
    title: "ExplicitConstruction",
    parameters: ("n",),
    indent-guides: 1pt + black,
    
)[
    $A_1,dots,A_n = {}$ \
    $k = 0$ \
    For $i in {1,dots,n-1}$ #i \
        For $a in {1,dots,min(i,n-i)}$ #i #comment[cosets with atleast two set indices]\
            For $b in {1,dots,phi(i)}$ #i #comment[number of elements to add]\
                For $j in {0,1,dots,n div i}$ #i #comment[set indices to add to]\
                    $A_(a + j i) = A_(a + j i) union {k + b}$ #d \
                End #d \ 
            End \
            $k += phi(i)$ #d \
        End #d \
    End \
    return $A_1,dots,A_n$    
]

euler identity for $sum_(d|n) phi(d) = n$

= Lower Bounds

= Combinatorial approach <combinatorialApproach>

= Linear Programming approach <LPApproach>