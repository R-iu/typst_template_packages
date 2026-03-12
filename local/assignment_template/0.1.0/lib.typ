#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart, plot

#import "info.typ": assignment_author, assignment_student_id

// === Problem / Subproblem blocks ===

/// Creates a numbered problem block.
/// Automatically resets subproblem counter.
///
/// Example: `#problem[Matrix Multiplication]`
#let problem(title) = {
  counter("subproblem").update(0)
  counter("problem").step()
  block(width: 100%, below: 1em, above: 1.5em)[
    #set text(12pt, weight: "bold")
    Problem #context counter("problem").display(): #title
  ]
}

/// Creates a subproblem with (a), (b), etc.
///
/// Example: `#subproblem[Compute the eigenvalues]`
#let subproblem(title) = {
  counter("subproblem").step()
  block(below: 0.8em, above: 1.2em)[
    #set text(11pt, weight: "medium")
    #context counter("subproblem").display("(a)") #title
  ]
}

// === Plotting functions (unchanged) ===

/// Quick single-series plot (array or function).
///
/// #quick_plot(((0,0),(1,2)), x_label: "t", y_label: "y")
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

// === Main template function ===
#let assignment(
  title: "Assignment Title",
  author: "Author",
  student-id: "SID",
  course: "Course Name & Code",
  date: none, // defaults to today
  body,
) = {
  let display-date = if date == none { datetime.today().display() } else { date }

  // Page Setup
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    header: align(right, text(8pt, gray)[#title | #author]),
    numbering: "1",
  )

  // Base Text Styles
  set text(font: "New Computer Modern", size: 11pt)

  // Header Area
  grid(
    columns: (1fr, 1fr),
    align(left)[
      #text(16pt, weight: "bold")[#title] \
      #text(12pt, gray)[#course]
    ],
    align(right)[
      #text(11pt)[*#author*] \
      #text(11pt)[ID: #student-id] \
      #text(10pt, style: "italic")[#display-date]
    ],
  )

  line(length: 100%, stroke: 0.5pt + gray)
  v(1em)

  body
}
