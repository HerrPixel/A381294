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

#outline()
#pagebreak()

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
A₂:  1           5euler identity for $sum_(d|n) phi(d) = n$
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

Remember that $phi(i)$ is Euler's totient function, the number of relatively prime integers up to $i$.

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
        For $a in {1,dots,min(i,n-i)}$ #i #comment[cosets with atleast two set-indices]\
            For $b in {1,dots,phi(i)}$ #i #comment[number of elements to add]\
                For $j in {0,1,dots,(n div i) - 1}$ #i #comment[set-indices to add to]\
                    $A_(a + j i) = A_(a + j i) union {k + b}$ #d \
                End \
                If#d \ 
            End \
            $k += phi(i)$ #d \
        End #d \
    End \
    return $A_1,dots,A_n$    
]

We first prove that this construction indeed yields a solution and then calculate it's size.

For sets $A_a$ and $A_b$ with $|a-b| = k$, we look at divisors $d$ of $k$. For each divisor, they share $phi(d)$ elements. Together they therefore share $sum_(d|k) phi(d) = k$ elements as wanted. This last identity is due to Euler. A proof can be found in.

To see that they share exactly those elements, see that they only share $phi(i)$ elements for every $i < n$ such that they are in the same coset of $ZZ \/ i ZZ$, i.e. 
$
&quad a mod i = b mod i = c \
&<=> a = u i + c and b = v i + c \
&<=> k = a-b = i (u-v) \
&<=> i | k
$
For $i > k$, $a$ and $b$ are never in the same coset, and therefore $a$ and $b$ share exactly $phi(i)$ elements for every $i <= k$ with $i | k$ as stated.



Now we want to estimate $k$ in dependency of $n$.
Using the terms for the 

#pagebreak()

= Lower Bounds

For a lower bound on $k$, we first calculate a lower bound on the number of elements needed in $A_i$ that cannot be contained in $A_j$ for $j < i$. We call the set of these elements $A_i^"new"$.

For this, we first calculate some lower bound on $|A_i|$. By using a weaker form of the inclusion-exclusion principle, we see that 
$
|A_i| &= |union.big_(j=1 \ j eq.not i)^n A_i sect A_j| \
#text(size:8pt,"inclusion-exclusion") &>= sum_(j=1 \ j eq.not i)^n |A_i sect A_j| - sum_(1 <= j < k <= n \ j,k,i "distinct")^n |(A_i sect A_j ) sect (A_i sect A_k)| \
&>= sum_(j=1 \ j eq.not i)^n |A_i sect A_j| - sum_(1 <= j < k <= n \ j,k,i "distinct")^n |(A_i sect A_j ) sect (A_i sect A_k)|
$

Without any additional knowledge, we do not know anything about $A_i sect A_j sect A_k$, so we cannot use a stronger version of the inclusion-exclusion principle. Next, we see that by our problem definition, $|A_i sect A_j| = |i-j|$ and 

#pagebreak()

= Normal Form

For each solution, we can rename the elements to obtain another solution. Since such solutions are "the same" in some sense, we would like some way to check if two solutions are "the same" or if they really differ in a significant way. While we could count how many elements each set uses, there are solutions which use the same number of elements while still not being able to be transformed into each other via a renaming of used elements.

In this section we therefore want to introduce a normal form for solutions which is the same for all solutions arising from another via renaming of elements.

Each element is either contained in a set $A_i$ or not. We can therefore associate an element $k$ with a $n$-dimensional vector $v^k$ with $v^k_i = 1$ if $k in A_i$ or $0$ otherwise.

For example, in the following solution for $n=4$

```
A₁:  1  2  3  4
A₂:  1           5
A₃:  1  2
A₄:  1     3  4  5
```

we have $v^1 = (1,1,1,1)$ or $v^2 = (1,0,1,0)$. Writing our solution in the format above, the vectors are just the columns with $0$s filled in the blank spots.

We therefore transform our solution into one , where the elements are renamed in such a way, that the vectors are sorted lexicographically.

The exemplary solution above is already in this normal form while the following solution isn't:

```
A₁:  1  2     4  5
A₂:  1     3      
A₃:  1  2
A₄:  1     3  4  5
```
Here, $v^3 = (0,1,0,1)$ is sorted before $v^4 = (1,0,0,1) = v^5$.

It is clear that this normal form is unique by the uniqueness property of sorted lists up to equivalent elements, which would be elements that are in the exact same set in our case, which can be renamed at will anyway.

It is also clear that each solution has a normal form, since we can always define these column vectors and sort them.

Another way to create a solution out of another, is to switch the sets $A_i$ with $A_(n-(i-1))$, i.e. $A_1$ becomes $A_n$, $A_2$ becomes $A_(n-1)$ and so on. Our normal form is not resistant to this renaming and we have not found a "cheap" normal form that is invariant under both transformations though we welcome all suggestions.

 
#pagebreak()

= Combinatorial approach <combinatorialApproach>

#pagebreak()


= Linear Programming approach <LPApproach>

#pagebreak()

= Addendum

Euler phi function identity and citation in Chapter 3