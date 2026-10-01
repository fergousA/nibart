// nib 0.2 — plumes « calligraphiques » : arrêts le long du chemin, follow, pointillés irréguliers, pression,
// empilement, contour, vue de construction, chemins en longueurs, et Hobby par-dessus.
#import "../lib.typ": *
#let lang = sys.inputs.at("lang", default: "fr")
#let T(en, fr) = if lang == "fr" { fr } else { en }

#let paper = rgb("#ece7dc")
#let ink = rgb("#292621")
#let red = rgb("#a83b32")
#let ochre = rgb("#b37a22")
#let blue = rgb("#366a91")
#let muted = rgb("#685f53")
#set page(paper: "a4", fill: paper, margin: (top: 22mm, bottom: 20mm, x: 32mm))
#set text(font: "Libertinus Serif", size: 10pt, fill: ink)
#show heading: set text(size: 17pt)

#let section(title, body) = {
  block(above: 6mm, below: 3mm, {
    text(size: 9pt, weight: "bold", fill: red, tracking: 0.6pt, upper(title))
    v(-1mm)
    nib-stroke(straight((0mm, 0mm), (12cm, 0mm)),
      pen: nibpen((at: 0%, width: 3.2pt, thinness: 28%, angle: 18deg), (at: 46%, width: 1.2pt, thinness: 25%, angle: 23deg), (at: 85%, width: 0.08pt, thinness: 35%, angle: 30deg)),
      pressure: pressure(minimum-width: 0.34pt, period: 3.1pt, seed: 27), fill: ochre, pad: 1pt)
  })
  body
}
#let cap(t) = text(size: 8pt, fill: muted, style: "italic", t)
#let cell(body, caption) = align(center, stack(dir: ttb, spacing: 2mm, box(height: 18mm, align(center + horizon, body)), cap(caption)))

// le même dessin que dans `nibst` (repère Typst, y vers le bas) grâce à `y-down: true`
#let wave = cubics((((0mm, 0mm), (8mm, -9mm), (26mm, 9mm), (34mm, 0mm)),), y-down: true)
#let loop = cubics((
  ((0mm, 0mm), (7mm, 10mm), (25mm, 10mm), (32mm, 0mm)),
  ((32mm, 0mm), (25mm, -7mm), (7mm, -7mm), (0mm, 0mm)),
), cycle: true, y-down: true)
#let taper(w0) = nibpen((at: 0%, width: w0, thinness: 28%, angle: 24deg), (at: 72%, width: 1.2pt, thinness: 25%, angle: 2deg), (at: 96%, width: 0.08pt, thinness: 35%, angle: 30deg))
#let long = cubics((((0mm, 0mm), (30mm, -5mm), (72mm, 5mm), (104mm, 0mm)),), y-down: true)

= #T[Calligraphic pens][Plumes calligraphiques]

#section(T("Pen angle", "Orientation de la plume"))[
  #grid(columns: (1fr,) * 4, gutter: 4mm, ..(0deg, 30deg, 60deg, 90deg).map(a =>
    cell(nib-stroke(straight((0mm, 0mm), (22mm, 0mm)), pen: nibpen(width: 3pt, thinness: 12%, angle: a), fill: ink), [#calc.round(a.deg())°])))
]

#section(T("A trail that breaks up into dots (pen with stops + pressure)", "Traînée qui se défait en pointillés (plume à arrêts + pression)"))[
  #align(center, box(height: 14mm, align(center + horizon,
    nib-stroke(long, pen: taper(24pt), pressure: pressure(minimum-width: 0.64pt, period: 3.1pt, seed: 27), tol: 0.015pt))))
]

#section(T("Irregular dashes", "Pointillés irréguliers"))[
  #align(center, box(height: 18mm, align(center + horizon,
    nib-stroke(long, pen: taper(14pt), dash: dashes(4mm, 5mm, jitter: 1.5mm, seed: 42), pressure: pressure(minimum-width: 0.64pt, period: 3.1pt, seed: 27)))))
]

