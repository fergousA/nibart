// nibart — « insolite » : des usages qu'on n'associe pas à une plume.
//   typst compile --root . examples/insolite.typ            (français)
//   typst compile --root . --input lang=en examples/insolite.typ   (English)
#import "../lib.typ" as nib
#import "insolite-figs.typ": figures, note, ink, gold, teal, brick, polar, P, rnd, rnd01, card

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }

#set page(paper: "a4", margin: (x: 14mm, y: 13mm), fill: rgb("#fbf7ee"))
#set text(font: "DejaVu Sans", size: 8.6pt, fill: rgb("#2b2118"), lang: lang)
#show heading.where(level: 2): it => block(above: 13pt, below: 4pt, text(size: 10.5pt, weight: "bold", fill: rgb("#7a3b12"), it.body))

#let F = figures(lang, neon-sc: 0.68)

#align(center)[
  #text(size: 21pt, weight: "bold", fill: rgb("#7a3b12"))[nibart — #T("l'insolite", "the unexpected")]\
  #note[#T("Une partition, des nœuds qui passent dessus/dessous, une enseigne au néon, une broderie, un arbre, un enso, une sphère gravée, un guilloché, une carte : tout est tracé avec des chemins de Hobby et des plumes.", "A score, knots that weave over and under, a neon sign, embroidery, a tree, an enso, an engraved sphere, guilloché, a map — all drawn with Hobby paths and pens.")]
]

== #T("1. Nœuds : le dessus/dessous est calculé avec intersection-times", "1. Knots: over/under is computed with intersection-times")
#F.knots

== #T("2. Partition : liaisons effilées, ligatures à plume « rasoir », têtes inclinées", "2. Score: tapered slurs, razor-pen beams, tilted note heads")
#F.score

== #T("3. Enseigne au néon (halos = traits translucides empilés)  ·  4. Broderie (points avant dashes + satin)", "3. Neon sign (halos = stacked translucent strokes)  ·  4. Embroidery (running stitch with dashes + satin)")
#grid(columns: (1fr, 1fr), gutter: 8pt, align: horizon, F.neon, F.embroidery)

#pagebreak()
== #T("5. Enso au pinceau sec (chaque poil = un trait dont la pression s'effondre)  ·  6. Cerisier fractal", "5. Dry-brush enso (every bristle is a stroke whose pressure collapses)  ·  6. Fractal cherry tree")
#grid(columns: (1fr, 1fr), gutter: 8pt, F.enso, F.tree)

== #T("7. Sphère gravée (l'épaisseur du trait suit la lumière : pens)  ·  8. Guilloché de billet", "7. Engraved sphere (line width follows the light: pens)  ·  8. Banknote guilloché")
#grid(columns: (1fr, 1fr), gutter: 8pt, F.sphere, F.guilloche)

