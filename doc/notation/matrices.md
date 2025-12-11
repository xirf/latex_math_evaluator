# Matrices

The library supports standard LaTeX matrix environments for defining matrices and performing matrix operations.

## Supported Environments

The following matrix environments are supported:
- `matrix`: Plain matrix (no brackets)
- `pmatrix`: Parentheses `( )`
- `bmatrix`: Square brackets `[ ]`
- `vmatrix`: Vertical bars `| |`

Note: While the parser recognizes these different environments, the evaluator treats them all as standard matrices. The visual distinction (brackets vs parentheses) is not preserved in the evaluation result, only the numerical structure.

## Syntax

Matrices are defined using the standard LaTeX syntax:
- `&` separates columns
- `\\` separates rows

```latex
\begin{matrix}
1 & 2 \\
3 & 4
\end{matrix}
```

## Operations

The following operations are supported for matrices:

### Addition and Subtraction
Matrices of the same dimensions can be added or subtracted.

```latex
\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix} + \begin{matrix} 5 & 6 \\ 7 & 8 \end{matrix}
```

### Matrix Multiplication
Matrices can be multiplied if their dimensions are compatible (columns of A = rows of B).

```latex
\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix} * \begin{matrix} 5 & 6 \\ 7 & 8 \end{matrix}
```

### Scalar Multiplication
Matrices can be multiplied by a scalar value.

```latex
2 * \begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}
```

### Negation
Matrices can be negated.

```latex
-\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}
```

## Examples

### Solving a System of Linear Equations (Representation)
While the library doesn't currently have a built-in solver, you can represent systems using matrices.

```latex
\begin{pmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{pmatrix}
```

### Transformations
Representing a 2D rotation matrix:

```latex
\begin{pmatrix}
\cos{\theta} & -\sin{\theta} \\
\sin{\theta} & \cos{\theta}
\end{pmatrix}
```
