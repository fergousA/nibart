#import "../lib.typ": *
#let lang = sys.inputs.at("lang", default: "fr")
#let T(en, fr) = if lang == "fr" { fr } else { en }
#let bg = rgb("#0c1222")
#set page(paper: "a4", margin: (x: 14mm, y: 14mm), fill: bg)
#set text(font: "DejaVu Sans", size: 9pt, fill: rgb("#e8dcc0"))
#show heading.where(level: 2): it => block(above: 14pt, below: 6pt, text(size: 11pt, weight: "bold", fill: rgb("#f0b860"), it.body))

#let n(x) = str(calc.round(x, digits: 3))
#let spec-of(pts, cycle: false, join: "..") = pts.map(p => "(" + n(p.at(0)) + "," + n(p.at(1)) + ")").join(join) + if cycle { join + "cycle" } else { "" }
#let polar(r, a) = (r * calc.cos(a), r * calc.sin(a))
#let mixc(a, b, t) = color.mix((a, (1 - t) * 100%), (b, t * 100%))

#align(center)[
  #text(size: 22pt, weight: "bold", fill: rgb("#f0b860"))[nibart — #T[a cabinet of curiosities][cabinet de curiosités]]\
  #text(size: 9pt)[#T[interlaces · twisted ribbons · Hilbert · Lorenz · tree rings · razor-pen star][entrelacs · rubans torsadés · Hilbert · Lorenz · cernes · étoile à plume rasoir]]
]

== #T[1. Interlaced knots: crossings found by `intersection-times`, over/under alternated automatically][1. Nœuds à entrelacs : croisements trouvés par `intersection-times`, dessus/dessous alternés automatiquement]
#let crossings(p, m) = {
  let nn = path-length(p)
  let k = nn / m
  let pcs = range(m).map(i => subpath(p, i * k, (i + 1) * k))
  let found = ()
  for i in range(m) {
    for j in range(i + 1, m) {
      let adjacent = (j == i + 1) or (i == 0 and j == m - 1)
      for h in intersection-times(pcs.at(i), pcs.at(j)) {
        let (ta, tb) = h
        if adjacent {
          if j == i + 1 and ta > k - 0.06 and tb < 0.06 { continue }
          if i == 0 and j == m - 1 and ta < 0.06 and tb > k - 0.06 { continue }
        }
        found.push((i * k + ta, j * k + tb))
      }
    }
  }
  let out = ()
  for f in found {
    let pos = point-of(p, f.at(0))
    let dup = out.any(o => {
      let q = point-of(p, o.at(0))
      calc.sqrt(calc.pow((pos.at(0) - q.at(0)).pt(), 2) + calc.pow((pos.at(1) - q.at(1)).pt(), 2)) < 1.5
    })
    if not dup { out.push(f) }
  }
  out
}
#let knot(p, m, wide, col, hi) = {
  let cr = crossings(p, m)
  let ev = ()
  for (ci, f) in cr.enumerate() { ev.push((f.at(0), ci)); ev.push((f.at(1), ci)) }
  ev = ev.sorted(key: e => e.at(0))
  let over = (:)
  for (idx, e) in ev.enumerate() {
    if calc.even(idx) and not (str(e.at(1)) in over) { over.insert(str(e.at(1)), e.at(0)) }
  }
  for (ci, f) in cr.enumerate() { if not (str(ci) in over) { over.insert(str(ci), f.at(0)) } }
  let nn = path-length(p)
  let L = arclength(p).pt()
  let d1 = (wide.pt() * 1.15) * nn / L
  let d2 = d1 + (wide.pt() * 0.45) * nn / L
  let d3 = d2 + (wide.pt() * 0.7) * nn / L
  let items = (
    draw(p, pen: pencircle(wide * 1.3), fill: bg),
    draw(p, pen: pencircle(wide), fill: col),
    draw(p, pen: pencircle(wide * 0.22), fill: hi),
  )
  for (ci, _) in cr.enumerate() {
    let t = over.at(str(ci))
    items.push(draw(subpath(p, t - d1, t + d1), pen: pencircle(wide * 1.3), fill: bg))
    items.push(draw(subpath(p, t - d2, t + d2), pen: pencircle(wide), fill: col))
    items.push(draw(subpath(p, t - d3, t + d3), pen: pencircle(wide * 0.22), fill: hi))
  }
  items
}
#let tre = range(0, 120).map(i => { let t = i / 120 * 2 * calc.pi; (34 * (calc.sin(t) + 2 * calc.sin(2 * t)), 34 * (calc.cos(t) - 2 * calc.cos(2 * t))) })
#let cinq = range(0, 160).map(i => { let t = i / 160 * 4 * calc.pi; polar(40 * (3 + calc.cos(2.5 * t)) * 0.75, t) })
#let tre-p = mp-path(spec-of(tre, cycle: true))
#let cinq-p = mp-path(spec-of(cinq, cycle: true))
#scale(84%, reflow: true, grid(columns: 2, gutter: 4pt,
  align(center, mp-fig(..knot(tre-p, 6, 17pt, rgb("#d99a2b"), rgb("#ffe6a8")), pad: 10pt)),
  align(center, mp-fig(..knot(cinq-p, 8, 11pt, rgb("#2fb5a8"), rgb("#c9fff4")), pad: 10pt))))