#section(T("The pen on a curve", "La plume sur une courbe"))[
  #grid(columns: (1fr,) * 3, gutter: 5mm,
    cell(nib-stroke(wave, pen: nibpen(width: 8pt, thinness: 16%, angle: 25deg), fill: ink), [#T[fixed, 25°][fixe, 25°]]),
    cell(nib-stroke(wave, pen: nibpen(width: 4pt, thinness: 100%, angle: 0deg), fill: ink), [#T[round pen][plume ronde]]),
    cell(nib-stroke(wave, pen: nibpen(width: 8.4pt, thinness: 16%, angle: 25deg, follow: true), fill: ink), [#T[25° relative to the tangent][25° par rapport à la tangente]]))
]

#section(T("Construction view (debug)", "Vue de construction (debug)"))[
  #grid(columns: (1fr,) * 3, gutter: 5mm,
    cell(nib-stroke(wave, pen: nibpen(width: 8pt, thinness: 16%, angle: 25deg), fill: ink.transparentize(60%), debug: true), [#T[skeleton and pens][squelette et plumes]]),
    cell(nib-stroke(wave, pen: nibpen(width: 4pt, thinness: 100%), fill: ink.transparentize(60%), debug: true), [#T[circle][cercle]]),
    cell(nib-stroke(wave, pen: nibpen(width: 8.4pt, thinness: 16%, angle: 25deg, follow: true), fill: ink.transparentize(60%), debug: true), [#T[follows the tangent][suit la tangente]]))
]

#section(T("Rotating pen, closed path, layering", "Plume tournante, chemin fermé, empilement"))[
  #grid(columns: (1fr,) * 3, gutter: 6mm,
    cell(nib-stroke(straight((0mm, 0mm), (38mm, 0mm)), pen: nibpen((at: 0%, width: 8.4pt, thinness: 16%, angle: 0deg), (at: 100%, width: 8.4pt, thinness: 16%, angle: 360deg)), fill: ink.transparentize(75%), debug: true), [#T[360° along the stroke][360° le long du trait]]),
    cell(nib-stroke(loop, pen: nibpen(width: 8.2pt, thinness: 28%, angle: 45deg), fill: ink.transparentize(75%), debug: true), [#T[closed path][chemin fermé]]),
    cell(nib-stroke(loop, pen: nibpen(width: 8.2pt, thinness: 28%, angle: 45deg), overlap: "layered", layer: 2.5pt, fill: blue.transparentize(70%), outline: 0.4pt + blue), [#T[stacked (layered)][superposé (layered)]]))
]

// ── ce que nib ajoute : Hobby + plume à arrêts, en un seul geste
#let swash = mp-path("(0,0)..(28,55)..(70,150)..(62,205)..(26,192)..(30,135)..(68,62)..(118,8)..(175,-6)..(230,22)")
#let l-pen = nibpen(
  (at: 0%, width: 4pt, thinness: 60%, angle: 10deg),
  (at: 12%, width: 3pt, thinness: 15%, angle: 60deg),
  (at: 35%, width: 15pt, thinness: 20%, angle: 28deg),
  (at: 60%, width: 14pt, thinness: 18%, angle: 10deg),
  (at: 85%, width: 6pt, thinness: 20%, angle: 14deg),
  (at: 100%, width: 1pt, thinness: 40%, angle: 14deg))
#pagebreak()
#section(T("Hobby + pen with stops: a cursive “ℓ”", "Hobby + plume à arrêts : un « ℓ » cursif"))[
  #grid(columns: (1fr,) * 3, gutter: 2mm, align: bottom + center,
    scale(62%, reflow: true, nib-stroke(swash, pen: l-pen, fill: ink, pad: 4pt)),
    scale(62%, reflow: true, nib-stroke(swash, pen: l-pen, fill: gradient.linear(red, ochre, blue, angle: 90deg), pad: 4pt)),
    scale(62%, reflow: true, nib-stroke(swash, pen: l-pen, overlap: "layered", layer: 7pt, fill: red.transparentize(65%), outline: 0.8pt + red, pad: 4pt)),
    cap[union], cap[#T[gradient][dégradé]], cap[layered + contour])
]

#let spiral = mp-path(range(0, 41).map(i => { let t = i / 40 * 3.6 * calc.pi; let r = 5 + 5.6 * t; "(" + str(calc.round(r * calc.cos(t), digits: 2)) + "," + str(calc.round(r * calc.sin(t), digits: 2)) + ")" }).join(".."))
#let sp-pen = nibpen((at: 0%, width: 1pt, thinness: 40%, angle: 35deg), (at: 55%, width: 9pt, thinness: 22%, angle: 35deg), (at: 100%, width: 2pt, thinness: 40%, angle: 35deg), follow: true)
#section(T("Spiral: follow + irregular dashes + pressure", "Spirale : follow + pointillés irréguliers + pression"))[
  #grid(columns: (1fr,) * 3, gutter: 2mm, align: bottom + center,
    scale(80%, reflow: true, nib-stroke(spiral, pen: sp-pen, fill: blue, pad: 4pt)),
    scale(80%, reflow: true, nib-stroke(spiral, pen: sp-pen, dash: dashes(9mm, 2.5mm, jitter: 2mm, seed: 5), fill: red, pad: 4pt)),
    scale(80%, reflow: true, nib-stroke(spiral, pen: sp-pen, pressure: pressure(minimum-width: 2.6pt, period: 2.2pt, seed: 3), fill: ochre, pad: 4pt)),
    cap[#T[pen following the tangent][plume qui suit la tangente]], cap[#T[random dashes / gaps][trait / vide aléatoires]], cap[#T[pressure breaks the thin parts][la pression casse les parties fines]])
]
