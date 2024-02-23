---
title: Cryptography Notes
author: Rasmus Kirk Jakobsen
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
  \newcommand*\a{\alpha}
  \newcommand*\b{\beta}
  \newcommand*\d{\delta}
  \newcommand*\e{\epsilon}
  \newcommand*\l{\lambda}
  \newcommand*\B{\mathbb{B}}
  \newcommand*\E{\mathbb{E}}
  \newcommand*\N{\mathbb{N}}
  \newcommand*\R{\mathbb{R}}
  \newcommand*\Z{\mathbb{Z}}
  \newcommand*\O{\mathcal{O}}
  \newcommand*\H{\mathcal{H}}
  \newcommand*\Sc{\mathcal{S}}
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
  \newcommand*\Gen{\text{Gen}}
  \newcommand*\Commit{\text{Commit}}
  \newcommand*\CheckParams{\text{CheckParams}}
---

Note that these notes are based on the 2023v3 version of the cryptography book.

\setcounter{secnumdepth}{0}
\setcounter{tocdepth}{3}
\tableofcontents
\pagebreak

\newpage

# Curriculum

Specific remarks on the subjects

1. Commitments and Graph Hamiltonicity. The note on commitments is the
   main mateiral. The Graph Hamiltonicity protocol from the ZK note is a
   prime example of an application of commitments. You can choose to cover
   it, but you don't have to. There is other stuff with substance in it,
   such as the construction of commitments from hash functions.
2. Zero-Knowledge. The ZK note.
3. Sigma protocols. The Sigma protocol note. Many people do the OR
   construction, which is fine, but remember to also give an example of a
   Sigma protocol. It would be very sad to have all that theory, if Sigma
   protocols did not exist!
4. Passive MPC. Chapter 3. For the exact pages this covers see curriculum
   below.
5. The UC model. Chapter 4. For the exact pages this covers see curriculum
   below. Be careful not to waste your time on small technical details. Also,
   all the initial stuff about how to simulate actual leakage and influence
   is just meant to give intuition to the reader and can easily eat up your
   time. The UC theorem is the main thing and it's important you have time
   for this.
6. Actively Secure MPC. Chapter 5. For the exact pages this covers see
   curriculum below. The CEAS protocol itself is not all that interesting,
   as it is more or less just CEPS with commitments added. So instead, better
   focus on the Transfer/Commit-Mult protocols, or the Commitment protocol.

**Curriculum:**

The notes on Commitment schemes, Zero-Knowledge and Sigma Protocols. The
MPC book, chapters 3, 4 and 5 (with chapters 1+2 as background), however,
in chapter 5, proofs of adaptive security and the material on IC signatures
are not curriculum.

The pages covered in the book are as follows:
- Chapter 3: Pages 32 - 50
- Chapter 4: Pages 51- 93
- Chapter 5: Pages 104 - 137. The curriculum excludes the three chapters
  called “Adaptive Corruption” on  pages 112-113, 126-128, and 132-133.

\newpage

# Commitments and Graph Hamiltonicity

**Disposition (Kirk):**

## Commitment schemes

**Definition (Commitment Schemes):**

- $Gen() \to pp$: Generates any public parameters $pp$ necessary for the
  commitment scheme.
- $CheckParams(pp) \to \{ acc, rej \}$: Checks the public parameters $pp$.
- $Commit_{pp}(m; r) \to c$: Creates a commitment $c$ to the message $m$ using
  randomness $r$.
$\enddef$

**Definition 1 (Negligible):**. Let $\e : \N \to \R$ be a function from
the natural to the real numbers such that $\forall \l \in N : \e(\l)
\geq 0$. We say that $\e$ is negligible (as a function of $\l$) if for any
positive polynomial $p$, there exists a constant $\l_0$ such that $\e(\l)
\leq 1/p(\l)$ for $\l > \l_0$.
$\enddef$

**Definition 2 (Statistical Distance):** Given two probability distributions
$P, Q$, the statistical distance between them is defined to be $SD(P, Q)
= \frac{1}{2} \sum_{y} |P(y) - Q(y)|$, where $P(y)$ (or $Q(y)$) is the
probability that $P$ (or $Q$) assigns to $y$.


**Definition 3 (Indistinguishability):** Given two probabilistic algorithms
(or families of distributions) $U, V$ , we say that:

- $U, V$ are perfectly indistinguishable, written $U \sim^p V$ , if $U_x =
  V_x$ for every $x$.
- $U, V$ are statistically indistinguishable, written $U \sim^s V$, if
  $SD(U_x, V_x)$ is negligible in the length of $x$.