#let cap(body) = align(center, text(size: 8pt, style: "italic", fill: rgb("#a8a08a"), body))

// ═══════════════════════════════════════════════ 2. rubans torsadés
== #T[2. Twisted ribbons: a pen whose width is |cos φ| (a ribbon seen in perspective)][2. Rubans torsadés : une plume dont la largeur vaut |cos φ| (un ruban vu en perspective)]
#let deg-delta(a, b) = { // plus petit écart (b − a) modulo 180°
  let d = calc.rem(b - a, 180)
  if d > 90 { d - 180 } else if d < -90 { d + 180 } else { d }
}
#let ribbon(pts, turns, W, c1, c2) = {
  let p = mp-path(spec-of(pts, cycle: true))
  let n = pts.len()
  let ang = ()
  for i in range(n) {
    let a = direction-angle(p, i).deg() + 90
    if i > 0 { a = ang.last() + deg-delta(ang.last(), a) }
    ang.push(a)
  }
  let cs = range(n + 1).map(i => calc.cos(turns * 2 * calc.pi * i / n))
  let wd(c) = W * calc.abs(c) + 0.5
  let dark = rgb("#10182c")
  let piece(i) = {
    let j = calc.rem(i + 1, n)
    let a0 = ang.at(i)
    let a1 = a0 + deg-delta(a0, ang.at(j))
    let e = 0.05
    let sp = subpath(p, i - e, i + 1 + e)
    let cm = (cs.at(i) + cs.at(i + 1)) / 2
    let base = if cm > 0 { c1 } else { c2 }
    let col = mixc(dark, base, 0.40 + 0.60 * calc.abs(cm))
    // 3 segments → 4 plumes
    let pn = (
      (wd(cs.at(i)), 0.6, a0),
      (wd(cs.at(i)), 0.6, a0),
      (wd(cs.at(i + 1)), 0.6, a1),
      (wd(cs.at(i + 1)), 0.6, a1),
    )
    (front: cm > 0, item: draw(sp, pens: pn, fill: col))
  }
  let ps = range(n).map(piece)
  ps.filter(q => not q.front).map(q => q.item) + ps.filter(q => q.front).map(q => q.item)
}
#let resample(f, n, dense: 1500) = { // points équidistants (abscisse curviligne) d'une courbe fermée t ∈ [0, 2π)
  let d = range(dense + 1).map(i => f(i / dense * 2 * calc.pi))
  let cum = (0.0,)
  for i in range(1, dense + 1) {
    let (x0, y0) = d.at(i - 1)
    let (x1, y1) = d.at(i)
    cum.push(cum.last() + calc.sqrt(calc.pow(x1 - x0, 2) + calc.pow(y1 - y0, 2)))
  }
  let tot = cum.last()
  let j = 0
  let out = ()
  for k in range(n) {
    let tg = k * tot / n
    while cum.at(j + 1) < tg { j += 1 }
    let u = (tg - cum.at(j)) / (cum.at(j + 1) - cum.at(j))
    out.push((d.at(j).at(0) * (1 - u) + d.at(j + 1).at(0) * u, d.at(j).at(1) * (1 - u) + d.at(j + 1).at(1) * u))
  }
  out
}
#let lem-f(t) = { let d = 1 + calc.pow(calc.sin(t), 2); (200 * calc.cos(t) / d, 200 * calc.sin(t) * calc.cos(t) / d) }
#let tre-f(t) = (34 * (calc.sin(t) + 2 * calc.sin(2 * t)), 34 * (calc.cos(t) - 2 * calc.cos(2 * t)))
#let cinq-f(t) = polar(0.8 * 30 * (3 + calc.cos(2.5 * 2 * t)), 2 * t)
#let lem = resample(lem-f, 260)
#align(center, mp-fig(..ribbon(lem, 3, 27, rgb("#f0b860"), rgb("#2fb5a8")), pad: 8pt))
#cap[#T[Bernoulli lemniscate, 260 equidistant nodes, 3 twists: gold = front, turquoise = back; the pen becomes thin when the ribbon is edge-on][lemniscate de Bernoulli, 260 nœuds équidistants, 3 tours de torsion : or = face, turquoise = revers ; la plume devient fine quand le ruban est de chant]]
#grid(columns: (1fr, 1fr), gutter: 4pt,
  align(center, mp-fig(..ribbon(resample(tre-f, 240).map(q => (q.at(0) * 0.62, q.at(1) * 0.62)), 5, 10.5, rgb("#e0706a"), rgb("#8f7be0")), pad: 8pt)),
  align(center, mp-fig(..ribbon(resample(cinq-f, 300).map(q => (q.at(0) * 0.68, q.at(1) * 0.68)), 9, 8, rgb("#9ad96a"), rgb("#2f8fb5")), pad: 8pt)))
