// === External packages & configuration ===
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart, plot
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#import "info.typ": assignment_author, assignment_student_id


// === Problem & subproblem blocks ===
/// Numbered problem block. Resets the subproblem counter and increments the problem counter.
/// - *title*: Heading text for the problem.
#let problem(title) = {
  counter("subproblem").update(0)
  counter("problem").step()
  block(width: 100%, below: 1em, above: 1.5em)[
    #set text(1.4em, weight: "bold")
    Problem #context counter("problem").display(): #title
  ]
}

/// Numbered subproblem within the current problem, labeled (a), (b), etc.
/// - *title*: Heading text for the subproblem.
#let subproblem(title) = {
  counter("subproblem").step()
  block(below: 0.8em, above: 1.2em)[
    #set text(1.2em, weight: "bold")
    #context counter("subproblem").display("(a)") #title #linebreak()
  ]
}

// === Plotting helpers ===
/// Single-series figure: plot from an array of points or a function over a domain.
/// - *data*: Array of (x, y) pairs or a function of one argument.
/// - *domain*: Required when *data* is a function; (min, max) for x.
/// - *samples*, *line*, *x_label*, *y_label*, *caption*: Plot options.
#let quick_plot(
  data,
  domain: none,
  samples: 100,
  line: "linear",
  x_label: "x",
  y_label: "f(x)",
  caption: none,
) = figure(
  cetz.canvas(length: 0.4cm, {
    plot.plot(size: (12, 8), x-label: x_label, y-label: y_label, {
      if type(data) == function {
        assert(domain != none, message: "quick_plot: set domain when data is a function")
        plot.add(
          domain: domain,
          data,
          samples: samples,
          line: line,
          style: (stroke: blue, fill: none),
        )
      } else {
        plot.add(
          data,
          mark: "o",
          line: line,
          style: (stroke: blue, fill: none),
          mark-style: (stroke: blue, fill: blue.lighten(80%)),
        )
      }
    })
  }),
  caption: caption,
)

/// Multi-series figure: plot up to 4 functions over a common domain with a legend.
/// - *domain*: (min, max) for x.
/// - *fns*: Array of functions (one argument).
/// - *labels*: Array of legend labels, same length as *fns*.
/// - *samples*, *line*, *x_label*, *y_label*, *caption*: Plot options.
#let multi_plot(
  domain,
  fns,
  labels,
  samples: 200,
  line: "linear",
  x_label: "x",
  y_label: "f(x)",
  caption: none,
) = figure(
  cetz.canvas(length: 0.4cm, {
    plot.plot(
      size: (12, 8),
      x-label: x_label,
      y-label: y_label,
      legend: auto,
      {
        assert(fns.len() <= 4)
        assert(labels.len() == fns.len())

        let colors = (blue, red, green, orange)

        for (i, fn) in fns.enumerate() {
          plot.add(
            domain: domain,
            fn,
            samples: samples,
            line: line,
            style: (stroke: colors.at(i), fill: none),
            label: labels.at(i),
          )
        }
      },
    )
  }),
  caption: caption,
)

// === Matrix operations & math utilities ===
/// Element-wise sum of two matrices. Matrices must have the same dimensions.
#let mat_add(A, B) = {
  assert(A.len() == B.len() and A.at(0).len() == B.at(0).len(), message: "Matrix dimensions must match for addition")
  range(A.len()).map(i => range(A.at(0).len()).map(j => A.at(i).at(j) + B.at(i).at(j)))
}

/// Element-wise difference A - B. Matrices must have the same dimensions.
#let mat_sub(A, B) = {
  assert(A.len() == B.len() and A.at(0).len() == B.at(0).len(), message: "Matrix dimensions must match for subtraction")
  range(A.len()).map(i => range(A.at(0).len()).map(j => A.at(i).at(j) - B.at(i).at(j)))
}

/// Matrix product A×B. Requires A columns equal to B rows.
#let mat_mul(A, B) = {
  let rows_A = A.len()
  let cols_A = A.at(0).len()
  let rows_B = B.len()
  let cols_B = B.at(0).len()

  assert(cols_A == rows_B, message: "Matrix dimensions do not match for multiplication")

  let result = range(rows_A).map(_ => range(cols_B).map(_ => 0))

  for i in range(rows_A) {
    for j in range(cols_B) {
      let sum = 0
      for k in range(cols_A) {
        sum += A.at(i).at(k) * B.at(k).at(j)
      }
      result.at(i).at(j) = sum
    }
  }
  return result
}

/// Apply a scalar function to every element of a matrix.
#let mat_apply(A, f) = A.map(row => row.map(v => f(v)))

/// Scale matrix by scalar k (element-wise).
#let mat_scale(k, A) = mat_apply(A, v => k * v)

/// Row-wise softmax: each row is normalized by exp(row) / sum(exp(row)).
/// - *dp*: Decimal places for rounding the result.
#let mat_softmax(A, dp: 4) = {
  A.map(row => {
    let exps = row.map(v => calc.exp(v))
    let sum_exp = exps.sum()
    exps.map(e => calc.round(e / sum_exp, digits: dp))
  })
}

/// ReLU activation: max(0, x).
/// - *dp*: Decimal places for rounding the result.
#let relu(x, dp: 4) = calc.round(calc.max(0, x), digits: dp)

/// Sigmoid activation: 1 / (1 + exp(-x)).
/// - *dp*: Decimal places for rounding the result.
#let sigmoid(x, dp: 4) = calc.round(1 / (1 + calc.exp(-x)), digits: dp)