#pagebreak()
// ───────────────────────────────────────────────────────────── 9. carte
== #T("9. Carte de l'île de Hobby : fleuve effilé, affluents qui se raccordent (point-of), frontière en tiret-point", "9. Map of Hobby Island: tapered river, tributaries joined with point-of, dash-dot border")
#let map-card = {
  let sea = rgb("#cfe0e2"); let land = rgb("#f3ead0"); let water = rgb("#3f7f9a")
  let coast = P(((-200, 10), (-185, 72), (-130, 100), (-88, 94), (-50, 118), (10, 110), (60, 94), (110, 108), (160, 82), (198, 30), (180, -20), (205, -55), (170, -95), (120, -88), (80, -105), (20, -98), (-30, -110), (-70, -92), (-120, -100), (-170, -70), (-195, -30)), cycle: true)
  // water-lining: progressively fainter halos around the coast
  let halos = range(4).map(i => nib.draw(coast, pen: nib.pencircle((34 - i * 8) * 1pt), fill: rgb("#e3eff0").transparentize(i * 10% + 0%))).rev()
  let river = P(((-120, 62), (-92, 38), (-55, 24), (-28, -8), (8, -28), (30, -62), (22, -99)))
  let taper(p, w0, w1) = nib.stroke-items(p, pen: nib.nibpen((at: 0%, width: w0 * 1pt, thinness: 100%), (at: 100%, width: w1 * 1pt, thinness: 100%)), fill: water, refine: 4)
  let join(t) = { let q = nib.point-of(river, t); (q.at(0).pt(), q.at(1).pt()) }
  let trib1 = P(((98, 66), (78, 34), (52, 2), join(4.3)))
  let trib2 = P(((-112, -52), (-84, -34), (-56, -40), join(3.0)))
  let trib3 = P(((-10, 70), (-30, 52), join(2.0)))
  let rivers = (..taper(river, 0.6, 7), ..taper(trib1, 0.5, 3), ..taper(trib2, 0.5, 2.6), ..taper(trib3, 0.4, 2.2))
  // mountains: chevrons with a shaded side
  let mts = range(26).map(i => {
    let x = -150 + rnd01(i * 7 + 1) * 96 - rnd01(i * 3) * 10; let y = 50 + rnd01(i * 5 + 2) * 40 - 0.25 * (x + 150)
    let h = 9 + rnd01(i * 11 + 4) * 7
    (nib.draw(nib.polyline(((x * 1pt - h * 0.8pt, y * 1pt), (x * 1pt, y * 1pt + h * 1pt), (x * 1pt + h * 0.8pt, y * 1pt))), pen: nib.broadnib(1.5pt, t: 0.6pt, angle: 30deg), fill: rgb("#6b4a2a")),
     nib.draw(nib.straight((x * 1pt + h * 0.1pt, y * 1pt + h * 0.8pt), (x * 1pt + h * 0.5pt, y * 1pt + h * 0.2pt)), pen: nib.pencircle(0.5pt), fill: rgb("#6b4a2a")))
  }).flatten()
  let border = P(((55, 103), (40, 52), (66, 2), (90, -40), (84, -97)))
  let borderline = nib.stroke-items(border, pen: nib.nibpen(width: 1.6pt, thinness: 100%), fill: brick, dash: nib.dashes(9pt, 3pt, 1.5pt, 3pt))
  let city(x, y, name, dx: 8, dy: 0, al: left + horizon) = (nib.mp-dot((x * 1pt, y * 1pt), pen: nib.pencircle(6.4pt), fill: ink), nib.mp-dot((x * 1pt, y * 1pt), pen: nib.pencircle(2.8pt), fill: white),
    nib.mp-label(text(font: "DejaVu Serif", style: "italic", size: 7.3pt, fill: ink, name), ((x + dx) * 1pt, (y + dy) * 1pt), align: al))
  let cities = (..city(-92, 38, "Hobbyburg", dx: -5, dy: -9, al: right + top), ..city(22, -98, "Port-Nib", dx: -8, al: right + horizon), ..city(98, 66, "Kurbo", dx: 8), ..city(-130, -40, "Plumeville", dx: -8, al: right + horizon), ..city(118, -55, "Bézier-sur-Mer"))
  // compass rose
  let cr = 26
  let star = (nib.mp-fill(nib.polyline(range(8).map(i => { let r = if calc.even(i) { cr } else { cr * 0.3 }; let (x, y) = polar(r, i * calc.pi / 4 + calc.pi / 2); ((x + 225) * 1pt, (y - 98) * 1pt) }).map(q => q), cycle: true), fill: ink),
    nib.draw(nib.polyline(range(4).map(i => { let (x, y) = polar(cr * 0.62, i * calc.pi / 2 + calc.pi / 4); ((x + 225) * 1pt, (y - 98) * 1pt) }), cycle: true), pen: nib.pencircle(0.6pt), fill: brick),
    nib.mp-label(text(font: "DejaVu Serif", weight: "bold", size: 8pt, fill: ink)[N], (225pt, -62pt), align: bottom))
  // waves
  let waves = range(22).map(i => {
    let x = -235 + rnd01(i * 13 + 2) * 470; let y = -128 + rnd01(i * 29 + 5) * 252
    // only in the sea: test roughly with the coast polygon using path bbox is enough; skip spots on land via distance to coast
    let (t, dist) = nib.closest-time(coast, (x * 1pt, y * 1pt))
    if dist < 24pt { return () }
    // inside test: ray towards -x counting crossings
    let ray = nib.straight((x * 1pt, y * 1pt), (-400pt, y * 1pt))
    if calc.rem(nib.intersection-times(ray, coast).len(), 2) == 1 { return () }
    (nib.draw(P(((x, y), (x + 5, y + 2.6), (x + 10, y), (x + 15, y + 2.6))), pen: nib.broadnib(1.2pt, t: 0.5pt, angle: 30deg), fill: water),)
  }).flatten()
  let title = (nib.draw(nib.polyline(((-235pt, 110pt), (-145pt, 110pt), (-145pt, 135pt), (-235pt, 135pt)), cycle: true), pen: nib.pencircle(1pt), fill: ink),
    nib.mp-label(text(font: "DejaVu Serif", weight: "bold", size: 8.4pt, fill: ink, align(center)[#T("ÎLE DE HOBBY", "HOBBY ISLAND")\ #text(size: 6pt, weight: "regular")[#T("1 cm = 40 lieues de plume", "1 cm = 40 pen-leagues")]]), (-190pt, 122.5pt)))
  block(width: 100%, fill: sea, radius: 3pt, inset: 4pt, clip: true, align(center, nib.mp-fig(..halos, nib.mp-fill(coast, fill: land), nib.draw(coast, pen: nib.broadnib(2.2pt, t: 0.9pt, angle: 35deg), fill: ink), ..mts, ..rivers, ..borderline, ..cities, ..waves, ..star, ..title, origin: (250pt, 135pt), width: 500pt, height: 272pt)))
}
#map-card

// ───────────────────────────────────────────────────────────── 10. relief · 11. croquis
== #T("10. Relief : courbes de niveau, l'épaisseur varie avec l'orientation (plume plate = hachure d'ombrage)  ·  11. Croquis à main levée", "10. Relief: contour lines, the nib's orientation shades the slopes  ·  11. Hand-drawn sketch")
#let relief = {
  let shape(k) = {
    let s = 4.9 * k
    let (cx, cy) = (-0.55 * k, 0.4 * k)
    P(range(97).map(i => { let th = i / 96 * 2 * calc.pi; let r = s * (1 + 0.26 * calc.sin(2 * th + 0.6) + 0.13 * calc.sin(3 * th + 1.9) + 0.06 * calc.sin(5 * th)); (cx + r * calc.cos(th), cy + r * calc.sin(th)) }), cycle: true)
  }
  let ks = range(1, 13).rev()
  let tint(k) = { let f = (12 - k) / 11; if f < 0.55 { rgb("#d3e2b0").mix((rgb("#e3d08c"), f / 0.55 * 100%)) } else { rgb("#e3d08c").mix((rgb("#b98d62"), (f - 0.55) / 0.45 * 100%)) } }
  let fills = ks.map(k => nib.mp-fill(shape(k), fill: tint(k)))
  let lines = ks.map(k => nib.draw(shape(k), pen: if calc.rem(k, 4) == 0 { nib.broadnib(2.6pt, t: 1pt, angle: 40deg) } else { nib.broadnib(1.5pt, t: 0.55pt, angle: 40deg) }, fill: rgb("#5a3b22")))
  let labels = (4, 8, 12).map(k => { let q = nib.point-of(shape(k), 12); (nib.mp-dot(q, pen: nib.penellipse(17pt, 8pt), fill: tint(k)), nib.mp-label(text(size: 6pt, fill: rgb("#5a3b22"))[#(k * 50)], q)) }).flatten()
  let peak = (nib.mp-dot((-6.6pt, 4.8pt), pen: nib.pensquare(4pt, angle: 45deg), fill: rgb("#5a3b22")),)
  block(width: 100%, fill: rgb("#e8f0d8"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(..fills, ..lines, ..labels, ..peak, origin: (92pt, 88pt), width: 184pt, height: 176pt, clip: true)))
}
#let sketch = {
  let ink2 = rgb("#2b2118")
  let pen = nib.broadnib(2pt, t: 1.3pt, angle: 35deg)
  let wob(pts, amp, seed, cycle: true, straight: false) = if straight { nib.polyline(pts.enumerate().map(((i, q)) => ((q.at(0) + (rnd01(seed + i * 5) - 0.5) * 2 * amp) * 1pt, (q.at(1) + (rnd01(seed + i * 5 + 1) - 0.5) * 2 * amp) * 1pt)), cycle: cycle) } else { P(pts.enumerate().map(((i, q)) => (q.at(0) + (rnd01(seed + i * 5) - 0.5) * 2 * amp, q.at(1) + (rnd01(seed + i * 5 + 1) - 0.5) * 2 * amp)), cycle: cycle) }
  let stroke(p) = nib.draw(p, pen: pen, fill: ink2)
  let rect-pts(cx, cy, w, h) = {
    let (x0, x1, y0, y1) = (cx - w / 2, cx + w / 2, cy - h / 2, cy + h / 2)
    ((x0, y0), (cx - w / 6, y0), (cx + w / 6, y0), (x1, y0), (x1, cy - h / 6), (x1, cy + h / 6), (x1, y1), (cx + w / 6, y1), (cx - w / 6, y1), (x0, y1), (x0, cy + h / 6), (x0, cy - h / 6))
  }
  let box(cx, cy, label, seed, col) = (nib.mp-fill(wob(rect-pts(cx, cy, 92, 34), 0.0, seed + 40, straight: true), fill: col), stroke(wob(rect-pts(cx, cy, 92, 34), 1.1, seed, straight: true)),
    nib.mp-label(text(font: "DejaVu Serif", style: "italic", size: 10pt, fill: ink2, label), (cx * 1pt, cy * 1pt)))
  let arrow(x, ya, yb, seed) = (stroke(wob(((x, ya), (x + 1, (ya + yb) / 2), (x, yb)), 1.4, seed, cycle: false)),
    stroke(P(((x - 6, yb + 7), (x - 2, yb + 2), (x, yb)))), stroke(P(((x + 6, yb + 7), (x + 2, yb + 2), (x, yb)))))
  let (fx, fy) = (-12, 10)
  let fp(pts) = pts.map(q => (q.at(0) + fx, q.at(1) + fy))
  let fig = (
    ..box(-32, 62, T("une idée", "an idea"), 11, rgb("#ffe9a8")), ..arrow(-32, 43, 26, 21),
    ..box(-32, 0, T("un chemin", "a path"), 31, rgb("#cfe6f2")), ..arrow(-32, -19, -36, 51),
    ..box(-32, -62, "PDF", 71, rgb("#d3ecc8")),
    // stick figure
    stroke(wob(range(10).map(i => polar(9, i / 10 * 2 * calc.pi)).map(q => (q.at(0) + 62 + fx, q.at(1) - 22 + fy)), 0.7, 91)),
    stroke(P(fp(((62, -31), (61, -48), (62, -64))), cycle: false)), stroke(P(fp(((62, -40), (52, -34), (46, -28))))), stroke(P(fp(((62, -40), (71, -47), (79, -48))))),
    stroke(P(fp(((62, -64), (55, -76), (52, -86))))), stroke(P(fp(((62, -64), (70, -76), (73, -86))))),
    nib.mp-dot(((59.2 + fx) * 1pt, (-22 + fy) * 1pt), pen: nib.pencircle(1.6pt), fill: ink2), nib.mp-dot(((65 + fx) * 1pt, (-22 + fy) * 1pt), pen: nib.pencircle(1.6pt), fill: ink2),
    stroke(P(fp(((58, -26), (62, -28), (66, -26))), cycle: false)),
    // speech bubble
    nib.mp-fill(wob(range(12).map(i => { let (x, y) = polar(1, i / 12 * 2 * calc.pi); (x * 40 + 50 + 0, y * 21 + 34) }), 0.8, 121), fill: white),
    stroke(wob(range(12).map(i => { let (x, y) = polar(1, i / 12 * 2 * calc.pi); (x * 40 + 50 + 0, y * 21 + 34) }), 1.2, 121)),
    stroke(P(fp(((52, 8), (57, -4), (62, -10))), cycle: false)),
    nib.mp-label(text(font: "DejaVu Serif", style: "italic", size: 8.6pt, fill: ink2, align(center, T("et ça\ncompile !", "and it\ncompiles!"))), (50pt, 34pt)))
  block(width: 100%, fill: rgb("#fdfcf7"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(..fig, origin: (92pt, 88pt), width: 184pt, height: 176pt, clip: true)))
}
#grid(columns: (1fr, 1fr), gutter: 8pt, relief, sketch)
