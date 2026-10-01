// nibart — figures 1 to 8 of the « insolite » example, shared by examples/insolite.typ and the manual cover.
//   figures(lang) -> (knots, score, neon, embroidery, enso, tree, sphere, guilloche), each a block of width 100%.
#import "../lib.typ" as nib

#let note(body) = text(size: 7.8pt, fill: rgb("#6b5a48"), body)

#let ink = rgb("#1d2a44")
#let gold = rgb("#b07a1c")
#let teal = rgb("#1c7a78")
#let brick = rgb("#9a3324")
#let polar(r, a) = (r * calc.cos(a), r * calc.sin(a))
#let P(pts, cycle: false) = nib.mp-path-pts(pts.map(p => (p.at(0) * 1pt, p.at(1) * 1pt)), cycle: cycle)
#let rnd(seed) = calc.rem(seed * 1664525 + 1013904223, 4294967296)
#let rnd01(seed) = rnd(rnd(rnd(seed + 977))) / 4294967296   // three rounds: small consecutive seeds must not give correlated values
#let card(..items, w: 100%, h: auto, bg: none, pad: 8pt) = block(width: w, fill: bg, stroke: 0.4pt + rgb("#c9b99a"), radius: 3pt, inset: pad, align(center, nib.mp-fig(..items, pad: 2pt)))

