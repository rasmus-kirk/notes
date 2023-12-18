---
title: Cryptography Notes
author: 
- Rasmus Kirk Jakobsen
- Mikkel Skafsgaard Berg
date: \today
geometry: margin=2cm
fontsize: 11pt
#linkcolor: blue
header: |
  \usepackage[style=iso]{datetime2}
  \usepackage{amsmath,bm}
  \newcommand*\mod{\bmod}
  \newcommand*\Z{\mathbb{Z}}
  \newcommand*\E{\mathbb{E}}
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

# Curriculum

**Background material:**

Chapters 2+3 (preliminary probability theory and math), Section 5.4
(optimistic results on key exchange), Section 6.3 (diff and lin analysis),
Proof of Theorem 7.8 (if you can get the secret exponent you can factor),
Section 7.6.1 (factoring algorithms), Section 9.6 (discrete log algorithms).

**Example Templates:**

Here are some details on what you might for instance cover in each the exam
subject. But do not misunderstand this in the sense that you have to follow
the templates below, they really are just examples...

**Information theory and Cryptography:**

Definition of perfect secret security, why you need as many keys at plaintexts
to have perfect security. Definition of entropy, and proof of some of the
inequalities properties it satisfies. Unicity distance (but be careful,
this may take a lot of time, so test this beforehand)

**Symmetric (secret-key) cryptography:**

What a crypto-system is (the three algorithms) You can describe DES or AES -
but you can also just give a high-level description of what a block cipher
is. Definitions of PRF and CPA security. Specification of CBC or CTR modes
(or both), proofs of CPA security for CBC or CTR mode (or both). Perhaps a
brief talk about stream ciphers and how to make one from a block cipher.

**Public-key cryptography from Factoring:**

What a public-key cryptosystem is. Basic spec of RSA, maybe proof that
decryption works. Then some selection of the following: How to make RSA be CPA
secure (the PCRSA scheme, and the result that computing the least significant
bit is as hard as inverting RSA). How to generate keys and Miller-Rabin
primality testing, how to get CCA security: OAEP and the intuition on why
it works.

**Public-key cryptography based on discrete log and LWE:**

The DL, DH and DDH problems, and how they relate. The El Gamal cryptosystem
and proof that it is secure if DDH is hard. Then some example of groups we
can use, can be a subgroup of $\Z_p^*$, or you can talk about elliptic curves. You
can also put less emphasis on El Gamal, for instance skip the example groups
and go to LWE instead, define the problem and the cryptosystem and do the
proof from the exercise that decryption works under a certain assumption
about the noise distribution.

**Symmetric authentication and hash functions:**

Definition of collision-intractable hash functions. Then a selection of:
construction from discrete log, proof that collision-intractable implies
one-way, construction and proof that we can get any size input from fixed
size input. Finally, MAC schemes, definition of CMA security, CBCMAC and
EMAC security result for EMAC. Maybe a brief mention of HMAC.

**Signature schemes:**

Definition of signatures schemes and of CMA security. The Schnorr signature
scheme, you can do many details here, such as the proof that you cannot
cheat the underlying interactive game with better than 1/q probability, and
the full story on how you derive the signature scheme from the interactive
game. Or you can just do the spec of the scheme, giving you time for something
else, such as RSA+hash signatures and the proof that secure hash + secure
signature scheme is secure. Or you can do the one-time signatures based on
hash functions and the proof that they are secure.

\newpage

# Basic Facts from Probability Theory

