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