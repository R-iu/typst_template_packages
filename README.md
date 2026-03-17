# Typst Local Packages

This repository contains local Typst packages, along with a small helper script to install them into Typst's local package directory.

Currently it includes:

- `assignment_template` (`local/assignment_template/0.1.0`)

## Repository layout

- `local/` – Namespace for local Typst packages.
  - `assignment_template/0.1.0/` – A private assignment template package.
    - `typst.toml` – Package metadata (name, version, entrypoint, description, etc.).
    - `lib.typ` – Main library file exported by the package.
    - `template/` – Template entrypoint and related files (e.g. `main.typ`).
- `install.sh` – Script to copy the packages in `local/` into Typst's local package directory.
- `assignment-preview.png` – Screenshot of the assignment template (first page).
- `LICENSE` – MIT No Attribution (MIT-0) license.

## Installation

You can install the packages into your Typst local package directory with:

```bash
chmod +x install.sh        # only needed once
./install.sh
```

By default the script installs to:

- **Linux**: `${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages`
- **macOS**: `$HOME/Library/Application Support/typst/packages`
- **Windows** (Git Bash, MSYS2, Cygwin): `%APPDATA%\typst\packages` (e.g. `C:\Users\<you>\AppData\Roaming\typst\packages`)

You can override the destination by setting `TYPST_PACKAGE_DIR`:

```bash
TYPST_PACKAGE_DIR="/path/to/typst/packages" ./install.sh
```

## Using the packages in Typst

After running `install.sh`, Typst should see the package under the `local` namespace. For example, you can import the assignment template in a Typst document as:

```typ
import "@local/assignment_template:0.1.0": *
```

Adjust the version or imported symbols as needed for your document.

## Template display

The assignment template provides a document layout and helpers for typed assignments, plotting, and small linear-algebra demos.

![Assignment template preview](./assets/assignment-preview.png)

**Page**

- A4, 2.5 cm margins
- Header: right-aligned, small gray text `Title | Author`
- Page numbering: `1`, `2`, …

**Header block**

- Two-column grid at the top of the first page:
  - **Left:** Assignment title (16 pt bold), course name/code (12 pt gray)
  - **Right:** Author (italic), student ID, date (italic; defaults to today)
- A horizontal rule separates the header from the body.

**Body**

- Base font: New Computer Modern, 11 pt
- Use `#problem[Title]` and `#subproblem[Title]` for auto-numbered problems and (a), (b), …
- Use `#quick_plot(...)` and `#multi_plot(...)` for inline plots (via CeTZ).
- Use the matrix helpers from `lib.typ` (`mat_add`, `mat_sub`, `mat_mul`, `mat_transpose`, `mat_inv_2x2`, etc.) to perform basic matrix operations inside your solutions.
- Use `matrix_step(..)` to both **compute** and **display** a step-by-step matrix equation, returning structured data and a nicely formatted math equation.

**Template files**

- Compile `template/main.typ` to build a document. It uses `info.typ` for your personal metadata (author, student ID, course, optional date); edit `info.typ` (or a copy like `info.typ.example`) with your details.
- The template’s quick-start prompt at the top of `main.typ` shows example usage of `problem`, `subproblem`, plotting helpers, and matrix helpers via `matrix_step`.

### Matrix calculation helpers

After importing the package:

```typ
import "@local/assignment_template:0.1.0": *
```

you can use the matrix helpers directly in your solutions.

**Supported operations (`lib.typ`)**

- **Element-wise addition**: `mat_add(A, B)` – only if A and B have exactly the same shape.
- **Element-wise subtraction**: `mat_sub(A, B)` – only if A and B have exactly the same shape.
- **Matrix multiplication**: `mat_mul(A, B)` – allowed whenever the number of columns of A equals the number of rows of B.
- **Element-wise application of a scalar function**: `mat_apply(A, f)` – applies `f` to every entry of A.
- **Scalar multiplication**: `mat_scale(k, A)` – multiplies every entry of A by the scalar `k`.
- **Row-wise softmax**: `mat_softmax(A)` – for each row, applies `exp` and normalizes by the row sum.
- **Transpose**: `mat_transpose(A)` – works for any rectangular matrix.
- **2×2 inverse**: `mat_inv_2x2(A)` – only defined for 2×2 matrices with non-zero determinant.
- **Activation functions on scalars**: `relu(x)`, `sigmoid(x)`.
- **Rounding**: `round_mat(A, dp: 4)` – rounds every entry to `dp` decimal places.

**Unified step display with `matrix_step`**

`matrix_step` wraps the above operations and produces both:

- `content`: a formatted Typst math equation for the derivation.
- `data`: the resulting numeric matrix.

Supported `op` values and their meaning:

- `"+"` – uses `mat_add(m1, m2)`.
- `"-"` – uses `mat_sub(m1, m2)`.
- `"*"` or `""` – uses `mat_mul(m1, m2)`.
- `"scale"` – uses `mat_scale(k, m1)` (scalar `k` required).
- `"transpose"` or `"T"` – uses `mat_transpose(m1)`.
- `"inv"` – uses `mat_inv_2x2(m1)` (2×2 only).
- `"relu"` – applies `relu` element-wise via `mat_apply`.
- `"sigmoid"` – applies `sigmoid` element-wise via `mat_apply`.
- `"softmax"` – uses `mat_softmax(m1)` (row-wise).
- `"sinh"`, `"cosh"`, `"tanh"` – uses `calc.sinh`, `calc.cosh`, or `calc.tanh` element-wise via `mat_apply`.

Example:

```typ
// 2×2 matrices
let A = ((1, 2), (3, 4))
let B = ((2, 0), (1, 2))

// Single documented step: C = A · B
let step = matrix_step(A, B) // defaults: op: "*", n1: "A", n2: "B", target: "C"
$ step.content $

// Numeric result matrix
let C = step.data
```

## License

This repository is licensed under the **MIT No Attribution License (MIT-0)**. See [LICENSE](LICENSE) for the full text. You may use, copy, modify, and distribute the software for any purpose without attribution.
