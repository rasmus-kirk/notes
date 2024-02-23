---
title: Cryptography Notes
author: 
- Rasmus Kirk Jakobsen
- Mikkel Skafsgaard Berg
date: \today
geometry: margin=2cm
fontsize: 11pt
header: |
  \usepackage[style=iso]{datetime2}
  \usepackage{amsmath,bm}
  \newcommand*\mod{\bmod}
  \newcommand*\cat{\mathbin{+\mkern-10mu+}}
  \newcommand*\bor{\mathbin{\&\mkern-7mu\&}}
  \newcommand*\xor{\oplus}
  \newcommand*\B{\mathbb{B}}
  \newcommand*\Z{\mathbb{Z}}
  \newcommand*\E{\mathbb{E}}
  \newcommand*\O{\mathcal{O}}
  \newcommand*\H{\mathcal{H}}
  \newcommand*\a{\alpha}
  \newcommand*\b{\beta}
  \newcommand*\e{\epsilon}
  \newcommand*\beq{\stackrel{?}{=}}
  \renewcommand*\plainspace{\mathcal{P}}
  \renewcommand*\cipherspace{\mathcal{C}}
  \renewcommand*\keyspace{\mathcal{K}}
  \newcommand*\meq{\stackrel{?}{=}}
  \newcommand{\qed}{\hfill \ensuremath{\Box}}
  \newcommand{\enddef}{\hfill \ensuremath{\triangle}}
  \newcommand{\floor}[1]{\left \lfloor #1 \right \rfloor }
  \newcommand{\ceil}[1]{\left \lceil #1 \right \rceil }
  \newcommand{\vec}[1]{ \boldsymbol{#1} }
  \newcommand{\ran}[1]{ \mathrm{#1} }
  \newcommand{\ranvec}[1]{ \boldsymbol{\ran{#1}} }
---

Note that these notes are based on the 2023v3 version of the cryptography book.

\setcounter{secnumdepth}{0}
\setcounter{tocdepth}{3}
\tableofcontents
\pagebreak

\newpage

# Information theory and Cryptography (Chapter 5)

**Disposition (Kirk):**

<!-- TODO: Add subbullets -->
- Perfect Security
- Entropy
- Unicity Distance
  - $H_L$
  - Redundancy
  - Spurious Keys
  - Unicity Distance

## Perfect Security

**Definition 5.1 (Perfect Security):** $P[x|y] = P[x]$
$\enddef$

**Theorem - $|\keyspace| \geq |\cipherspace| \geq |\plainspace|$:** If you have
perfect security then $|\keyspace| \geq |\cipherspace| \geq |\plainspace|$.
$\enddef$

## Entropy

**Definition 5.6 (Entropy):**
$$H(X) = \sum^n_{i=1} p_i \log_2(1/p_i)$$
**TLDR:** The entropy $H(X)$ can be described as: 

- How many bits we need to send on average to communicate the value of $X$.
- The amount of uncertainty you have about $X$ before you are told what the
  value is.
$\enddef$

**Theorem 2.4 (Jensen's inequality):**

$$\sum^n_{i=1} p_i f(x_i) \leq f(\sum^n_{i=1} p_i x_i)$$

- $f$ must be concave
- Equality **iff** all $x_i$ is equal 
$\enddef$

**Theorem 5.7 (Entropy Bounds):**
$$0 \leq H(X) \leq \log_2(n)$$. 

- $H(X) = 0$ **iff** one value $X$ has probability 1 (and the others 0). 
- $H(X) = log_2(n)$ **iff** it is uniformly distributed, i.e., all probabilities are $1/n$.
$\enddef$

_Proof:_ We need to prove the following:

- $H(X) > 0$
- $H(X) = 0$ **iff** a single $p_i = 1$ and all other $p_j = 0$
- $H(X) < \log_2(n)$
- $H(X) = \log_2(n)$ **iff** $X$ is uniformly distributed.
$\qed$

## Conditional Entropy

**Definition 5.9:** Given the above definition of $H(X \;|\;Y = y_j)$, we define
the conditional entropy of X given Y to be:
$$H(X \;|\; Y) = \sum_j P[Y = y_j] H(X \;|\; Y = y_j)$$
$\enddef$

## Entropy of Random Variables in Cryptography

**Theorem 5.11:** $H(K \;|\; C) = H(K) + H(P) - H(C)$ **iff** deterministic encryption function
$\enddef$

## Unicity Distance

**Definition - Average Bits of Information per Letter:** $H_L = \lim_{n \mapsto \infty} H(P_n)/n$
$\enddef$

**Definition - Redundancy:** 
$$R_L = \frac{\log(|\plainspace|) - H_L}{\log(|\plainspace|)} = 1 - \frac{H_L}{\log(|\plainspace|)}$$
$\enddef$

**Definition - Spurious Keys:** A spurious key _seems_ to be the correct key but is not.
$\enddef$

**Definition - Number of Spurious Keys:** 
$$sp_n = \sum_{\vec{y} \in \cipherspace^n} P[y](|K(\vec{y})| - 1) = \sum_{\vec{y} \in \cipherspace^n} P[y]|K(\vec{y})| - 1$$
$$K(\vec{y}) = \{ K \in \keyspace \; | \; P[D_K(\vec{y} > 0)]\}$$
$$P[y] = \sum_{(x, K) : E_K(x) = y} P[x]P[K]$$
$\enddef$

**Definition 5.12:** The unicity distance $n_0$ of a cryptosystem is the
minimal length of plaintexts such that $sp_{n_0} = 0$, if such a value exists,
and $\infty$ otherwise.  
$\enddef$

**Theorem 5.13:** Assume we have a cryptosystem with deterministic encryption
function, where the plaintext and ciphertext alphabets have the same size
$(|\cipherspace| = |\plainspace|)$, and where keys are uniformly chosen from
$\keyspace$. Assume we use the system to encrypt sequences of letters from
language $L$. Then
$$n_0 \geq \frac{\log(|\keyspace|)}{R_L \log(|\plainspace|)}$$
**TLDR:** If we reuse keys, our unconditional security will always be gone,
once we encrypt enough plaintext under the same key. The only exception is
the case where $R_L = 0$ which leads to $n_0$ being $\infty$. Which makes
sense, if every sequence of characters is a plaintext that can occur, the
adversary can never exclude a key.
$\enddef$

_Proof:_ We start by unfolding the definition of $H(K \;|\; C_n)$ using Definition 5.9:

$$H(K \;|\; C_n) = \sum_{\vec{y \in \cipherspace_n}} P[C_n = \vec{y}] H(K \;|\;C_n = \vec{y})$$

First, note that given some ciphertext $\vec{y}$, the key $K$ will have
some conditional distribution, but of course only values in $K(\vec{y})$
can occur. Therefore $H(K|C_n = \vec{y}) \leq \log_2(|K(\vec{y})|)$:

$$
\begin{aligned}
  H(K \;|\; C_n)
    &\leq 
      \sum_{\vec{y \in \cipherspace_n}} P[C_n = \vec{y}] \log_2(|K(\vec{y})|) \\
    &\leq \log_2 \left(\sum_{\vec{y \in \cipherspace_n}} P[C_n = \vec{y}] |K(\vec{y})|\right) 
      && \text{(Definition 2.4 - Jensen's Inequality)} \\
    &\leq \log_2(sp_n + 1)
      && \text{(Definition - Number of Spurious Keys)} \\
\end{aligned}
$$

Now we want to simplify $H(K \;|\; C_n)$. We start by applying Theorem 5.11:
$$H(K \;|\; C_n) = H(K) + H(P_n) - H(C_n)$$

Observe that $H(C_n) \geq log(|C|^n) = n \log(|\plainspace|)$. Moreover,
recalling the definition on $H_L$, let us assume that we take $n$ large
enough so that $H(P_n) \approx nH_L$.
$$
\begin{aligned}
  H(P_n) &\approx nH_L \\
    &\approx n (\log(|\plainspace|)(1-R_L))
      && \text{(Definition - Redundancy)} \\
\end{aligned}
$$

Now we try to find $H(K \;|\; C_n)$

$$
\begin{aligned}
  H(K \;|\; C_n) &= H(K) + H(P_n) - H(C_n) \\
    &\geq H(K) + H(P_n) - n \log(|\plainspace|)
      && \text{(From our observation of $H(C_n)$)} \\
    &\approx H(K) + n \log(|\plainspace|)(1-R_L) - n \log(|\plainspace|)
      && \text{(From our estimate of $H(P_n)$)} \\
    &= H(K) + n \log(|\plainspace|)-n \log(|\plainspace|)R_L - n \log(|\plainspace|) \\
    &= H(K) - n \log(|\plainspace|)R_L \\
    &= \log(|\keyspace|) - n \log(|\plainspace|)R_L 
      && \text{(Theorem 5.7, $K$ is uniform)} \\
    H(K \;|\; C_n) &\geq \log(|\keyspace|) - n \log(|\plainspace|)R_L \\
\end{aligned}
$$

Combining our equations, setting $sp_n = 0$ and solving for $n$:

$$
\begin{aligned}
  \log(|\keyspace|) - n \log(|\plainspace|)R_L &\leq \log_2(sp_n + 1) \\
  \log(|\keyspace|) - n \log(|\plainspace|)R_L &\leq \log_2(0 + 1) \\
   n \log(|\plainspace|)R_L &\leq \log(|\keyspace|) \\
   n &\leq \frac{\log(|\keyspace|)}{\log(|\plainspace|)R_L} \\
\end{aligned}
$$

So $n_0 \leq \frac{\log(|\keyspace|)}{\log(|P|)R_L}$.
$\qed$

\newpage

# Symmetric (secret-key) cryptography (Chapter 4.1 + 6)

**Disposition (Kirk):**

- Symmetric Cryptosystems
- CBC
- PRF
- CPA
- CPA security proof for CBC/CTR

## Symmetric Cryptosystems

- $G :: \keyspace$
- $E :: \plainspace \rightarrow \cipherspace$
- $D :: \cipherspace \rightarrow \plainspace$

$\forall x \in \plainspace : x = D_K(E_K(x))$ 

## PRF Security
We want the $Adv_A(O_R, O_I) \leq \epsilon$.
 
More formally, we want our PRF's to be secure as given by the following definition:  
**Definition - PRF Security:**
    $\left\{f_K \mid K \in\{0,1\}^k\right\}$ is $(t', q', \e')$ PRF-secure if $Adv_A(O_R, O_I) \leq \e$
$\enddef$

## CPA Security
**Definition - Chosen-Plaintext Attack(CPA)-security:** $(G, E, D)$ is $(t, q, \mu, \e)$ CPA-secure if $\operatorname{Adv}_A(O_R, O_I) \leq \epsilon$

$\mu$ denotes the number of bits an adversary encrypts!

$\enddef$

**Theorem:**
    If $(G', E', D')$ is $(t', q', \e')$ PRF-secure then $(G, E, D)$ using CBC is $(t, q \mu, \epsilon)$ CPA-secure for any $q$, and for
$$
  \e=\e'+\left(\frac{\mu}{n}\right)^2 \cdot \frac{1}{2^n} = \e'+\frac{\mu^2}{n^2\cdot2^n} 
$$
provided that
$$
t \leq t', \quad \frac{\mu}{n} \leq q'
$$
$\enddef$

_Proof:_
<!-- Introduce hybrid -->  
We start by introducing the _hybrid_ oracle to the game

<!-- Argue for the Adv(real, hybrid) -->
Right off the bat, since the _only_ difference between the hybrid and real game is that $E_K$ is replaced with $R$, we must have: 
$$
\begin{aligned}
Adv_A(O_{real}, O_{hybrid}) &= |p(A,real) - p(A,hybrid)| \\
                            &\leq \epsilon
\end{aligned}
$$

If this was not the case, $\textit{A}$ could be used to distinguish between $E_K$ and a random function with advantage greater than $\epsilon$, contradicting our assumption that $(G, E, D)$ was PRF-secure.  

<!-- Use this to create an upperbound on Adv(real, ideal) -->
Now note that if we are in the ideal case, the oracle does $\textit{not}$ use CBC, but simply outputs $N+1$ blocks, where $N$ is the number of blocks in the input. It should now be difficult for $\textit{A}$ to distinguish between the ideal and hybrid case, since the hybrid case outputs a concatenation of random blocks, also yielding $N+1$ random blocks, $\textit{UNLESS}$ a certain bad event happens. We define BAD as; if at any point during the hybrid game, the function R receives an input that it has received before in this game. In this case we will have an input collision, which will yield a repeated block. This could hint $\textit{A}$ that he is in the hybrid case. Therefore, his advantage in distinguishing hybrid from ideal must be bounded by: 
$$|p(A,hybrid) - p(A,ideal)| \leq Pr(BAD)$$

If we add our two inequalities, we get: 
$$
\begin{aligned}
  |p(A,real) - p(A,ideal)| &\leq |p(A,real) - p(A,hybrid)| + |p(A,hybrid) - p(A,ideal)| \\
    Adv_A(O_{real}, O_{ideal}) &\leq \epsilon + Pr(BAD)
\end{aligned}
$$

<!-- Estimate P(BAD) => give upperbound (this upperbound is \epsilon) => this upperbound is then probability of a successful chosen plaintext attack on the new system. -->
So now, we just have to estimate $Pr(BAD)$ by bounding it. Let $M_j$ be the event that a collision occurs after j calls to R. Clearly $P(M1) = 0$. Using the Law of Total Probability, we have that:
$$
\begin{aligned}
  P[M_j] &= 
    P[M_j |M_{j-1}]P[M_{j-1}] + P[M_j | \lnot M_{j-1}]P[\lnot M_{j-1}] 
    &&\text{(Law of Total Probability)}\\
    &\leq P[M_{j-1}] + P[M_j | \lnot M_{j-1}] \\
    &= P[M_{j-1}] + \frac{(j-1)}{2^n}
\end{aligned}
$$  
The last probability on the right hand side is equal to $\frac{(j-1)}{2^n}$: First, since $M_{j-1}$ did not occur we have seen $j - 1$ different inputs before. Second, the new input nr. $j$ is the XOR of some message block and an independently chosen random block (either a y0-value chosen by the oracle or an output from R), it is therefore uniformly chosen.
We conclude that in fact

$$P[M_j] \leq (1+2+\ldots + (j-1)) \leq \frac{j^2}{2^n}$$

Now we've provided a bound for all j's (calls to R).
Since the total number of calls is at most $\mu/n$, we can replace j with $\mu/n$. Thus it follows that $P(BAD) \leq \frac{\mu^2}{n^2\cdot2^n}$ and we are done.

$\qed$

\newpage

# Public-key cryptography from Factoring (Chapter 7 & 8)
**Disposition (Kirk):**

- RSA
  - Specification
  - Decryption
  - PCRSA and CPA-security
  - CCA
  - OAEP

## RSA:

**Definition The RSA algorithm:**

- $G$:
  1. On input (even) security parameter value $k$, choose random $k/2$-bit
     primes $p, q$, and set $n = pq$.
  2. Select a number $e \in Z^*_{(p-1)(q-1)}$ and set $d = e-1 \mod
     (p - 1)(q - 1)$.
  3. Output public key $pk = (n, e)$ and secret key $sk = (n, d)$. For RSA,
     we always have $\plainspace = \cipherspace = Z_n$.
- $E$: $E_{(n,e)}(x) = x^e \mod n$
- $D$: $D_{(n,d)}(y) = y^d \mod n$

\enddef

**Decryption:** $D_{(n,d)}(E_{(n,e)}(x)) = x$

_Proof:_ We use the Chinese Remainder Theorem to get $x = x^{ed} \mod n
\implies x = x^{ed} \mod q \land x = x^{ed} \mod p$

Then prove:

**Case: $x = 0$**
$$0 = x = x^{ed}$$

**Case: $x \neq 0$ modulo $p$**
$$
\begin{aligned}
x &= x^{ed} \\
  &= x^{ed-1}x \\
  &= x^{(p-1)a}x \\
  &= (x^{(p-1)})^a x \\
  &= 1^a x \\
  &= x \mod p
\end{aligned}
$$

**Case: $x \neq 0$ modulo $q$**
$$
\begin{aligned}
x &= x^{ed} \\
  &= x^{ed-1}x \\
  &= x^{(q-1)b}x \\
  &= (x^{(q-1)})^b x \\
  &= 1^b x \\
  &= x \mod q
\end{aligned}
$$

$\qed$

**Definition: The PCRSA algorithm**

- $G$: $G_{RSA}$.
- $E$: $b \in \mathbb{B}$, $x_b \in_R \Z_n : \text{lsb}(x_b) = b$, $E^{(n,e)}_{RSA}(b) = x_b^e \mod n$
- $D$: $D_{(n,d)}(y) = \text{lsb}(D^{(n,d)}_{RSA}(y)) \mod n$

$\enddef$

**Theorem: PCRSA is _almost_ CPA secure:** If you can extract the least
significant bit with certainty of $x$ given $y$ then you have a contradiction
of the RSA assumption.
$\enddef$

_Proof:_ Define the following two functions:
$$
P(y) = lsb(y^d), \qquad
H(y) =
  \begin{cases}
    0, & \text{if } 0 \leq x \leq n/2 \\
    1, & \text{otherwise}
  \end{cases}
$$

Note that:

$$
P(y) = H(2^{-e}y), \qquad
H(y) = P(2^ey)
$$

Now we can perform binary search for $x$ given $P$ in $k = \floor{\lg(n)}$
queries. This is done by constructing $H$ and doubling y ($y' = 2^ey$).

$\qed$

## CCA & OAEP

**Definitions: CCA Security:** If you can extract the least

**Case: $O_I$:**

1. $A$ may submit an input string $y$ to $O_I$, and $O_I$ will return
   $D_{sk}(y)$ to $A$. This is repeated as many time as $A$ wants.

2. A computes a plaintext $x \in \plainspace$ and gives it to $O_I$. The
   oracle responds with $y_0 = E_{pk}(r)$, where $r$ is randomly chosen in
   $\plainspace$ of the same length as $x$.

3. $A$ may now again submit an input string $y$ to $O_I$, the only restriction
   is that $y$ must be different from $y_0$. $O_I$ will return $D_{sk}(y)$
   to $A$. This is repeated as many time as $A$ wants.

**Case: $O_R$:**

1. $A$ may submit an input string $y$ to $O_R$, and $O_R$ will return
   $D_{sk}(y)$ to $A$. This is repeated as many time as $A$ wants.

2. A computes a plaintext $x \in \plainspace$ and gives it to $O_R$. The
   oracle responds with $y_0 = E_{pk}(x)$, where $r$ is randomly chosen in
   $\plainspace$ of the same length as $x$.

3. $A$ may now again submit an input string $y$ to $O_R$, the only restriction
   is that $y$ must be different from $y_0$. $O_R$ will return $D_{sk}(y)$
   to $A$. This is repeated as many time as $A$ wants.

$\enddef$

**Definitions: OAEP:**

$E_{pk}' :: \B^k \to \B^a$  
$k_0, k_1 : k_0 + k_1 < k$  
$E_{pk} :: \B^n \to \B^b, \; n = k - k_0 - k_1$  
$G :: \B^{k_0} \to \B^{n+k_1}, \; H :: \B^{n+k_1} \to \B^{k_0}$  

Encryption $E_{pk}$:

1. Choose $r \in_R \B^{k_0}$.
2. Compute $s = G(r) \xor (x \cat 0^{k_1}), t = H(s) \xor r, w = s \cat t$
3. Let the ciphertext be $y = E'_{pk}(w)$.

Decryption $D_{pk}$:

1. $s, t$ from $D'_{pk}(y) = w = s \cat t$.
2. $r = t \xor H(s)$
3. $x, s_0$ from $G(r) \xor s$
4. Check $s_0 \beq 0^{k_1}$
5. Output $x$
$\enddef$

\newpage

# Public-key cryptography based on discrete log and LWE (Chapter 9 & 10, definition of CPS security in chapter 8)

**Disposition (Kirk):**

- DL, DH, DDH
- El Gamal
  - CPA
- Elliptic Curves

## DL, DH, DDH

**Definition: DL, DH, DDH:**

- DL: Given $\a^a$, find $a$
- DH: Given $\a^a, \a^b$, find $\a^{ab}$
- DDH: Given $\a^a, \a^b, \a^c$, find $\a^{ab} \beq \a^c$

$\enddef$

**Theorem: Hardness of DL, DH, DDH:** DL $\geq$ DH $\geq$ DDH $\enddef$

_Proof:_

- Solving DL means solving DH: Given $\a^a, \a^b$, solve DL for $a$, then $(\a^b)^a = \a^ab$.
- Solving DH means solving DDH: Given $\a^a, \a^b, \a^c$ solve DH for $\a^{ab}$, then $\a^{ab} \beq \a^c$.

$\qed$

## El Gamal

**Definition: Diffie-Hellman:**

1. A sends B $\a^a$
2. B sends A $\a^b$
3. Both compute secret $\a^{ab}$

**Definition: El Gamal**

Space:

- $\plainspace = G$
- $\cipherspace = G \times G$

Algorithm:

- GGen(k): $G, \a \in G$
- G(k): $a \in_R \Z_t, pk = (GGen(k), \b = \a^a), sk = a$
- E($x \in G$): $r \in_R \Z_t, y = (\a^r, \b^rm)$ 
- D(c, d): x = $c^{-a}d$

**Theorem: El Gamal Decryption Works** $\enddef$ 

_Proof:_
$$
\begin{aligned}
c^{-a}d &= (\a^r)^{-a}\b^rm \\
        &= \a^{-ar} \a^{ar}m \\
        &= m
\end{aligned}
$$
$\qed$

**Theorem: Under the DDH assumption El Gamal is CPA secure:** $\enddef$

_Proof:_ We assume that there exists and adversary $A$ that breaks CPA with
advatage $> \epsilon$. Then we construct a subroutine $B$ that uses $A$
to break DDH using $A$, this will lead to a contradiction.

$$
\begin{aligned}
  D(\a^b, \a^c m) &= \a^{-ab} \a^{c} m \\
                  &= \a^{c - ab} m \\
\end{aligned}
$$

Only if $c = ab$ do we get $m$. So we simply return the check $D(\a^b, \a^c m)
\beq m$. This will have the same advantage as $A$ so we have advantage $>\e$.

$\qed$

## Elliptic Curves

**Definition: Elliptic Curves**
Define a function:
$$y^2 = x^3 + ax + b : 4a^3 + 27b^2 \neq 0$$

Addition of $P + Q = (x_1, y_1) + (x_2, y_2)$:

- $x_1 \neq x_2$: $P + Q = R$ (regular)
- $x_1 = x_2 \land y_1 = -y_2$: $P + Q = \O$ (above)
- $x_1 = x_2 \land y_1 = y_2$: $P + Q = 2P$ (tangent)

$$E_{a,b,p} = \{ (x,y) \;|\; y^2 = x^3 + ax + b \mod p \} \cup \O$$

$\enddef$

**Theorem 9.11 (Hasse):** The order of $N$ of $E_{a,b,p}$ satisfies $p+1-2\sqrt{p} \leq N \leq p+1+2\sqrt{p}$ $\enddef$

**Definition: Elliptic Curves for El Gamal**

- $E(m)$: $P \in_R E_{a,b,p}, (E_{EG}(P), H(P) \xor m)$
- $D(c, d)$: $(H(D_{EG}(c)) \xor d = H(P) \xor (H(P) \xor m)$

<!-- Use Hasse? -->

$\enddef$

\newpage

# Symmetric authentication and hash functions (Chapter 11)

**Disposition (Kirk):**

- Definition of Collision intractible hash functions
  - Construction from DL
  - Implies one-way
- Merkle-Damgård
- CMA

## Collision Intractible Functions

**Definition: Collision Intractible Functions:**

- $\H(k)$ produces $h(x) :: \B^* \to \B^k$
- Security:
  - Second Preimage Attack: $h(m_1) = h(m_2) : m_1 \neq m_2$
  - Collision Attack: For _any_ $m_1, m_2$, $h(m_1) = h(m_2) : m_1 \neq m_2$
$\enddef$

**Definition: Hash Functions based on factoring and discrete log:**

- $\H(k)$: $p = 2q + 1$ where $q$ is a $k-1$-bit prime, $\a, \b$ of order $q$ in $\Z_p^*$
  - $h(m_1, m_2) = \a^{m_1} \b^{m_2} \mod p$
- Security. Assume collision:
  - $h(m_1, m_2) = h(m_1', m_2')$ where ($m_1 \neq m_1' \lor m_2 \neq m_2'$)
    then $\a^{m_1} \b^{m_2} = \a^{m_1'} \b^{m_2'}$
  - Then $\a = \b^{(m_2-m_2')(m_1-m_1')^{-1} \mod q} \mod p$
$\enddef$

**Lemma 11.2: Collisions-intractable hash functions are one-way:** Given
function $h :: \B^{2k} \to \B^k$, and assume we are given an algorithm $A$
running in time $t$ that, when given $h(m)$ for uniform $m$, returns a preimage
of $h(m)$ with probability $\e$. Then a collision for $h$ can be found in time
$t$ plus one evaluation of $h$ and with probability at least $\e/2 - 2-k-1$.

_Proof:_

- $P[m \text{ is only child}] \leq 2^{-k}$
- $P[m \text{ is only child and } A \text{is succesful}] = P[G] \geq \e - 2^{-k}$
- $P[A \text{ finds collision}] = P[C] = \e$
- $P[C|G] \geq 1/2$

$$P[C] \geq P[C \cap G] = P[C|G]P[G] \geq 1/2 \cdot P[G] \geq (\e - 2^{-k})/2$$

## Merkle-Damgård Construction

**Theorem 11.3 (Merkle-Damgård):** If there exists a collision-intractable
hash function generator $\H'$ producing functions with finite input length
$m > k$, then there exists a collision- intractable generator $\H$ that
produces functions taking arbitrary length inputs.
$\enddef$

_Proof:_  
**Case: $m-k > 1$:**  
$v = m - k - 1 > 0$  
$\H'(k) = f :: \B^m \to \B^k$

1. Split $x$ into $v$-bit blocks $x_1, x_2, ... x_n$ pad $x_n$ with zeros if needed.
2. Add $x_n$ containing the number of bytes used to pad $x_n$.
3. Define $m$-bit blocks $z_1, z_2, ..., z_{n+1}$
  - $z_1 = 0^k \cat 1 \cat x_1$
  - $z_i = f(z_{i-1}) \cat 0 \cat x_i$
4. Define $h(x) = f(z_{n+1})$

**Case: $m-k = 1$:**

1. Same arguments, but fails on last check **iff** $x'$ is a suffix of $x$
2. $H(x) = H(E(x))$ where $E$ is a suffix free encoding functions.
3. E(x) = $0, 1 \cat D(x)$ where $D(x)$ repeats each bit twice.
$\qed$

## MACs

**Definition: MACs**

- $G$: $K$
- $A(m) = s$
- $V(s, m) = acc \lor rej$

Where $V(A(m), m) = acc$.
$\enddef$

**Definition: HMAC:** Two 512 bit constants:

- $ipad = \text{3636...36}$
- $opad = \text{5C5C...5C}$

$$HMAC_K(m) = SHA1(\; (K \xor opad) \cat SHA1((K \xor ipad) \cat m))$$
$\enddef$

\newpage

# Signature schemes (Chapter 12)
**Disposition (Kirk):**

- Definition of Signature and CMA
- RSA Signatures
- Schnorr
  - Cannot cheat
  - Signature Scheme from interactive game

## Signature Schemes

**Definition: MACs**

- $G$: $K$
- $A(m) = s$
- $V(s, m) = acc \lor rej$

Where $V(A(m), m) = acc$.
$\enddef$

## RSA Signatures

**Definition: Simple RSA Signatures**

- $G$: $G_{RSA}$
- $A(m) = D_{RSA}(m) = m^d = s$
- $V(s, m) = E_{RSA}(s) \beq m = s^d \beq m$

_Not_ CMA secure!
$\enddef$

**Definition: CMA Secure RSA Signatures**

- $G$: $G_{RSA}, h = \H(k)$
- $A(m) = D_{RSA}(h(m)) = h(m)^d = s$
- $V(s, m) = E_{RSA}(s) \beq h(m) = s^d \beq h(m)$

Secure if we model the Full Domain Hash as a random function and under the RSA assumption.
$\enddef$

## Schnorr Signature Scheme

**Definition: The Schnorr ZK Interactive Game**  
$p, q : q | p-1, \a \in \Z_p^* : |\a| = q, \a = \a_0^{p-1/q}, \a_0$ is a generator for $\Z_p^*$  
$pk = (p, q, \a, \b = \a^a), sk = a$

$$
\begin{aligned}
  P \to V &: c = \a^r \\
  V \to P &: e \in_R \Z_q^* \\
  P \to V &: z = (r + ae) \\
        V &: \a^z \beq c\b^e
\end{aligned}
$$

If $P$ is honest:
$$
\begin{aligned}
  \a^z &= c\b^e \\
       &= \a^r (\a^a)^e \\
       &= \a^{r+ae} \\
       &= \a^z
\end{aligned}
$$
$\enddef$

**Theorem: If $P$ can reliably "cheat", then he knows $a$:** If $P$ can
guess more than 1 $e$ reliably, then he can easily calculate $a$.
$\enddef$

_Proof:_
$e \neq e'$  
$z = r + ae, \quad z' = r + ae'$  
$\a^z = c\b^e, \quad \a^{z'} = c\b^{e'}$  

$$
\begin{aligned}
  \a^{(z-z')} &= \b^{(e-e')} \\
  \a^{(z-z')(e-e')^{-1}} &= \b \\
  \a^a &= \b
\end{aligned}
$$
$\qed$

**Definition: Fiat-Shamir on the Schnorr Interactive Game:** We can use the
Fiat-Shamir heuristic to go from interactive to non-interactive:  
$$
\begin{aligned}
  P \to V &: (e = h(c, m), z, c) \\
        V &: \a^z \beq c\b^e \bor c \beq h(c,m)
\end{aligned}
$$
Alternatively:
$$
\begin{aligned}
  P \to V &: (e, z) \\
        V &: c = \a^z\b^{-e} \\
        V &: \a^z \beq c\b^e \bor \beq h(c,m)
\end{aligned}
$$
$\enddef$

**Definition: Fiat-Shamir on the Schnorr Interactive Game:** We can use the
Fiat-Shamir heuristic to go from interactive to non-interactive:  
$$
\begin{aligned}
  P \to V &: (e = h(c, m), z, c) \\
        V &: \a^z \beq c\b^e \bor c \beq h(c,m)
\end{aligned}
$$
Alternatively:
$$
\begin{aligned}
  P \to V &: (e, z) \\
        V &: c = \a^z\b^{-e} \\
        V &: \a^z \beq c\b^e \bor e \beq h(c,m)
\end{aligned}
$$
$\enddef$

**Definition: Schnorr Signature Scheme:**

- $G$: Output $pk = (h, p, q, \a, \b = \a^a mod p)$ and $sk = a$.
- $A(m) = (e, z)$
- $V(s, m) = \a^z \beq c\b^e \bor e \beq h(c,m)$

\newpage

## Appendix

**CPA**
$$
\begin{aligned}
  \epsilon &= \epsilon' + \left(\frac{\mu}{n}\right)^2 \cdot \frac{1}{2^n}\\
           &= \epsilon' + \frac{\mu^2}{n \cdot 2^n}
\end{aligned}
$$

Solving for $1 = | \epsilon - \epsilon' |$:

$$
\begin{aligned}
  1 &= | \epsilon - \epsilon' | \\ 
  1 &= \frac{\mu^2}{n \cdot 2^n} \\
  n \cdot 2^n &= \mu^2 \\
  \sqrt{n \cdot 2^n} &= \mu \\
  \sqrt{n} \cdot 2^{n/2} &= \mu \\
\end{aligned}
$$

So if we encrypt much less than $2^{n/2}$ we are safe. We disard $\sqrt{n}$
since it is insignificant compared to $2^{n/2}$.

$\qed$

**CPA**
$$
\begin{aligned}
  P[M_j] &= P[M_j |M_{j-1}]P[M_{j-1}] + P[M_j | \lnot M_{j-1}]P[\lnot M_{j-1}] 
    &&\text{(Law of Total Probability)}\\
    &= \frac{P[M_j, M_{j-1}]}{P[M_{j-1}]}P[M_{j-1}] + P[M_j | \lnot M_{j-1}]P[\lnot M_{j-1}]
      && \text{(Bayes rule)} \\
    &= P[M_j, M_{j-1}] + P[M_j | \lnot M_{j-1}]P[\lnot M_{j-1}] \\
    &= P[M_j] P[M_{j-1}] + P[M_j | \lnot M_{j-1}]P[\lnot M_{j-1}] \\
    &\leq P[M_{j-1}] + P[M_j | \lnot M_{j-1}] \\
\end{aligned}
$$