#cap[#T[the same process on the trefoil (5 twists) and on the 5-point star (9 twists)][le même procédé sur le trèfle (5 tours) et sur l'étoile à 5 pointes (9 tours)]]

#pagebreak()

// ═══════════════════════════════════════════════ 3-4. Hilbert & Lorenz
== #T[3. Hilbert curve (order 4), smoothed by Hobby, drawn with a broad nib at 45°][3. Courbe de Hilbert (ordre 4), lissée par Hobby, tracée à la plume large à 45°]
#let d2xy(order, d) = {
  let x = 0
  let y = 0
  let t = d
  let s = 1
  while s < calc.pow(2, order) {
    let rx = calc.rem(calc.quo(t, 2), 2)
    let ry = calc.rem(t + rx, 2)
    if ry == 0 {
      if rx == 1 { x = s - 1 - x; y = s - 1 - y }
      (x, y) = (y, x)
    }
    x += s * rx
    y += s * ry
    t = calc.quo(t, 4)
    s *= 2
  }
  (x, y)
}
#let hil = range(256).map(d => { let (x, y) = d2xy(4, d); (x * 20, y * 20) })
#let hp = mp-path(spec-of(hil))
#let hpieces = 8
#let hseg = 255 / hpieces
#let hcol(t) = if t < 0.5 { mixc(rgb("#2fb5a8"), rgb("#f0b860"), t * 2) } else { mixc(rgb("#f0b860"), rgb("#e0706a"), (t - 0.5) * 2) }
#align(center, mp-fig(
  ..range(hpieces).map(k => draw(subpath(hp, k * hseg, (k + 1) * hseg + 0.05), pen: broadnib(12pt, t: 1.3pt, angle: 45deg), fill: hcol((k + 0.5) / hpieces))),
  pad: 6pt))
#cap[#T[256 nodes, a single nib at 45°: the uprights are thick or thin depending on their orientation, as in chancery calligraphy][256 nœuds, une seule plume à 45° : les montants sont épais ou fins selon leur orientation, comme en calligraphie chancelière]]

