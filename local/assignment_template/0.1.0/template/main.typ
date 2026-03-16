#import "@local/assignment_template:0.1.0": *

// --- Document Metadata ---

#let assignment_title = "Assignment Title"
#let assignment_course = "Course Name & Code"
#let assignment_date = none

#show: assignment.with(
  title: assignment_title,
  author: assignment_author,
  student-id: assignment_student_id,
  course: assignment_course,
  date: assignment_date,
)

// --- Document Content ---

// ============================================================================= //
//  QUICK REFERENCE — DELETE THIS BLOCK AFTER READING                            //
// ============================================================================= //
#block(
  width: 100%,
  fill: luma(245),
  stroke: (left: 4pt + blue),
  inset: 1.2em,
  radius: 4pt,
  [
    #text(12pt, weight: "bold")[How to use this template]

    • Structure: use `#problem[Title]` and `#subproblem[Title]` for automatic numbering. \
    • Plots: `#quick_plot(...)` or `#multi_plot(...)` (see examples below). \
    • Matrices: use helpers like `mat_add`, `mat_sub`, `mat_mul`, `mat_transpose`, `mat_inv_2x2`, and `matrix_step` for worked linear-algebra steps.

    #quick_plot(
      ((0, 0), (1, 2), (2, 3), (3, 5)),
      x_label: "Time (s)",
      y_label: "Value",
      caption: [Example of quick_plot],
    )

    #multi_plot(
      (0, 2 * calc.pi),
      (calc.sin, calc.cos),
      ([$sin x$], [$cos x$]),
      line: "spline",
      caption: [Example of multi_plot],
    )

    // Example: matrix_step usage (2×2 multiplication)
    #let A = ((1, 2), (3, 4))
    #let B = ((2, 0), (1, 2))
    #let final = matrix_step(B, m2: A, op: "*", n1: $B$, n2: $A$, target: $X$)
    $ final.content $

    #text(9pt, gray)[Delete this entire block once you're comfortable.]
  ],
)
// =============================================================================
