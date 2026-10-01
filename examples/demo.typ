#import "../lib.typ": *
#let lang = sys.inputs.at("lang", default: "fr")
#let T(en, fr) = if lang == "fr" { fr } else { en }
#set page(paper: "a4", margin: 14mm)
#set text(font: "DejaVu Sans", size: 9pt)
#show heading: set text(weight: "bold")
#set heading(numbering: none)

= nibart — #T[an elliptical pen on a path, MetaPost-style][une plume elliptique sur un chemin, à la MetaPost]

#T[Paths smoothed by Hobby's algorithm (the same as METAFONT/MetaPost), exact envelope of the pen, all vector.][Chemins lissés par l'algorithme de Hobby (le même que METAFONT/MetaPost), enveloppe exacte de la plume, tout en vectoriel.]

== #T[1. Pen angle][1. Angle de la plume]
#T[Same path, pen `penellipse(16pt, 3pt, angle: θ)` for θ = 0°, 30°, 60°, 90°, 120°, 150°:][Même chemin, plume `penellipse(16pt, 3pt, angle: θ)` pour θ = 0°, 30°, 60°, 90°, 120°, 150° :]
#let wave = mp-path("(0,0)..(25,45)..(60,10)..(95,50)")
#grid(columns: 3, gutter: 6pt, row-gutter: 6pt, ..(0, 30, 60, 90, 120, 150).map(a =>
  mp-fig(draw(wave, pen: penellipse(14pt, 3pt, angle: a * 1deg)), mp-skeleton(wave, stroke: 0.25pt + red), pad: 4pt, frame: 0.3pt + luma(200))))

== #T[2. Hobby's tools: tension, curl, directions, control points][2. Les outils de Hobby : tension, curl, directions, points de contrôle]
#let show-path(spec, pen: pencircle(1.4pt), cap: none) = {
  let p = mp-path(spec)
  mp-fig(draw(p, pen: pen), mp-skeleton(p, stroke: 0.3pt + red), pad: 5pt, frame: 0.3pt + luma(200))
}
#grid(columns: 4, gutter: 6pt, row-gutter: 6pt,
  show-path("(0,0)..(40,50)..(80,0)"),
  show-path("(0,0)..tension 2..(40,50)..tension 2..(80,0)"),
  show-path("(0,0){up}..(40,50){right}..(80,0){down}"),
  show-path("(0,0){curl 4}..(40,50)..(80,0){curl 0}"),
  show-path("(0,0)..(40,50)--(80,0)..(120,40)"),
  show-path("(0,0)..controls (10,60) and (50,60)..(60,0)..(110,30)"),
  show-path("(0,0)..(40,50)..(80,0)..(40,-50)..cycle"),
  show-path("(0,0)..tension 1.5 and 4..(50,40)..(80,0)"),
)

== #T[3. Variable pen (one pen per node, interpolated along the path)][3. Plume variable (une plume par nœud, interpolée le long du chemin)]
#let s = mp-path("(0,0)..(30,55)..(70,50)..(95,5)..(130,40)")
#grid(columns: 3, gutter: 6pt,
  mp-fig(draw(s, pens: ((2pt, 2pt, 0deg), (14pt, 3pt, 40deg), (14pt, 3pt, 40deg), (3pt, 3pt, 40deg), (12pt, 12pt, 0deg))), pad: 6pt, frame: 0.3pt + luma(200)),
  mp-fig(draw(s, pens: t => (3pt + 2pt * t, 3pt, 15deg * t)), pad: 6pt, frame: 0.3pt + luma(200)),
  mp-fig(draw(s, pen: penrazor(16pt, angle: 35deg)), pad: 6pt, frame: 0.3pt + luma(200)),
)