/// Round each matrix element to *dp* decimal places.
#let round_mat(M, dp: 4) = M.map(row => row.map(v => calc.round(v, digits: dp)))

/// Transpose matrix M (rows become columns).
#let mat_transpose(M) = {
  let rows = M.len()
  let cols = M.at(0).len()
  range(cols).map(c => range(rows).map(r => M.at(r).at(c)))
}

/// Inverse of a 2×2 matrix. Fails if singular.
#let mat_inv_2x2(M) = {
  assert(M.len() == 2 and M.at(0).len() == 2, message: "Inverse support is currently 2x2 only")
  let det = M.at(0).at(0) * M.at(1).at(1) - M.at(0).at(1) * M.at(1).at(0)
  assert(det != 0, message: "Matrix is singular and cannot be inverted")
  let adj = (
    (M.at(1).at(1), -M.at(0).at(1)),
    (-M.at(1).at(0), M.at(0).at(0)),
  )
  return mat_scale(1.0 / det, adj)
}

/// Render a nested array as a Typst math matrix (content).
#let show_mat(M) = math.mat(..M.map(row => row.map(val => [#val])))


/// Perform one matrix operation and return both rendered equation and numeric result.
/// - *m1*, *m2*: Input matrices (*m2* required for "+", "-", "*").
/// - *op*: "+", "-", "*", "scale", "transpose"/"T", "inv", "relu", "sigmoid", "softmax", "sinh", "cosh", "tanh".
/// - *n1*, *n2*, *target*: Symbol names used in the equation.
/// - *k*: Scalar for "scale".
/// - *dp*: Decimal places for rounding.
/// Returns: (content: equation, data: result matrix).
#let matrix_step(
  m1,
  m2: none,
  op: "*",
  n1: $A$,
  n2: $B$,
  target: $C$,
  k: none,
  dp: 4,
) = {
  let raw_res = if op == "+" {
    mat_add(m1, m2) 
  } else if op == "-" {
    mat_sub(m1, m2) 
  } else if op == "*" or op == "" {
    mat_mul(m1, m2)
  } else if op == "scale" {
    mat_scale(k, m1) 
  } else if op == "transpose" or op == "T" {
    mat_transpose(m1) 
  } else if ( op == "inv") {
    mat_inv_2x2(m1) 
  } else if op == "relu" { 
    mat_apply(m1, v => relu(v, dp: dp)) 
  } else if op == "sigmoid" {
    mat_apply(m1, v => sigmoid(v, dp: dp))
  } else if op == "softmax" {
    mat_softmax(m1, dp: dp) 
  } else if op in ("sinh", "cosh", "tanh") {
    let f = if op == "sinh" { calc.sinh } else if op == "cosh" { calc.cosh } else { calc.tanh }
    mat_apply(m1, f)
  } else { 
    panic("Unsupported operation: " + op)
  }

  let res = round_mat(raw_res, dp: dp)
  let m1_rounded = round_mat(m1, dp: dp)

  let equation = if op in ("transpose", "T") {
    // Shows: Target = (Matrix)^T = Result
    $ #target = #show_mat(m1_rounded)^T = #show_mat(res) $
  } else if op == "inv" {
    // Shows: Target = (Matrix)^-1 = Result
    $ #target = #show_mat(m1_rounded)^(-1) = #show_mat(res) $
  } else if op in ("+", "-", "*", "") {
    let m2_r = round_mat(m2, dp: dp)
    let sym = if op in ("*", "") { "" } else { " " + op + " " }
    let n_sym = if op in ("*", "") { "" } else { op }
    $ #target = #n1 #n_sym #n2 = #show_mat(m1_rounded) #sym #show_mat(m2_r) = #show_mat(res) $
  } else if op == "scale" {
    // Shows: Target = k A = k (Mat) = Result
    $ #target = #k #n1 = #k #show_mat(m1_rounded) = #show_mat(res) $
  } else {
    // Functions (tanh, sigmoid, etc.)
    let f_sym = if op == "sigmoid" { $sigma$ } else if op == "relu" { $italic("ReLU")$ } else if op == "softmax" {
      $italic("softmax")$
    } else { math.op(op) }
    // Shows: Target = f(n1) = f(Mat) = (f(x1)...) = Result
    $ #target = #f_sym (#n1) = #f_sym #show_mat(m1_rounded) = #show_mat(res) $
  }

  return (content: equation, data: res)
}

// === Main assignment template ===
/// Assignment document template: title, course, author, student ID, date, and body.
/// Sets A4 page, margins, header, and base text style; renders a two-column header and body.
#let assignment(
  title: "Assignment Title",
  author: "Author",
  student-id: "SID",
  course: "Course Name & Code",
  date: none,
  body,
) = {
  let display-date = if date == none { datetime.today().display() } else { date }
  let author-display = author.replace(", ", "\n").replace(",", "\n")

  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    header: align(right, text(8pt, gray)[#title | #author]),
    numbering: "1",
  )

  set text(font: "New Computer Modern", size: 11pt)

  grid(
    columns: (1fr, 1fr),
    align(left)[
      #text(16pt, weight: "bold")[#title] \
      #text(12pt, gray)[#course]
    ],
    if student-id != none {
      align(right)[
        #text(11pt)[*#author-display*] \
        #text(11pt)[ID: #student-id] \
        #text(10pt, style: "italic")[#display-date]
      ]
    } else {
      align(right)[
        #text(11pt)[*#author-display*] \
        #text(10pt, style: "italic")[#display-date]
      ]
    },
  )

  line(length: 100%, stroke: 0.5pt + gray)
  v(1em)

  body
}