**Theorem 2.4 (Jensen's inequality):** Let $p_1, ..., p_n$ be a probability
distribution, that is, $\sum_i p_i = 1$ and $0 \leq p_i \leq 1$. Then for
any concave $f$ and any $x_1, .., x_n$, we have:

$$\sum^n_{i=1} p_i f(x_i) \leq f(\sum^n_{i=1} p_i x_i)$$

Furthermore, if $f$ is strictly concave, equality holds **iff** all the
$x_i$'s are equal.  
**TLDR: $f(\E[X]) \leq \E[f(X)]$**

**Note:** _Concave_ means that $\frac{f(a) + f(b)}{2} \leq \frac{a + b}{2}$.  
**TLDR:** $f'' = 0$.

**Note:** _Strictly concave_ means that $\frac{f(a) + f(b)}{2} < \frac{a +
b}{2}$ for all $a \neq b$.  
**TLDR:** This basically means that graph of the function always curves and
is never linear.

**Note:** For this course, we only apply this to $\log()$ which is strictly
concave.
$\enddef$

\pagebreak

# Information theory and Cryptography (Chapter 5)

**Disposition (Kirk):**

<!-- TODO: Add subbullets -->
- Perfect Security
- Entropy
- Unicity Distance

**Disposition (Berg):**

## Perfect Security

Below we have the definition for perfect security:

**Definition 5.1:** A cryptosystem has perfect security if for all $x \in
\plainspace$ and $y \in \cipherspace$, it holds that $P[x|y] = P[x].$  
**TLDR:** Information about the ciphertext gives you _no_ information about
the plaintext.
$\enddef$

**Theorem - $|\keyspace| \geq |\cipherspace| \geq |\plainspace|$:** If you have
perfect security then $|\keyspace| \geq |\cipherspace| \geq |\plainspace|$.  
**TLDR:** If you have perfect security your key can not be shorter than your
ciphertext, which cannot be shorter than your plaintext.
$\enddef$

_Proof:_

- $|\cipherspace| \geq |\plainspace|$: This is true for all crypto systems in
order for decryption to function correctly.

- $|\keyspace| \geq |\cipherspace|$: For a fixed plaintext $x$ must be able to
hit every ciphertext $y$, otherwise an adversary could conclude that $E(x)
\neq y$ and therefore learn information from $y$.

Therefore, given perfect security, you have $|\keyspace| \geq |\cipherspace|
\geq |\plainspace|$.
$\qed$

## Entropy

> _As a further illustration of the intuition behind entropy, consider
  the following thought experiment: suppose you get access to an oracle that
  will magically tell you if you will live to be more than 110 years old. One
  would naturally expect that the probability p of getting “yes” as the
  answer is very small, while the probability $1 - p$ of "no" is close to 1._

**Definition 5.6:** Let $X$ be a random variable that takes values $x_1,
..., x_n$ with probabilities $p_1, ..., p_n.$ Then the entropy of $X$,
written $H(X)$, is defined to be: 
$$H(X) = \sum^n_{i=1} p_i \log_2(1/p_i)$$
**TLDR:** If an event $A$ occurs with probability $p$ and you are told that
$A$ occurred, then you have learned $\log_2(1/p)$ bits of information.
**TLDR:** The entropy $H(X)$ can be described as: 

- How many bits we need to send on average to communicate the value of $X$.
- The amount of uncertainty you have about $X$ before you are told what the
  value is.
$\enddef$


**Theorem 5.7:** For a random variable $X$ taking $n$ possible values, it
holds that $0 \leq H(X) \leq \log_2(n)$. Furthermore, $H(X) = 0$ **iff**
one value $X$ has probability 1 (and the others 0). $H(X) = log_2(n)$ **iff**
it is uniformly distributed, i.e., all probabilities are $1/n$.  
**TLDR:** If the entropy of $X$ is 0 there is no uncertainty, meaning that
we know the value of $X$. If the entropy of $X$ is 1 then the uncertainty
of $X$ is highest meaning that all possible values of $X$ have the same
probability.
$\enddef$

_Proof:_ We need to prove the following:

- $H(X) > 0$
  - $H(X)$ is defined as a product of positive sums, therefore $H(X)$ is also positive.
- $H(X) = 0$ **iff** a single $p_i = 1$ and all other $p_j = 0$
  - The function $f(p) = p \log(1/p)$ is only 0 if $p = 0 \lor p = 1$. This
    coupled with the fact that probabilities must sum up to one means that 
    $H(X) = 0$ **iff** a single $p_i = 1$ and all other $p_j = 0$.
- $H(X) < \log_2(n)$
  - $\log$ is a concave function ($\log'' = 0$) therefore we can use Theorem
    2.4 (Jensen's inequality):  
    $$H(X) = \sum^n_{i=1} p_i \log_2(1/p_i) \leq \log_2(\sum^n_{i=1} p_i \cdot 1/p_i) = \log_2(n)$$  
    Thus $H(X) < \log_2(n)$.
- $H(X) = \log_2(n)$ **iff** $X$ is uniformly distributed.
  - Since $log_2$ is strictly concave then from Theorem 2.4 we know
    that $H(X) = \log_2(n)$ **iff** all $p_i$ are equal i.e. $X$ is uniformly
    distributed.
$\qed$

## Conditional Entropy

<!-- TODO: Above definition? lol -->

**Definition 5.9:** Given the above definition of $H(X \;|\;Y = y_j)$, we define
the conditional entropy of X given Y to be:
$$H(X \;|\; Y) = \sum_j P[Y = y_j] H(X \;|\; Y = y_j)$$

## Entropy of Random Variables in Cryptography

**Theorem 5.11:** For any cryptosystem with deterministic encryption function, it
holds that:
$$H(K \;|\; C) = H(K) + H(P) - H(C)$$
**TLDR:** Answers how much uncertainty remains about the key given the ciphertext
<!-- TODO: Include Proof? -->

## Unicity Distance

**Definition - Redundancy:** Given a language $L$ and a plaintext space $\plainspace$,
the _redundancy_ of the language is the amount of superflous information is
contained, on avarage in the language $L$.
$$R_L = \frac{\log(|\plainspace|) - H_L}{\log(|\plainspace|)} = 1 - \frac{H_L}{\log(|\plainspace|)}$$
$H_L$ is a measure of the number of bits of information each letter contains
in the language $L$, on average. For English, we have that $H_L$ is (very
approximately) 1.25 bits per letter.
$$H_L = \lim_{n \mapsto \infty} H(P_n)/n$$  
**TLDR:** A language contains redundancy, which is how much duplicate
information there is on avarage in the language.  
**Example:** The following sentance displays redundancy in english:

> _"cn y rd th fllwng sntnc, vn f t s wrttn wtht vcls?"_

$\enddef$

**Definition - Spurious Keys:** If an adversary has a ciphertext $y$ that
he wants to decrypt, he can try all keys and see if $y$ decrypts to meaningful
english. If $y$ decrypts to meaningful english under the _wrong_ key, then
that key is said to be a _spurious key._  
**TLDR:** A spurious key is a key that _seems_ to be the correct key for a
ciphertext but is not.
$\enddef$

**Definition - Number of Spurious Keys:** The average number of
spurious keys, taken over all choices of ciphertexts of length $n$: 
$$sp_n = \sum_{\vec{y} \in \cipherspace^n} P[y](|K(\vec{y})| - 1) = \sum_{\vec{y} \in \cipherspace^n} P[y]|K(\vec{y})| - 1$$
Given a ciphertext $\vec{y}$, we use $K(\vec{y})$ to denote the set of keys
that are possible given this ciphertext. More precisely, a key $K$ is in
this set if decryption of $\vec{y}$ under $K$ yields a plaintext that could
occur with non-zero probability:
$$K(\vec{y}) = \{ K \in \keyspace \; | \; P[D_K(\vec{y} > 0)]\}$$
**TLDR:** This formula for $sp_n$ describes the average number of spurious
keys of a ciphertext $\vec{y}$ of length $n$.

$\enddef$

**Definition 5.12:** The unicity distance $n_0$ of a cryptosystem is the
minimal length of plaintexts such that $sp_{n_0} = 0$, if such a value exists,
and $\infty$ otherwise.  
**TLDR:** The unicity distance tells you how many times you can encrypt
something where multiple keys seem to be valid keys.
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

**Proof:** We start by unfolding the definition of $H(K \;|\; C_n)$ using Definition 5.9:

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
      && \text{(Definition - Number of Spurious Keys)} \\
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
## Disposition (Kirk)

<!-- TODO: Add subbullets -->
- Definitely AES
- PRF and CPA security
- CBC/CTR
- CPA security proof for CBC/CTR
- At least understand the block cipher...

## Disposition (Berg)
- Symmetric Cryptosystem definition (chap 4.1)
- DES definition
  - Feistel ciphers
- AES definition 
- (High level definition of Block Ciphers)
- PRF security 
- CPA security 
- CBC mode
- CTR mode 
- Stream ciphers 
- (Differential & Linear Cryptanalysis)

## Notes

### Symmetric Cryptosystems
![Symmetric Cryptosystem](images/symmetric_cryptosystem.jpg)
(Optionally something related to confidentiality and authenticity)

For a symmetric system, there are 3 finite sets given; the key
space $\kappa$, the plaintext space $\rho$ and the ciphertext space $\cipherspace$.

\newpage

# Public-key cryptography from Factoring (Chapter 7 & 8)
## Disposition (Kirk)

## Disposition (Berg)

## Notes

\newpage

# Public-key cryptography based on discrete log and LWE (Chapter 9 & 10, definition of CPS security in chapter 8)
## Disposition (Kirk)

## Disposition (Berg)

## Notes

\newpage

# Symmetric authentication and hash functions (Chapter 11)
## Disposition (Kirk)

## Disposition (Berg)

## Notes

\newpage

# Signature schemes (Chapter 12)
## Disposition (Kirk)

## Disposition (Berg)

## Notes

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

