#import "../lib.typ": *
#let lang = sys.inputs.at("lang", default: "fr")
#let T(en, fr) = if lang == "fr" { fr } else { en }
#set page(paper: "a4", margin: (x: 14mm, y: 14mm), fill: rgb("#fbf7ee"))
#set text(font: "DejaVu Sans", size: 9pt, fill: rgb("#2b2118"))
#show heading.where(level: 2): it => block(above: 14pt, below: 6pt, text(size: 11pt, weight: "bold", fill: rgb("#7a3b12"), it.body))

#let ink = rgb("#1d2a44")
#let gold = rgb("#b07a1c")
#let teal = rgb("#1c7a78")
#let brick = rgb("#9a3324")
#let n(x) = str(calc.round(x, digits: 3))
#let pt-list(pts) = pts.map(p => "(" + n(p.at(0)) + "," + n(p.at(1)) + ")")
#let spec-of(pts, cycle: false) = pt-list(pts).join("..") + if cycle { "..cycle" } else { "" }
#let polar(r, a) = (r * calc.cos(a), r * calc.sin(a))

#align(center)[
  #text(size: 22pt, weight: "bold", fill: rgb("#7a3b12"))[nibart — #T[a gallery of pens][galerie de plumes]]\
  #text(size: 9pt)[#T[Hobby paths · exact elliptical pen · variable pen · path operations — all vector][Chemins de Hobby · plume elliptique exacte · plume variable · opérations de chemin — tout en vectoriel]]
]

== #T[1. Broad-nib rosette (fixed angle 30°: the thickness “breathes” with the direction)][1. Rosace à la plume plate (angle fixe 30° : l'épaisseur « respire » avec la direction)]
#let petal(a, b) = mp-path("(0,0)..(" + n(a * 0.5) + "," + n(b) + ")..(" + n(a) + ",0)..(" + n(a * 0.5) + "," + n(-b) + ")..cycle")
#let ring(k, a, b, phase, col, w) = range(k).map(i => draw(rotated(petal(a, b), (phase + i * 360 / k) * 1deg), pen: broadnib(w, t: w / 6, angle: 30deg), fill: col))
#let circ(r) = mp-path("(" + n(r) + ",0)..(0," + n(r) + ")..(" + n(-r) + ",0)..(0," + n(-r) + ")..cycle")
#align(center, mp-fig(
  ..ring(24, 118, 20, 0, teal, 3.2pt),
  ..ring(16, 92, 26, 11.25, ink, 3.6pt),
  ..ring(12, 62, 24, 0, brick, 3.4pt),
  ..ring(8, 34, 15, 22.5, gold, 3pt),
  draw(circ(124), pen: broadnib(4pt, t: 0.7pt, angle: 30deg), fill: gold),
  draw(circ(131), pen: broadnib(2.4pt, t: 0.5pt, angle: 30deg), fill: gold),
  mp-dot((0pt, 0pt), pen: pencircle(7pt), fill: brick),
  pad: 6pt))