== #T[4. Lorenz attractor (σ=10, ρ=28, β=8/3), integrated in Typst, then drawn as a calligraphic thread][4. Attracteur de Lorenz (σ=10, ρ=28, β=8/3), intégré dans Typst puis tracé comme un fil calligraphié]
#let lor = {
  let (x, y, z) = (1.0, 1.0, 1.0)
  let dt = 0.005
  let out = ()
  for k in range(7000) {
    let dx = 10 * (y - x)
    let dy = x * (28 - z) - y
    let dz = x * y - 8 / 3 * z
    x += dx * dt
    y += dy * dt
    z += dz * dt
    if k > 200 and calc.rem(k, 14) == 0 { out.push((x * 9, z * 7.4 - 185)) }
  }
  out
}
#let lp = mp-path(spec-of(lor))
#let lpieces = 7
#let lseg = (lor.len() - 1) / lpieces
#align(center, mp-fig(
  ..range(lpieces).map(k => draw(subpath(lp, k * lseg, (k + 1) * lseg + 0.05), pen: broadnib(3.4pt, t: 0.45pt, angle: 35deg), fill: mixc(rgb("#8f7be0"), rgb("#f0b860"), k / (lpieces - 1)))),
  pad: 6pt))
#cap[#T[#lor.len() points (one point every 14 Euler steps), (x, z) projection, 7 graded sections][#lor.len() points (un point tous les 14 pas d'Euler), projection (x, z), 7 tronçons dégradés]]

#pagebreak()

// ═══════════════════════════════════════════════ 5-6. cernes & étoile
== #T[5. Tree rings: 14 closed rings, sinusoidal noise, variable-width pen][5. Cernes d'un tronc : 14 anneaux fermés, bruit sinusoïdal, plume à largeur variable]
#let ringcol(k, K) = mixc(rgb("#4a2a14"), rgb("#e6c592"), k / K)
#let rings = {
  let K = 14
  let out = ()
  for k in range(K) {
    let pts = range(60).map(i => {
      let a = i / 60 * 2 * calc.pi
      let r = 0.85 * (14 + 11.5 * k)
      r = r * (1 + 0.045 * calc.sin(3 * a + 0.9 * k) + 0.03 * calc.sin(5 * a + 1.7 * k) + 0.015 * calc.sin(9 * a + 0.3 * k * k))
      (r * calc.cos(a) + 0.8 * k, r * calc.sin(a) + 0.4 * k)
    })
    let p = mp-path(spec-of(pts, cycle: true))
    let wd(i) = 1.1 + 2.3 * (1 + calc.sin(2 * calc.pi * i / 60 * 2 + 1.3 * k)) / 2
    out.push(draw(p, pens: i => (wd(i), 0.5 + 0.3 * wd(i) / 3.4, 30 + 20 * calc.sin(i / 60 * 2 * calc.pi * 3)), fill: ringcol(K - 1 - k, K)))
  }
  out
}
#let star-pts(n, step, R, rot: 0) = range(n).map(i => polar(R, rot + 2 * calc.pi * calc.rem(i * step, n) / n))
#align(center, mp-fig(..rings.rev(), pad: 6pt))
#cap[#T[each ring: 60 nodes, modulated pen width (2 to 3.4 pt), oscillating pen angle; the brown gradient runs from heart to bark][chaque anneau : 60 nœuds, largeur de plume modulée (2 à 3,4 pt), angle de plume oscillant ; le dégradé de bruns va du cœur à l'écorce]]

== #T[6. Stars {19/8}, {19/7}, {19/5} with a razor pen: the trace is wide or zero depending on the stroke angle][6. Étoiles {19/8}, {19/7}, {19/5} à la plume rasoir : la trace est large ou nulle selon l'angle du trait]
#let razor = penrazor(11pt, angle: 45deg)
#let s1 = mp-path(spec-of(star-pts(19, 8, 140), cycle: true, join: "--"))
#let s2 = mp-path(spec-of(star-pts(19, 7, 140, rot: calc.pi / 19), cycle: true, join: "--"))
#let s3 = mp-path(spec-of(star-pts(19, 5, 140, rot: 2 * calc.pi / 19), cycle: true, join: "--"))
#align(center, mp-fig(
  draw(s1, pen: razor, fill: rgb("#f0b860").transparentize(35%)),
  draw(s2, pen: razor, fill: rgb("#2fb5a8").transparentize(35%)),
  draw(s3, pen: razor, fill: rgb("#e0706a").transparentize(35%)),
  pad: 10pt))
#cap[#T[three star polygons, a single 11 pt blade at 45°: a stroke parallel to the blade leaves almost nothing, a perpendicular stroke leaves 11 pt][trois polygones étoilés, une seule lame de 11 pt à 45° : un trait parallèle à la lame ne laisse presque rien, un trait perpendiculaire laisse 11 pt]]