== #T[4. Path operations][4. Opérations sur les chemins]
#let a = mp-path("(0,0)..(50,80)..(120,90)..(200,20)..(260,100)")
#let b = mp-path("(0,60)..(100,30)..(260,50)")
#let hits = intersection-times(a, b)
#mp-fig(
  draw(a, pen: pencircle(1.2pt), fill: blue), draw(b, pen: pencircle(1.2pt), fill: green.darken(20%)),
  draw(subpath(a, 1, 3), pen: penellipse(6pt, 2pt, angle: 30deg), fill: rgb("#e338")),
  ..hits.map(h => mp-dot(point-of(a, h.at(0)), pen: pencircle(5pt), fill: red)),
  mp-label(text(size: 7pt)[arclength(a) = #calc.round(arclength(a).pt(), digits: 1) pt · #hits.len() intersections], (130pt, 2pt), align: bottom + left),
  pad: 8pt, frame: 0.3pt + luma(200))

== #T[5. Latin letters with a broad nib (angle 40°)][5. Lettres latines à la plume plate (angle 40°)]
#let ital(p) = slanted(p, 0.22)
#let L = (
  o: "(12,15)..(0,15)..(12,30)..(24,15)..(12,0)..cycle",
  n: ("(0,30)..(0,0)", "(0,22){up}..(12,32)..(24,22){down}..(24,0)"),
  i: "(0,30)..(0,6){down}..(8,0)..(15,6)",
  u: ("(0,30)..(0,9){down}..(12,0)..(24,12){up}", "(24,30)..(24,4){down}..(32,4)"),
  l: "(0,80)..(0,8){down}..(8,0)..(15,6)",
  a: ("(24,16)..(12,0)..(0,14)..(12,30)..(24,18)", "(24,30)..(24,4){down}..(32,4)"),
  e: "(0,15)..(12,18)..(24,16){up}..(12,30)..(0,15)..(12,0)..(24,6)",
  m: ("(0,30)..(0,0)", "(0,22){up}..(12,32)..(24,22)..(24,0)", "(24,22){up}..(36,32)..(48,22)..(48,0)"),
  t: ("(6,60)..(6,8){down}..(14,0)..(20,6)", "(0,30)--(20,30)"),
)
#let glyph(k, nib, s) = {
  let parts = if type(L.at(k)) == str { (L.at(k),) } else { L.at(k) }
  parts.map(sp => draw(ital(scaled(mp-path(sp, unit: 1pt), s)), pen: nib))
}
#let show-word(w, s: 0.7, gap: 11, nib: broadnib(5pt, t: 1.3pt, angle: 40deg), fill: black) = {
  let x = 0pt
  let cells = ()
  for ch in w {
    let k = str(ch)
    let adv = (o: 30, n: 30, i: 18, u: 36, l: 18, a: 38, e: 30, m: 54, t: 26).at(k)
    let parts = if type(L.at(k)) == str { (L.at(k),) } else { L.at(k) }
    for sp in parts { cells.push(draw(ital(shifted(scaled(mp-path(sp), s), x, 0pt)), pen: nib, fill: fill)) }
    x += (adv + gap) * s * 1pt
  }
  mp-fig(..cells, pad: 6pt)
}
#show-word("minimum", s: 1.0) #h(1em) #show-word("animal", s: 1.0)
#v(2pt)
#show-word("mule", s: 1.6, nib: broadnib(8pt, t: 2pt, angle: 40deg))

== #T[6. Arabic letters (naskh style, nib at 62°)][6. Lettres arabes (style naskh, plume à 62°)]
#let N = broadnib(4.2pt, t: 1.1pt, angle: 62deg)
#let A = (
  "ا": ("(0,0)..(0,30)..(0,62)",),
  "ب": ("(50,20){down}..(40,3)..(18,0)..(2,14)", "(2,14)..(0,20)"),
  "د": ("(0,0)..(18,4)..(26,20)..(14,34)", "(14,34)..(26,36)"),
  "ر": ("(14,30)..(12,0)..(0,-14)",),
  "و": ("(10,18)..(0,10)..(10,0)..(20,10)..(10,18)..cycle", "(20,10)..(18,-10)..(4,-26)"),
  "ن": ("(40,18){down}..(30,0)..(10,-4)..(0,14)",),
  "م": ("(10,22)..(0,14)..(10,6)..(22,14)..cycle", "(22,14)..(24,-16)..(10,-30)"),
)
#let dots(k) = if k == "ب" { ((20pt, -10pt),) } else if k == "ن" { ((18pt, 30pt),) } else { () }
#let letter(k, s: 1.0) = mp-fig(
  ..A.at(k).map(sp => draw(scaled(mp-path(sp), s), pen: N)),
  ..dots(k).map(d => mp-dot((d.at(0) * s, d.at(1) * s), pen: pencircle(3.6pt * s))),
  pad: 6pt, frame: 0.3pt + luma(200))
#grid(columns: 7, gutter: 6pt, ..("ا", "ب", "د", "ر", "و", "ن", "م").map(k => letter(k, s: 1.2)))