== #T[2. Scroll: stems and curls placed with `point-of` and `direction-angle`][2. Rinceau : tiges et volutes placées avec `point-of` et `direction-angle`]
#let stem-pts = range(0, 25).map(i => (i * 19, 26 * calc.sin(i * 0.55)))
#let stem = mp-path(spec-of(stem-pts))
#let scroll(at-t, side, R, turns) = {
  let pos = point-of(stem, at-t)
  let a = direction-angle(stem, at-t)
  let na = a + side * 90deg
  let c = (pos.at(0).pt() + R * calc.cos(na), pos.at(1).pt() + R * calc.sin(na))
  let th0 = na + 180deg
  let m = 20
  let pts = range(m + 1).map(i => {
    let f = i / m
    let rho = R * calc.pow(1 - f, 0.9) + 0.8
    let th = th0.rad() - side * f * turns * 2 * calc.pi
    (c.at(0) + rho * calc.cos(th), c.at(1) + rho * calc.sin(th))
  })
  let p = mp-path(spec-of(pts))
  (draw(p, pens: range(m + 1).map(i => (8pt * calc.pow(1 - i / m, 0.8) + 1.2pt, 1.3pt, 40deg)), fill: ink),
   mp-dot((pts.at(m).at(0) * 1pt, pts.at(m).at(1) * 1pt), pen: pencircle(7pt), fill: gold))
}
#let leaf(at-t, side, len) = {
  let pos = point-of(stem, at-t); let a = direction-angle(stem, at-t)
  let q = (pos.at(0).pt(), pos.at(1).pt())
  let al = (a + side * 50deg)
  let d = al.deg()
  let tip = (q.at(0) + len * calc.cos(al), q.at(1) + len * calc.sin(al))
  let s = side
  let spec = "(" + n(q.at(0)) + "," + n(q.at(1)) + "){dir " + n(d + s * 38) + "}..{dir " + n(d - s * 38) + "}(" + n(tip.at(0)) + "," + n(tip.at(1)) + "){dir " + n(d + s * 38 + 180) + "}..{dir " + n(d - s * 38 + 180) + "}cycle"
  let lf = mp-path(spec)
  (mp-fill(lf, fill: teal), draw(lf, pen: broadnib(1.6pt, t: 0.4pt, angle: 40deg), fill: ink),
   draw(mp-path("(" + n(q.at(0)) + "," + n(q.at(1)) + ")--(" + n(tip.at(0) - 6 * calc.cos(al)) + "," + n(tip.at(1) - 6 * calc.sin(al)) + ")"), pen: pencircle(0.7pt), fill: ink))
}
#align(center, mp-fig(
  draw(stem, pens: range(25).map(i => (2.4pt + 2.4pt * calc.sin(i / 24 * calc.pi), 1.3pt, 40deg)), fill: ink),
  ..range(0, 6).map(k => scroll(2 + k * 4, if calc.even(k) { 1 } else { -1 }, 36, 0.92)).flatten(),
  ..range(0, 6).map(k => leaf(4 + k * 4, if calc.even(k) { -1 } else { 1 }, 46)).flatten(),
  ..range(0, 5).map(k => leaf(3.2 + k * 4, if calc.even(k) { 1 } else { -1 }, 30)).flatten(),
  pad: 8pt))

#pagebreak()
== #T[3. Lissajous curves, polar rosettes and hypotrochoids (sampled curves, then smoothed by Hobby)][3. Lissajous, rosaces polaires et hypotrochoïdes (courbes échantillonnées puis lissées par Hobby)]
#let curve-pts(f, m) = range(m).map(i => f(i / m))
#let lissa = curve-pts(t => (72 * calc.sin(3 * t * 2 * calc.pi + 0.6), 72 * calc.sin(2 * t * 2 * calc.pi)), 72)
#let rose5 = curve-pts(t => polar(72 * calc.cos(5 * t * 2 * calc.pi), t * 2 * calc.pi), 120)
#let hypo = curve-pts(t => { let a = t * 2 * calc.pi * 5; (14 * (5 - 1) * calc.cos(a) + 32 * calc.cos(4 * a), 14 * (5 - 1) * calc.sin(a) - 32 * calc.sin(4 * a)) }, 100)
#let card(pts, col, nib) = mp-fig(width: 160pt, height: 160pt, origin: (80pt, 80pt), draw(mp-path(spec-of(pts, cycle: true)), pen: nib, fill: col), frame: 0.4pt + rgb("#c9b99a"))
#grid(columns: 3, gutter: 6pt,
  card(lissa, ink, broadnib(6pt, t: 0.8pt, angle: 45deg)),
  card(rose5, brick, broadnib(7pt, t: 0.9pt, angle: 20deg)),
  card(hypo, teal, broadnib(6pt, t: 0.8pt, angle: 70deg)),
)

== #T[4. Golden spiral with growing pressure (variable pen: width and slant change along the path)][4. Spirale dorée à pression croissante (plume variable : largeur et inclinaison évoluent le long du chemin)]
#let sp-n = 46
#let sp-pts = range(sp-n + 1).map(i => { let th = i / sp-n * 4.3 * calc.pi; polar(3 * calc.pow(1.36, th), th + 0.3) })
#let sp = mp-path(spec-of(sp-pts))
#align(center, mp-fig(
  draw(sp, pens: range(sp-n + 1).map(i => (1.2pt + 14pt * calc.pow(i / sp-n, 1.6), 1.1pt, 35deg)), fill: gradient.linear(brick, gold, teal, angle: 30deg)),
  pad: 8pt))