#let figures(lang, neon-sc: 1.45) = {
  let T(fr, en) = if lang == "en" { en } else { fr }
  let knot(f, n, tmax, scale, col) = {
    let pts = range(n).map(i => { let t = i / n * tmax; let (x, y) = f(t); (x * scale, y * scale) })
    let p = P(pts, cycle: true)
    let L = nib.path-length(p)
    // the closed path is cut in `k` pieces; crossings between non-adjacent pieces give pairs of times along the path
    let k = 18
    let pieces = range(k).map(i => nib.subpath(p, i * L / k, (i + 1) * L / k))
    let times = ()
    let seen = ()
    for i in range(k) { for j in range(i + 2, k) {
      if i == 0 and j == k - 1 { continue }
      for (ta, tb) in nib.intersection-times(pieces.at(i), pieces.at(j)) {
        let q = nib.point-of(pieces.at(i), ta)
        let key = str(calc.round(q.at(0).pt() / 1.5)) + "," + str(calc.round(q.at(1).pt() / 1.5))
        if key not in seen { seen.push(key); times.push((i * L / k + ta, j * L / k + tb)) }
      }
    } }
    // alternating rule: sort the 2×crossings times along the curve, every other one is an "over" pass
    let all = times.map(((a, b)) => (a, b)).flatten().sorted()
    let over = all.enumerate().filter(((i, _)) => calc.even(i)).map(((_, t)) => t)
    let band(q, w1, w2) = (nib.draw(q, pen: nib.pencircle(w1), fill: ink), nib.draw(q, pen: nib.pencircle(w2), fill: col))
    // an "over" pass: outline first, then a slightly longer core that hides the outline's end caps
    let pass(t, d) = (nib.draw(nib.subpath(p, t - d, t + d), pen: nib.pencircle(9pt), fill: ink), nib.draw(nib.subpath(p, t - d - 1.7, t + d + 1.7), pen: nib.pencircle(5.4pt), fill: col))
    (..band(p, 9pt, 5.4pt), ..over.map(t => pass(t, 2.0)).flatten(), (count: times.len()))
  }
  let tref(t) = { let r = 2 + calc.cos(3 * t / 2); (r * calc.cos(t), r * calc.sin(t)) }
  let cinq(t) = { let r = 2 + calc.cos(5 * t / 2); (r * calc.cos(t), r * calc.sin(t)) }
  let tor34(t) = { let r = 2 + calc.cos(4 * t / 3); (r * calc.cos(t), r * calc.sin(t)) }
  let knot-card(f, tmax, sc, col) = {
    let items = knot(f, 150, tmax, sc, col)
    let cnt = items.last().count
    (nib.mp-fig(..items.slice(0, items.len() - 1), pad: 4pt), cnt)
  }
  let ks = (
    knot-card(tref, 4 * calc.pi, 22, gold),
    knot-card(cinq, 4 * calc.pi, 22, teal),
    knot-card(tor34, 6 * calc.pi, 22, brick),
  )
  let fig-knots = grid(columns: (1fr, 1fr, 1fr), gutter: 6pt,
    ..ks.enumerate().map(((i, (fg, c))) => block(width: 100%, stroke: 0.4pt + rgb("#c9b99a"), radius: 3pt, inset: 6pt, align(center, stack(fg, v(3pt), note[#c #T("croisements", "crossings")])))))

  // ───────────────────────────────────────────────────────────── 2. partition
  let fig-score = {
    let sp = 8          // staff space
    let X1 = 488
    let (line-pen, stem-pen) = (nib.pencircle(0.7pt), nib.penrazor(1.1pt))
    let staff = range(5).map(i => nib.draw(nib.straight((0pt, i * sp * 1pt), (X1 * 1pt, i * sp * 1pt)), pen: line-pen, fill: ink))
    let bar(x, w) = nib.draw(nib.straight((x * 1pt, 0pt), (x * 1pt, 32pt)), pen: nib.penrazor(w), fill: ink)
    let y-of(step) = step * sp / 2
    // (x, step, kind) kind: "e" eighth, "q" quarter, "h" half
    let notes = ((88, 1, "e"), (116, 3, "e"), (152, 5, "q"), (188, 4, "e"), (216, 6, "e"), (252, 8, "q"), (288, 7, "e"), (316, 5, "e"), (352, 3, "q"), (388, 2, "e"), (416, 0, "e"), (452, 1, "h"))
    let head-pen = nib.penellipse(9.6pt, 6.6pt, angle: 22deg)
    let heads = notes.map(((x, s, k)) => {
      let y = y-of(s)
      let led = if s <= -2 { () } else { () }
      (nib.mp-dot((x * 1pt, y * 1pt), pen: head-pen, fill: ink),
       ..if k == "h" { (nib.mp-dot((x * 1pt, y * 1pt), pen: nib.penellipse(7.4pt, 2.6pt, angle: 38deg), fill: rgb("#fbf7ee")),) } else { () })
    }).flatten()
    let up(s) = s <= 3
    let stem-end(n) = { let (x, s, k) = n; if up(s) { (x + 4.3, y-of(s) + 28) } else { (x - 4.3, y-of(s) - 28) } }
    let stems = notes.map(n => {
      let (x, s, k) = n
      let a = if up(s) { (x + 4.3, y-of(s) + 1) } else { (x - 4.3, y-of(s) - 1) }
      let b = stem-end(n)
      nib.draw(nib.straight((a.at(0) * 1pt, a.at(1) * 1pt), (b.at(0) * 1pt, b.at(1) * 1pt)), pen: nib.penrazor(1.1pt), fill: ink)
    })
    let beam(i, j) = {
      let a = stem-end(notes.at(i)); let b = stem-end(notes.at(j))
      nib.draw(nib.straight((a.at(0) * 1pt, a.at(1) * 1pt), (b.at(0) * 1pt, b.at(1) * 1pt)), pen: nib.penrazor(4.2pt, angle: 90deg), fill: ink)
    }
    let beams = (beam(0, 1), beam(3, 4), beam(6, 7), beam(9, 10))
    // tapered slur: a circular pen whose diameter swells in the middle
    let slur(a, b, h) = {
      let (x0, y0) = a; let (x1, y1) = b
      let p = P((a, ((x0 + x1) / 2, (y0 + y1) / 2 + h), b))
      nib.stroke-items(p, pen: nib.nibpen((at: 0%, width: 0.5pt, thinness: 100%), (at: 50%, width: 3.4pt, thinness: 100%), (at: 100%, width: 0.5pt, thinness: 100%)), fill: ink, refine: 6)
    }
    let slurs = (slur((88, -6), (216, -6), -14), slur((186, 38), (316, 38), 15), slur((352, -6), (452, -6), -13)).flatten()
    // clef: one stroke, thick-thin with a broad nib
    let clef-p = nib.mp-path("(6,-4){dir -60}..(14,-12)..(21,-4){up}..(12,14){up}..(9,30){up}..(15,43)..(20,35)..(11,25)..(1,14)..(9,3)..(21,10)..(15,19)..(6,13)")
    let clef = nib.stroke-items(clef-p, pen: nib.nibpen((at: 0%, width: 2pt), (at: 45%, width: 4.4pt), (at: 100%, width: 1.6pt), thinness: 100%), fill: ink, refine: 4)
    let clef-stem = nib.draw(nib.mp-path("(12,-8)--(12,44)"), pen: nib.pencircle(1.3pt), fill: ink)
    let clef-dot = nib.mp-dot((12pt, 2.5pt), pen: nib.pencircle(3pt), fill: ink)
    // hairpin crescendo and dynamics
    let hp = (nib.draw(nib.straight((188pt, -40pt), (282pt, -35pt)), pen: nib.pencircle(0.9pt), fill: ink), nib.draw(nib.straight((188pt, -40pt), (282pt, -45pt)), pen: nib.pencircle(0.9pt), fill: ink))
    let dyn(body, x) = nib.mp-label(text(font: "DejaVu Serif", style: "italic", weight: "bold", size: 12pt, fill: ink, body), (x * 1pt, -40pt))
    let ts = nib.mp-label(text(font: "DejaVu Serif", weight: "bold", size: 15pt, fill: ink)[#stack(spacing: -3pt, [4], [4])], (56pt, 16pt))
    block(width: 100%, stroke: 0.4pt + rgb("#c9b99a"), radius: 3pt, inset: 8pt, align(center,
      nib.mp-fig(..staff, bar(0, 1.1pt), bar(X1 - 5, 1.1pt), bar(X1, 4pt), ..clef, clef-stem, ..heads, ..stems, ..beams, ..slurs, ..hp, dyn([p], 100), dyn([f], 304), ts,
        origin: (6pt, 52pt), width: 505pt, height: 118pt)))
  }

  // ───────────────────────────────────────────────────────────── 3. néon · 4. broderie
  let neon = {
    let pink = rgb("#ff4fa3"); let cyan = rgb("#4fe6ff")
    let sc = neon-sc
    let f = sc / 1.45          // tube widths follow the scale
    // n i b a r t  (x-height 42, ascender 80, letters 28–32 units apart)
    let letters = ("(0,0)--(0,42)", "(0,30)..(14,43)..(28,30)--(28,0)",
      "(58,0)--(58,42)", "(90,0)--(90,80)", "(90,28)..(106,43)..(122,22)..(106,1)..(90,12)",
      "(182,0)--(182,42)", "(182,28)..(166,43)..(150,22)..(166,1)..(182,12)",
      "(212,0)--(212,42)", "(212,26)..(222,40)..(238,43)",
      "(264,66)--(264,12)..(270,1)..(284,2)", "(250,42)--(280,42)").map(spec => nib.scaled(nib.mp-path(spec), sc))
    let dot = nib.scaled(nib.mp-path("(58,62)--(58,62.01)"), sc)
    let strokes = letters + (dot,)
    let W = 284 * sc
    let frame = nib.polyline(((-30pt * f - 4pt, -38pt * f), (W * 1pt + 30pt * f + 4pt, -38pt * f), (W * 1pt + 30pt * f + 4pt, 80pt * sc + 38pt * f), (-30pt * f - 4pt, 80pt * sc + 38pt * f)), cycle: true)
    let tube(p, col) = (
      ..range(9).map(i => nib.draw(p, pen: nib.pencircle((30 - i * 2.6) * f * 1pt), fill: col.transparentize(94% - i * 2%))),
      nib.draw(p, pen: nib.pencircle(6pt * f), fill: col.lighten(10%)),
      nib.draw(p, pen: nib.pencircle(2.2pt * f), fill: white.mix((col, 30%))),
    )
    let wave = nib.mp-path("(0,-12)..(14,-7)..(30,-16)..(46,-8)..(62,-16)..(78,-8)..(94,-16)..(110,-8)..(126,-14)..(150,-10)")
    let wave = nib.shifted(nib.xscaled(wave, W / 150 * 0.93), 0.04 * W * 1pt, -8pt * f - 4pt * sc)
    block(width: auto, fill: rgb("#14121f"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(
      // unlit tubes behind
      ..strokes.map(q => nib.draw(q, pen: nib.pencircle(6pt * f), fill: rgb("#2a2838"))),
      ..tube(frame, cyan).rev(),
      ..strokes.map(q => tube(q, pink)).flatten(),
      ..tube(wave, cyan),
      pad: 4pt)))
  }
  let embroidery = {
    let thread = (rgb("#c4314b"), rgb("#d7485f"))
    let R = 100
    let CY = 26
    let weave = (
      ..range(-10, 11).map(i => nib.mp-skeleton(nib.straight((i * 10pt, -R * 1pt), (i * 10pt, R * 1pt)), stroke: 0.3pt + rgb("#cbbd9f"))),
      ..range(-10, 11).map(i => nib.mp-skeleton(nib.straight((-R * 1pt, i * 10pt), (R * 1pt, i * 10pt)), stroke: 0.3pt + rgb("#cbbd9f"))))
    let hoop = P(range(48).map(i => polar(R + 3, i / 48 * 2 * calc.pi)), cycle: true)
    let satin(a0, a1, r0, r1, n, col, w: 2.6pt) = range(n + 1).map(i => {
      let f = i / n
      let a = a0 + (a1 - a0) * f
      let bulge = 1 + 0.25 * calc.sin(f * calc.pi)
      let (x0, y0) = polar(r0, a); let (x1, y1) = polar(r1 * bulge * (0.72 + 0.28 * calc.sin(f * calc.pi)), a)
      y0 += CY; y1 += CY
      nib.draw(nib.straight((x0 * 1pt, y0 * 1pt), (x1 * 1pt, y1 * 1pt)), pen: nib.penellipse(w, w * 0.6, angle: a * 1rad), fill: col.lighten(if calc.even(i) { 0% } else { 14% }))
    })
    // petals: 8 lens-shaped satin areas (offset by half a pitch so that the stem leaves between two petals)
    let np = 8
    let pitch = 2 * calc.pi / np
    let petals = range(np).map(k => { let a = (k + 0.5) * pitch; satin(a - 0.33, a + 0.33, 13, 56, 13, thread.at(calc.rem(k, 2))) }).flatten()
    // stem with running stitches (nib follows the tangent)
    let stem = nib.mp-path("(6,-66)..(-6,-86)..(8,-100)..(-2,-112)")
    let stem-items = nib.stroke-items(nib.shifted(nib.mp-path("(0,-2)..(9,-28)..(-5,-52)..(0,-84)"), 0pt, 0pt), pen: nib.nibpen(width: 4.5pt, thinness: 45%, angle: 0deg, follow: true), fill: rgb("#2f7d4a"), dash: nib.dashes(4pt, 5pt, jitter: 0.9pt, seed: 4))
    // leaves: satin strokes across a lens
    let leaf(cx, cy, dir, len, col) = range(0, 13).map(i => {
      let f = i / 12
      let w = len * 0.34 * calc.sin(f * calc.pi)
      let base = (cx + len * (f - 0.5) * calc.cos(dir), cy + len * (f - 0.5) * calc.sin(dir))
      let a = (base.at(0) - w * calc.sin(dir), base.at(1) + w * calc.cos(dir))
      let b = (base.at(0) + w * calc.sin(dir), base.at(1) - w * calc.cos(dir))
      nib.draw(nib.straight((a.at(0) * 1pt, a.at(1) * 1pt), (b.at(0) * 1pt, b.at(1) * 1pt)), pen: nib.penellipse(2.6pt, 1.6pt, angle: (dir + 90deg.rad()) * 1rad), fill: col.lighten(if calc.even(i) { 0% } else { 12% }))
    })
    let leaves = leaf(-22, -50, 0.35, 40, rgb("#2f7d4a")) + leaf(18, -66, 2.75, 38, rgb("#3f9a5a"))
    let knots = range(9).map(i => { let a = i * 2.4; let r = 3.5 * calc.sqrt(i); let (x, y) = polar(r, a); (nib.mp-dot((x * 1pt, (y + CY) * 1pt), pen: nib.pencircle(6.4pt), fill: rgb("#8a5a0c")), nib.mp-dot((x * 1pt, (y + CY) * 1pt), pen: nib.pencircle(4.4pt), fill: rgb("#e0a52c")), nib.mp-dot(((x - 0.9) * 1pt, (y + CY + 0.9) * 1pt), pen: nib.pencircle(1.4pt), fill: rgb("#ffe6a0"))) }).flatten()
    block(width: 100%, fill: rgb("#efe6d3"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(
      nib.mp-fill(hoop, fill: rgb("#f2e9d6")), ..weave,
      nib.draw(hoop, pen: nib.pencircle(8pt), fill: rgb("#9b6a3c")), nib.draw(hoop, pen: nib.pencircle(2.4pt), fill: rgb("#c99563")),
      ..stem-items, ..leaves, ..petals, ..knots, pad: 3pt)))
  }

  // ───────────────────────────────────────────────────────────── 5. enso · 6. arbre
  let enso = {
    let R0 = 50; let nb = 17
    let bristle(k) = {
      let off = (k - (nb - 1) / 2) * 1.75
      let r0 = R0 + off
      let a0 = 1.75; let sweep = 5.55
      let pts = range(57).map(i => { let f = i / 56; let a = a0 - f * sweep; let r = r0 + f * 9 + 1.2 * calc.sin(f * 9 + k); polar(r, a) })
      let w = 2.2 + 0.8 * rnd01(k * 31 + 7) - 0.4 * calc.abs(off) / 14
      nib.stroke-items(P(pts), pen: nib.nibpen((at: 0%, width: w * 1pt, thinness: 100%), (at: 55%, width: w * 0.85 * 1pt, thinness: 100%), (at: 100%, width: 0.3pt, thinness: 100%)),
        fill: ink.transparentize(int(rnd01(k * 17 + 3) * 22) * 1%), refine: 3,
        pressure: nib.pressure(minimum-width: 1.9pt, period: 2.4pt, seed: k * 13 + 5))
    }
    let seal = (nib.mp-dot((66pt, -58pt), pen: nib.pensquare(17pt, angle: 4deg), fill: brick),
      nib.draw(nib.mp-path("(61,-52)..(66,-56)..(71,-52)"), pen: nib.broadnib(2.4pt, t: 1.2pt, angle: 40deg), fill: rgb("#fbf7ee")),
      nib.draw(nib.mp-path("(61,-62)--(71,-62)"), pen: nib.broadnib(2.4pt, t: 1.2pt, angle: 40deg), fill: rgb("#fbf7ee")),
      nib.draw(nib.mp-path("(66,-54)--(66,-66)"), pen: nib.broadnib(2.4pt, t: 1.2pt, angle: 40deg), fill: rgb("#fbf7ee")))
    block(width: 100%, fill: rgb("#f4efe3"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(..range(nb).map(bristle).flatten(), ..seal, origin: (92pt, 88pt), width: 184pt, height: 176pt)))
  }
  let tree = {
    let bark = rgb("#4a3427")
    let pinks = (rgb("#f7b6c8"), rgb("#f29bb5"), rgb("#ffd3de"), rgb("#ec7fa0"))
    let grow(x, y, ang, len, w, depth, seed) = {
      let r1 = rnd01(seed); let r2 = rnd01(seed * 3 + 1); let r3 = rnd01(seed * 5 + 2)
      let bend = (r1 - 0.5) * 0.35
      let (x1, y1) = (x + len * calc.cos(ang + bend * 0.5), y + len * calc.sin(ang + bend * 0.5))
      let (mx, my) = ((x + x1) / 2 - bend * len * 0.35 * calc.sin(ang), (y + y1) / 2 + bend * len * 0.35 * calc.cos(ang))
      let br = (nib.draw(P(((x, y), (mx, my), (x1, y1))), pens: ((w, w, 0), (w * 0.88, w * 0.88, 0), (w * 0.76, w * 0.76, 0)), fill: bark, tol: 0.05pt),)
      let fl = ()
      if depth == 0 {
        for j in range(3) {
          let q = rnd01(seed * 11 + j * 7 + 4); let q2 = rnd01(seed * 13 + j * 5 + 9)
          fl.push(nib.mp-dot(((x1 + (q - 0.5) * 16) * 1pt, (y1 + (q2 - 0.5) * 16) * 1pt), pen: nib.pencircle((4 + q2 * 5) * 1pt), fill: pinks.at(int(q * 4) )))
        }
        return (br, fl)
      }
      let a1 = ang + 0.32 + r2 * 0.3; let a2 = ang - 0.32 - r3 * 0.3
      let (b1, f1) = grow(x1, y1, a1, len * (0.78 + r2 * 0.08), w * 0.68, depth - 1, seed * 2 + 1)
      let (b2, f2) = grow(x1, y1, a2, len * (0.78 + r3 * 0.08), w * 0.68, depth - 1, seed * 2 + 2)
      let extra = ((), ())
      if depth >= 3 and depth <= 5 and r1 > 0.55 { extra = grow(x1, y1, ang + (r2 - 0.5) * 0.3, len * 0.6, w * 0.6, depth - 2, seed * 7 + 3) }
      (br + b1 + b2 + extra.at(0), fl + f1 + f2 + extra.at(1))
    }
    let (br, fl) = grow(0, -108, 1.62, 30.5, 9, 8, 12)
    let ground = nib.draw(nib.mp-path("(-95,-112)..(-40,-108)..(0,-111)..(45,-108)..(98,-113)"), pens: ((0.5, 0.5, 0), (2.6, 2.6, 0), (3.2, 3.2, 0), (2.6, 2.6, 0), (0.5, 0.5, 0)), fill: ink)
    let moon = nib.mp-dot((72pt, 100pt), pen: nib.pencircle(26pt), fill: rgb("#f2e7c9"))
    block(width: 100%, fill: rgb("#e9eef0"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(moon, ground, ..br, ..fl, origin: (92pt, 120pt), width: 184pt, height: 176pt, clip: true)))
  }

  // ───────────────────────────────────────────────────────────── 7. sphère gravée · 8. guilloché
  let sphere = {
    let Rs = 88
    let tau = 0.42
    let L = (-0.55, 0.62, 0.56); let ln = calc.sqrt(L.map(v => v * v).sum()); L = L.map(v => v / ln)
    let view(phi, lam) = {
      let X = calc.cos(phi) * calc.sin(lam); let Y = calc.sin(phi); let Z = calc.cos(phi) * calc.cos(lam)
      let Y2 = Y * calc.cos(tau) - Z * calc.sin(tau); let Z2 = Y * calc.sin(tau) + Z * calc.cos(tau)
      (X, Y2, Z2)
    }
    let lines = ()
    for i in range(-28, 29) {
      let phi = i * 3 * calc.pi / 180
      let pts = (); let ws = ()
      for j in range(0, 241) {
        let lam = -calc.pi + j * calc.pi / 120
        let (X, Y2, Z2) = view(phi, lam)
        if Z2 > 0.02 {
          let I = calc.max(0, X * L.at(0) + Y2 * L.at(1) + Z2 * L.at(2))
          pts.push((Rs * X, Rs * Y2)); ws.push(0.12 + 2.5 * calc.pow(1 - I, 1.6))
        }
      }
      if pts.len() > 3 {
        lines.push(nib.draw(P(pts), pens: ws.map(w => (w, w, 0)), fill: ink, tol: 0.04pt))
      }
    }
    // cast shadow: horizontal hatching in a flattened ellipse
    let shadow = range(-9, 10).map(k => {
      let f = k / 9; let half = 92 * calc.sqrt(1 - f * f)
      let y = -Rs * 1.05 + f * 17
      let x0 = 30 - half * 0.6; let x1 = 30 + half * 0.6
      nib.draw(nib.mp-path-pts(((x0 * 1pt, y * 1pt), ((x0 + x1) / 2 * 1pt, (y + 0.4) * 1pt), (x1 * 1pt, y * 1pt))), pens: ((0.1, 0.1, 0), (1.3 - 0.8 * calc.abs(f), 1.3 - 0.8 * calc.abs(f), 0), (0.1, 0.1, 0)), fill: ink)
    })
    block(width: 100%, fill: rgb("#f1ead8"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(..shadow, ..lines, origin: (92pt, 100pt), width: 184pt, height: 200pt)))
  }
  let guilloche = {
    let hypo(Rg, rg, d, rot) = P(range(181).map(i => { let t = i / 180 * 2 * calc.pi
      let x = (Rg - rg) * calc.cos(t) + d * calc.cos((Rg - rg) / rg * t)
      let y = (Rg - rg) * calc.sin(t) - d * calc.sin((Rg - rg) / rg * t)
      polar(calc.sqrt(x * x + y * y), calc.atan2(x, y).rad() + rot) }), cycle: true)
    let col(f) = teal.mix((brick, f * 70%)).lighten(10%)
    let rosette = range(44).map(k => nib.draw(hypo(84, 12, 27, k * 2 * calc.pi / 7 * 0.5 / 44), pen: nib.pencircle(0.3pt), fill: col(k / 44)))
    let inner = range(30).map(k => nib.draw(hypo(45, 9, 12, k * 2 * calc.pi / 6 * 0.5 / 30), pen: nib.pencircle(0.3pt), fill: col(1 - k / 30)))
    let ring(r, amp, n, ph, c) = nib.draw(P(range(241).map(i => { let t = i / 240 * 2 * calc.pi; polar(r + amp * calc.sin(n * t + ph), t) }), cycle: true), pen: nib.pencircle(0.35pt), fill: c)
    let rings = (ring(88, 2.2, 48, 0, ink), ring(88, 2.2, 48, calc.pi, ink), ring(94, 1.5, 72, 0, gold), ring(94, 1.5, 72, calc.pi, gold), nib.draw(P(range(97).map(i => polar(99, i / 96 * 2 * calc.pi)), cycle: true), pen: nib.pencircle(1.1pt), fill: ink))
    let core = (nib.mp-dot((0pt, 0pt), pen: nib.pencircle(17pt), fill: rgb("#f6f0de")), ring(7.5, 0.8, 16, 0, ink), ring(5, 0.6, 12, 0, teal))
    block(width: 100%, fill: rgb("#f1ead8"), radius: 3pt, inset: 6pt, align(center, nib.mp-fig(..rosette, ..inner, ..rings, ..core, origin: (92pt, 100pt), width: 184pt, height: 200pt)))
  }
  (knots: fig-knots, score: fig-score, neon: neon, embroidery: embroidery, enso: enso, tree: tree, sphere: sphere, guilloche: guilloche)
}
