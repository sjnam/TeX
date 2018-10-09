\let\K=\leftarrow
\def\ldot{\mathinner{\ldotp\ldotp}}

\datethis

@* Introduction. Jon Bentley recently discussed the following interesting problem
as one of his ``Programming Pearls'' [{\sl Communications of the ACM\/} {\bf 27}
(December, 1984), 1179--1182]:

{\smallskip
\narrower\noindent
The input consists of two integer $M$ and $N$, with $M<N.$ The output
is a sorted list of $M$ random numbers in the range $1\ldot N$ in which no integer
occurs more than once. For probability buffs, we desire a sorted selection without
replacement in which each selection occurs equiprobably.
\smallskip}

The present program illustrates what I think is the best solution to this problem,
when $M$ is reasonably large yet small compared to $N.$ It's the method described
tersely in the answer to exercise 3.4.2--15 of my book {\sl Seminumerical
Algorithms}, pp. 141 and 555.

@ For simplicity, all input and output in this program is assumed to be handled
at the terminal.

@ Here's an outline of the entire \CEE/ program:
@c
#include <stdio.h>
#include <stdlib.h>
#include<time.h>
#include <math.h>
@<Global variables@>;
@<The random number generation procedure@>;
@<The main program@>;

@ The global variable |M| and |N| have already been mentioned; we had better
declare them. Other global variables will be declared later.
@d M_max 5000 /* maximum value of |M| allowed in this program */
@<Glob...@>=
int M; /* size of the sample */
int N; /* size of the population */

@ We assume the existence of a system routine called |rand_int(i,j)| that returns
a random integer chosen uniformly in the range $i\ldot j.$
@<The rand...@>=
int rand_int(int i, int j)
{
  int r;
  const unsigned int range = 1+j-i;
  const unsigned int buckets = RAND_MAX/range;
  const unsigned int limit=buckets*range;

  do {
    r = rand();
  } while(r>=limit);

  return i+(r/buckets);
}

@* A plan of attack. After the user has specified |M| and |N|, we compute the
sample by following a general procedure recommended by Bentley:
@<The main...@>=
int main()
{
  srand(time(NULL));
  @<Establish the values of |M| and |N|@>;
  size = 0;
  @<Initialize set |S| to empty@>;
  while (size<M) {
    T = rand_int(1,N);
    @<If |T| is not in |S|, insert it and increase |size|@>;
  }
  @<Print the elements of |S| in sorted order@>;
  return 0;
}

@ The main program just sketched has introduced sevral more global variables.
There's a set |S| of integers, whose representation will be deferred until later;
but we can declare two auxiliary integer variables now.
@<Glob...@>=
int size; /* the number of elements in set |S| */
int T; /* new candidate for membership in |S| */

@ The first order of business is to have a short dialog with the user.
@<Estab...@>=
do {
  printf("population size: N = ");
  scanf("%d", &N);
  if (N<=0) printf("N should be positive\n");
}while(N<=0);
do {
  printf("sample size: M = ");
  scanf("%d", &M);
  if (M<0) printf("M shouldn't be negative\n");
  else if(M>N) printf("M shouldn't exceed N!\n");
  else if(M>M_max) printf("(Sorry, M must be at most %d.\n)", M_max);
} while(M<0||M>N||M>M_max);

@* An ordered hash table. The key idea to an efficient solution of this sampling
problem is to maintain a set whose entries are easily sorted. The method of
``ordered hash tables'' [Amble and Knuth, {\sl The Computer Journal\/} {\bf 17}
(May 1974), 135--142] is ideally suited to this task, as we shall see.

Ordered hashing is similar to ordinary linear probing, except that the relative
order of keys is taken into account. The cited paper derives theoretical results
that will not be rederived here, but we shall use the following fundamental
property: {\sl The entries of an order hash table are independent of the order
in which its keys were inserted.\/} Thus, an ordered hash table is a ``canonical''
representation of its set of entries.

We shall represent |S| by an array of $2M$ integers. Since \CEE/ doesn't permit
arrays of variable size, we must leave room for the largest possible table.
@<Glob...@>=
int hash[M_max+M_max+1]; /* the ordered hash table */
int H; /* an index into |hash|, $0\ldot |M_max|+|M_max|-1$ */
int H_max; /* the currend hash size, $0\ldot |M_max|+|M_max|-1$ */
float alpha; /* the ratio of table size to |N| */

@ @<Init...@>=
H_max = 2*M-1;
alpha = 2*M/N;
for (H=0; H <= H_max; H++)
  hash[H] = 0;

@ Now we come to the interesting part, where the algorithm tries to insert |T|
into an ordered hash table. We use the hash address $H=\lfloor2M(T-1)/N\rfloor$
as a starting point, since this quantity is monotonic in $T$ and almost uniformly
distributed in the range $0\le H<2M.$
@<If |T|...@>=
H = (int) trunc(alpha*(T-1));
while (hash[H]>T) {
  if (H==0) H = H_max;
  else H--;
}
if (hash[H]<T) { /* |T| is not present */
  size++;
  @<Insert |T| into the ordered hash table@>;
}

@ The heart of ordered hashing is the insertion process. In general the new key
|T| will be inserted in place of a previouse key $T_1<T,$ which is then reinserted
in place of $T_2<T_1,$ etc., until an empty slot is discovered.
@<Insert |T|...@>=
while(hash[H]>0){
  TT=hash[H]; /* we have $0<TT<T$ */
  hash[H]=T;
  T=TT;
  do {
    if(H==0) H=H_max;
    else H--;
  } while(hash[H]>=T);
}
hash[H]=T;

@ @<Glob...@>=
int TT; /* a key that's being moved */

@* Sorting in linear time. The climax of this program is the fact that the entries
in our ordered hash table can easily be read out in increasing order.

Why is this true? Well, we know that the final state of the table is independent
of the order in which the elements entered. Furthermore it's easy to understand
what the table looks like when the entires are inserted in decreasing order,
because we have used a monotonic hash function. Therefore we know that the table
must hase an especially simple form.

Suppose the nonzero entries are $T_1<\cdots<T_M.$ If |k| of these have ``wrapped
around'' in the insertion process (i.e., if |H| passed from 0 to |H_max|, |k|
times), table position |hash[0]| will either be zero (in which case |k| must also
be zero) or it will contain $T_{k+1}.$ In the latter case, the entries $T_{k+1}
<\cdots<T_M$ and $T_1<\cdots<T_k$ will appear in order from left to right. Thus
the output can be sorted with at most two passes over the table!
@d print_it  printf("%d ", hash[H])
@<Print...@>=
if(hash[0]==0) { /* there was no wrap-around */
  for(H=1;H<=H_max;H++)
    if(hash[H]>0) print_it;
}@+else {
  for(H=1;H<=H_max;H++) /* print the wrap-around entries */
    if(hash[H]>0)
      if(hash[H]<hash[0]) print_it;

  for(H=0;H<=H_max;H++)
    if (hash[H]>=hash[0]) print_it;
}
printf("\n");

@* Index. The uses of single-letter variables aren't indexed by \.{CWEB}, so
this list is quit short. (And an index is quite pointless anyway, for a program
of this size.)