#pagebreak()
== #T[5. Hand-drawn chart: axes, curves, intersections computed by `intersection-times`][5. Graphique manuscrit : axes, courbes, intersections calculées par `intersection-times`]
#let xs = range(0, 97).map(i => i * 3.2)
#let sinp = mp-path(spec-of(xs.map(x => (x, 70 * calc.sin(x / 50)))))
#let cosp = mp-path(spec-of(xs.map(x => (x, 70 * calc.cos(x / 50)))))
#let axis-x = mp-path("(-12,0)--(318,0)")
#let axis-y = mp-path("(0,-92)--(0,96)")
#let hits = intersection-times(sinp, cosp)
#let arrow(tip, a) = mp-fill(mp-path(spec-of((tip, (tip.at(0) - 9 * calc.cos(a - 0.35), tip.at(1) - 9 * calc.sin(a - 0.35)), (tip.at(0) - 9 * calc.cos(a + 0.35), tip.at(1) - 9 * calc.sin(a + 0.35))), cycle: true).replace("..", "--")), fill: ink)
#align(center, mp-fig(
  ..range(1, 5).map(k => draw(mp-path("(" + n(k * 50 * calc.pi / 2) + ",-4)--(" + n(k * 50 * calc.pi / 2) + ",4)"), pen: pencircle(1.1pt), fill: ink)),
  draw(axis-x, pen: broadnib(2.2pt, t: 0.5pt, angle: 45deg), fill: ink), draw(axis-y, pen: broadnib(2.2pt, t: 0.5pt, angle: 45deg), fill: ink),
  arrow((318, 0), 0), arrow((0, 96), calc.pi / 2),
  draw(sinp, pen: broadnib(4pt, t: 0.8pt, angle: 50deg), fill: brick),
  draw(cosp, pen: broadnib(4pt, t: 0.8pt, angle: 50deg), fill: teal),
  ..hits.map(h => { let pp = point-of(sinp, h.at(0)); mp-dot(pp, pen: pencircle(6pt), fill: gold) }),
  mp-label($sin x$, (160pt, 82pt), align: left + bottom),
  mp-label(text(fill: teal)[$cos x$], (255pt, 82pt), align: left + bottom),
  mp-label(text(size: 8pt)[#hits.len() intersections en $x = pi/4 + k pi$], (40pt, -100pt), align: left + horizon),
  origin: (20pt, 110pt), width: 345pt, height: 215pt, frame: 0.4pt + rgb("#c9b99a"), grid: 25pt))

== #T[6. Text laid on a path (`arctime` + `direction-angle`), with a pen ribbon underneath][6. Texte posé sur un chemin (`arctime` + `direction-angle`), avec un ruban à la plume dessous]
#let ribbon = mp-path("(0,0){dir 40}..(90,45)..(190,-5)..(290,40)..(380,5){dir -30}")
#let phrase = T("A pen glides along the Hobby curve", "Le temps d'une plume glisse sur la courbe de Hobby")
#let size = 11pt
#let adv = 0.602 * size
#let glyphs = phrase.clusters().enumerate().map(((i, ch)) => {
  let t = arctime(ribbon, (i + 0.5) * adv)
  let pos = point-of(ribbon, t)
  let a = direction-angle(ribbon, t)
  let off = 13pt
  mp-label(rotate(-a, text(font: "DejaVu Sans Mono", size: size, fill: ink, ch)), (pos.at(0) - off * calc.sin(a), pos.at(1) + off * calc.cos(a)), align: center + horizon)
})
#align(center, mp-fig(
  draw(ribbon, pens: range(5).map(i => (4pt + i * 0.6pt, 1pt, 35deg)), fill: gold),
  ..glyphs, pad: 14pt))

== #T[7. Cursive writing: arcades with variable pressure (full downstrokes, hairline upstrokes)][7. Écriture cursive : arcades à pression variable (descentes pleines, montées déliées)]
#let sm = 140
#let cyc = range(sm + 1).map(i => { let t = i / sm * 7.5 * calc.pi; (11 * t - 14 * calc.sin(t) , 44 - 44 * calc.cos(t + 0.35 * calc.sin(t))) })
#let cpath = mp-path(spec-of(cyc))
#let press = range(sm + 1).map(i => {
  let j = calc.min(i + 1, sm); let k = calc.max(i - 1, 0)
  let dy = cyc.at(j).at(1) - cyc.at(k).at(1)
  let down = calc.max(0, -dy) / 4.5
  (1pt + 5.2pt * calc.pow(calc.min(1, down), 0.8), 1pt, 48deg)
})
#let under = mp-path("(-10,-30){dir 6}..(120,-40)..(260,-34){dir 8}")
#align(center, mp-fig(
  draw(cpath, pens: press, fill: ink, tol: 0.02pt),
  draw(under, pens: ((0.8pt, 0.6pt, 48deg), (3.5pt, 1pt, 48deg), (0.8pt, 0.6pt, 48deg)), fill: brick),
  pad: 10pt))