- $U, V$ are computationally indistinguishable, written $U \sim^c V$ , if the
  following holds for every probabilistic polynomial time algorithm $D$:
  let $p_{U,D}(x)$ be the probability that $D$ outputs "$U$" as its guess when
  $D$’s input comes from $U$, and similarly $p_{V,D}(x)$ be the probability that $D$
  outputs "$U$" as its guess when $D$’s input comes from $V$. Then $|p_{U,D}(x)
  - p_{V,D}(x)|$ should be negligible in the length of $x$. This is the standard
  definition of "advantage" that is also used to define, e.g., the
  CPA security of encryption schemes.

  An alternative and equivalent definition: Let $D(U)$ be the algorithm
  that first runs $U$ on input $x$ to get result $y$, and then runs $D$ on
  input $y$ and $x$. Define $D(V)$ similarly. Then $U \sim^c V$ if and only if
  $D(U) \sim^s D(V)$ for every probabilistic polynomial time algorithm $D$.

Sometimes we do not want to consider how $U, V$ behave on arbitrary inputs
$x$, but only when $x$ is in some language $L$. We then say, e.g. $U ~^c V$

**Definition (Formal Commitment Schemes):**

- $\Gen(1^{\l}) \to pp$: $\Gen$, which takes as input $1^{\l}$ where $\l$ is a security
  parameter and corresponds to e.g. the length of the modulus we want. It
  outputs a string $pp$, the public parameters of the commitment scheme.
- $\CheckParams(pp) \to \{acc \lor rej\}$: $\CheckParams$ checks that
  the public parameters are valid and well-formed.
- $\Commit_{pp}(m; r) \to c$: $\Commit_{pp}$ commits to a message $b \in
  \B$ using randomness $r \in \B^{\l}$. We stick to bit-commitments here for
  simplicity.

**Definition (Binding):**

- **Unconditional/Perfect Binding:** Even with infinite computing power,
  $P$ should not be able to change his mind after committing. We require
  that if $pp$ is correctly generated, then $b$ is uniquely determined from
  $\Commit(b; r)$, i.e., for any $c$, there exists at most one $b$
  such that for some $r$ it holds that $c = \text{Commit}(b; r)$.
- **Computational Binding:** Unless $P$ has "very large" computing resources,
  then her chances of being able to change her mind should be very small. More
  precisely: take any probabilistic polynomial time algorithm $P^*$ which takes
  as input a public parameters $pp$ produced by $\Gen(1^{\l})$. Let $\e(\l)$
  be the probability (over the random choices of $\Gen$ and $P^*$) with which
  $P^*$ outputs $c, b, b', r, r'$ such that $b \neq b'$ and $\Commit(b; r)
  = \Commit(b'; r')$. Then, $\e(\l)$ should be negligible in $\l$.

**Definition (Hiding):**

- **Computational Hiding:** A polynomially bounded $V$ should have a hard
  time guessing what is inside a commitment. We require that $(pp, \Commit(0;
  r)) \sim^c (pp, \Commit(1; r'))$, where $r, r'$ are random variables that
  are uniformly distributed over $\B^{\l}$.
- **Unconditional Hiding:** A commitment to $b$ should reveal (almost) no
  information about $b$, even to an infinitely powerful $V$.
  - **Statistical Hiding:** We require that if we restrict to correctly
    generated $pp$’s, then $Commit(0; r) \sim^s Commit(1; r')$ (for uniformly
    distributed random variables $r, r'$).
  - **Perfect Hiding:** In the best possible case, we have $\Commit(0; r)
    \sim^p \Commit(1; r')$, i.e. commitments reveal no information whatsoever
    about the committed values.

# Zero-Knowledge

**Definition 1:** The pair $(P, V)$ is an interactive proof system for $L$
if it satisfies the following two conditions:

- **Completeness:** If $x \in L$, then the probability that $(P, V)$ rejects
  $x$ is negligible in the length of $x$.
- **Soundness:** If $x \notin L$ then for any prover $P^*$, the probability
  that $(P^*, V)$ accepts $x$ is negligible in the length of $x$.
$\enddef$


**Definition 2:** An interactive proof system or argument $(P, V)$ for language
$L$ is zero-knowledge if for every probabilistic polynomial time verifier
$V^*$, there is a simulator $\Sc_{V^*}$ running in expected probabilistic
polynomial time on inputs $x \in L$, such that we have $\Sc_{V^*} \sim^c (P, V^*)$
on input $x \in L$ and arbitrary $\d$ (as input to $V^*$ only).

For some protocols, we can obtain that $\Sc_{V^*} \sim^p (P, V^*)$, or
$\Sc_{V^*} \sim^s (P, V^*)$. In this case we speak of _perfect zero-knowledge_
or _statistical zero-knowledge_, respectively.
$\enddef$

**Definition (Honest-Verifier Simulator):** Suppose we are given a proof
system $(P, V)$ for language $L$. Suppose there exists a probabilistic
poly-time machine $\Sc_L$ with the property that $(P, V) \sim^p \Sc$ on
input $x \in L$. Then $\Sc$ is called a perfect honest-verifier simulator
(note that we use $V$ and not an arbitrary $V^*$ here).
$\enddef$
