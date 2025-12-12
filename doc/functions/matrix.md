# Matrix Functions

Advanced operations for matrices.

## Determinant

Calculates the determinant of a square matrix.

### Syntax

```latex
\det(matrix)
```

### Examples

- `\det(\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix})` evaluates to `-2`.

## Inverse

Calculates the inverse of a square matrix.

### Syntax

```latex
matrix^{-1}
```

### Examples

- `\begin{pmatrix} 4 & 7 \\ 2 & 6 \end{pmatrix}^{-1}` evaluates to `[[0.6, -0.7], [-0.2, 0.4]]`.

## Transpose

Calculates the transpose of a matrix.

### Syntax

```latex
matrix^T
```

### Examples

- `\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}^T` evaluates to `[[1, 3], [2, 4]]`.

## Trace

Calculates the trace (sum of diagonal elements) of a square matrix.

### Syntax

```latex
\trace{matrix}
\tr{matrix}
```

### Examples

- `\trace{\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}}` evaluates to `5` (1 + 4).
