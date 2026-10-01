// nibart — the "art" layer: knots, calligraphic braces, pointed pen, path surgery.
//   typst compile --root . examples/nibart.typ                  (français)
//   typst compile --root . --input lang=en examples/nibart.typ  (English)
#import "../lib.typ" as nib

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }

#set page(paper: "a4", margin: (x: 14mm, y: 10mm), fill: rgb("#fbf7ee"))
#show regex("`[^`]+`"): it => text(font: "DejaVu Sans Mono", size: 0.92em, fill: rgb("#7a3b12"), it.text.slice(1, -1))
#set text(font: "DejaVu Sans", size: 8.4pt, fill: rgb("#2b2118"), lang: lang)
#show heading.where(level: 2): it => block(above: 12pt, below: 4pt, text(size: 10.5pt, weight: "bold", fill: rgb("#7a3b12"), it.body))
#let note(body) = text(size: 7.4pt, fill: rgb("#6b5a48"), body)

#let ink = rgb("#1d2a44")
#let gold = rgb("#b07a1c")
#let teal = rgb("#1c7a78")
#let brick = rgb("#9a3324")
#let sky = rgb("#2f628c")
#let leaf = rgb("#4d7b47")
#let P(pts, cycle: false) = nib.mp-path-pts(pts.map(p => (p.at(0) * 1pt, p.at(1) * 1pt)), cycle: cycle)
#let card(title, ..items, h: auto) = block(width: 100%, stroke: 0.4pt + rgb("#c9b99a"), radius: 3pt, inset: 6pt, {
  align(center, nib.mp-fig(..items, pad: 3pt))
  v(-1pt)
  align(center, note(title))
})

#align(center)[
  #text(size: 21pt, weight: "bold", fill: rgb("#7a3b12"))[nibart]\
  #note[#T("Nœuds et entrelacs · accolades calligraphiques · plume pointue · chirurgie de chemins — tout repose sur le même moteur de Hobby.", "Knots and interlace · calligraphic braces · pointed pen · path surgery — all on the same Hobby engine.")]
]

// ─────────────────────────────────────────────────────────
== #T("1. Nœuds, entrelacs, tresses : `knot(...)`", "1. Knots, links, braids: `knot(...)`")

#let lissa(a, b, ph, n: 48, sx: 26, sy: 26) = P(range(n).map(i => { let t = i / n * 360deg; (sx * calc.sin(a * t + ph), sy * calc.sin(b * t)) }), cycle: true)
#let trefoil = P(range(30).map(i => { let t = i / 30 * 360deg; (9.5 * (calc.sin(t) + 2 * calc.sin(2 * t)), 9.5 * (calc.cos(t) - 2 * calc.cos(2 * t))) }), cycle: true)
#let fig8 = P(range(32).map(i => { let t = i / 32 * 360deg; let d = 1 + calc.pow(calc.sin(t), 2); (34 * calc.cos(t) / d, 34 * calc.sin(t) * calc.cos(t) / d * 1.5) }), cycle: true)
#let circ(cx, cy, r) = P(range(8).map(i => (cx + r * calc.cos(i * 45deg), cy + r * calc.sin(i * 45deg))), cycle: true)
#let olymp = (circ(0, 0, 14), circ(32, 0, 14), circ(64, 0, 14), circ(16, -14, 14), circ(48, -14, 14))
#let bor = range(3).map(i => nib.rotated(P(range(12).map(k => (20 * calc.cos(k * 30deg) + 11, 10.8 * calc.sin(k * 30deg))), cycle: true), i * 120deg))
#let braid = range(3).map(i => P(range(0, 13).map(k => (k * 7, 11 * calc.sin(k * 60deg + i * 120deg)))))
#let celtic = lissa(3, 4, 0deg, n: 72, sx: 30, sy: 26)

#grid(columns: (1fr, 1fr, 1fr), gutter: 6pt,
  card(T("trèfle — style « weave » (entrelac celtique)", "trefoil — “weave” style (Celtic interlace)"),
    ..nib.knot(trefoil, style: "weave", width: 5pt, fill: sky, outline: 0.9pt, outline-fill: ink)),
  card(T("huit — style « gap » (diagramme de nœud)", "figure-eight — “gap” style (knot diagram)"),
    ..nib.knot(fig8, style: "gap", width: 2.2pt, fill: brick, gap: 1.6pt)),
  card(T("anneaux olympiques : le dessus/dessous alterne tout seul", "Olympic rings: over/under alternates by itself"),
    ..nib.knot(olymp, width: 3pt, fill: (sky, ink, brick, gold, leaf), outline: 0.5pt, outline-fill: luma(25), gap: 1pt)),
  card(T("anneaux borroméens (6 croisements)", "Borromean rings (6 crossings)"),
    ..nib.knot(bor, style: "weave", width: 3.2pt, fill: (brick, sky, leaf), outline: 0.6pt, outline-fill: ink)),
  card(T("tresse à trois brins", "three-strand braid"),
    ..nib.knot(braid, style: "weave", width: 5.5pt, fill: (brick, sky, leaf), outline: 0.8pt, outline-fill: ink)),
  card(T("Lissajous 3:4 tissé — un motif celtique", "woven Lissajous 3:4 — a Celtic pattern"),
    ..nib.knot(celtic, style: "weave", width: 4.2pt, fill: gold, outline: 0.8pt, outline-fill: ink)),
)
#grid(columns: (2.2fr, 1fr), gutter: 8pt, align: horizon,
  note[#T("Les croisements (y compris ceux d'un brin avec lui-même) sont trouvés automatiquement et numérotés ; le dessus/dessous est alterné sur tous les brins. `flips: (2, 5)` inverse des croisements, `rule: \"first\"` impose un ordre fixe, `draft: true` affiche les numéros (à droite).", "Crossings (including a strand with itself) are found automatically and numbered; over/under alternates along every strand. `flips: (2, 5)` inverts crossings, `rule: \"first\"` forces a fixed order, `draft: true` prints the numbers (right).")],
  align(center, nib.mp-fig(..nib.knot(trefoil, width: 2pt, fill: ink, gap: 1.3pt, draft: true), pad: 2pt)))

// ─────────────────────────────────────────────────────────
== #T("2. Accolades et parenthèses calligraphiques : `delimiter(...)`", "2. Calligraphic braces and parentheses: `delimiter(...)`")
#let word(x, s, col: ink) = nib.mp-label(text(size: 13pt, fill: col, s), (x * 1pt, 0pt))
#let dl(a, b, kind, amp, flip: false, fill: brick) = nib.delimiter((a.at(0) * 1pt, a.at(1) * 1pt), (b.at(0) * 1pt, b.at(1) * 1pt), kind: kind, amplitude: amp * 1pt, flip: flip, fill: fill, heavy: 2.6pt)
#grid(columns: (1.3fr, 1fr, 1fr), gutter: 6pt,
  card(T("sur deux points quelconques, des deux côtés", "between any two points, on either side"),
    word(0, $a$), word(24, $+$), word(48, $b$), word(72, $+$), word(96, $c$),
    dl((-8, -12), (104, -12), "brace", 8), dl((104, 14), (-8, 14), "brace", 8, fill: sky)),
  card(T("parenthèse courbe et droite", "curved and straight parenthesis"),
    dl((0, 0), (0, 44), "paren", 6), dl((26, 0), (26, 44), "paren-straight", 6, fill: sky), dl((52, 44), (52, 0), "paren-straight", 6, fill: leaf)),
  card(T("accolade oblique", "slanted brace"),
    nib.mp-label(text(size: 10pt, fill: ink)[#T("oblique", "slanted")], (9pt, 34pt)),
    dl((0, 0), (44, 44), "brace", 7), dl((56, 0), (56, 44), "paren", 7, fill: teal)),
)

// ─────────────────────────────────────────────────────────
== #T("3. Plume pointue : `copperplate(...)` — fin en montée, plein en descente", "3. Pointed pen: `copperplate(...)` — hairline up, shade down")
#let loops = P((
  (0, 0), (10, 22), (22, 38), (30, 20), (20, 0), (14, 14), (30, 26), (50, 8), (62, 22), (76, 38), (84, 20), (74, 0), (68, 14), (84, 26), (104, 8),
))
#let spiral = P(range(0, 26).map(i => { let t = i * 0.42; (1.8 * t * calc.cos(t * 1rad) * 1.9, 1.8 * t * calc.sin(t * 1rad) * 1.9) }))
#let swash = nib.mp-path("(0,0){dir 70}..(14,44){left}..(2,52)..(-6,40)..(6,24){dir -30}..(40,14)..(76,26){dir 60}..(96,44)")
#grid(columns: (1fr, 1fr, 1fr), gutter: 6pt,
  card(T("boucles, penchées à 70°", "loops, slanted at 70°"), ..nib.copperplate(loops, light: 0.5pt, heavy: 3.2pt, slant: 70deg, sharpness: 1.4, fill: ink)),
  card(T("spirale", "spiral"), ..nib.copperplate(spiral, light: 0.5pt, heavy: 3pt, taper: "both", taper-length: 14pt, fill: brick)),
  card(T("empattement en volute", "swash"), ..nib.copperplate(swash, light: 0.5pt, heavy: 3.4pt, slant: 80deg, taper-length: 10pt, fill: teal)),
)

// ─────────────────────────────────────────────────────────
== #T("4. Chirurgie de chemins", "4. Path surgery")
#let house = ((0, 0), (60, 0), (60, 34), (30, 56), (0, 34))
#let blob = P(((0, 0), (22, 10), (46, 2), (56, 26), (30, 46), (6, 34)), cycle: true)
#let wave = nib.mp-path("(0,0)..(20,26)..(40,0)..(60,26)..(80,0)")
#let circle = circ(30, 30, 26)
#grid(columns: (1fr, 1fr, 1fr), gutter: 6pt,
  card(T("`round-corners` : rayons différents par sommet", "`round-corners`: a different radius per corner"),
    ..nib.stroke-items(nib.round-corners(house.map(q => (q.at(0) * 1pt, q.at(1) * 1pt)), r: (2pt, 10pt, 18pt, 8pt, 2pt), cycle: true), pen: nib.pencircle(2pt), fill: ink)),
  card(T("`offset` : parallèles à gauche (+) et à droite (−)", "`offset`: parallels to the left (+) and right (−)"),
    ..range(-2, 4).map(k => nib.stroke-items(nib.offset(blob, k * 4pt), pen: nib.pencircle(0.7pt), fill: if k == 0 { brick } else if k > 0 { sky } else { leaf })).flatten()),
  card(T("`prongs` : plume à trois dents", "`prongs`: three-tined nib"),
    ..nib.prongs(wave, (-4pt, 0pt, 4pt), width: 1.1pt, fill: ink), ..nib.prongs(nib.shifted(wave, 0pt, -24pt), (-3pt, 3pt), width: 1.6pt, fill: brick)),
  card(T("`frames-along` + `in-frame` : pointes de flèche le long d'un cercle", "`frames-along` + `in-frame`: arrowheads around a circle"),
    ..nib.stroke-items(circle, pen: nib.pencircle(0.9pt), fill: ink),
    ..nib.frames-along(circle, count: 10).map(f => nib.mp-fill(nib.in-frame(nib.polyline(((-3pt, -3pt), (3pt, 0pt), (-3pt, 3pt)), cycle: true), f), fill: brick))),
  card(T("`gap-at`, `shorten` : interrompre et raccourcir", "`gap-at`, `shorten`: interrupt and shorten"),
    ..nib.gap-at(wave, (1.0, 2.0, 3.0), 4pt).map(q => nib.stroke-items(q, pen: nib.pencircle(2pt), fill: sky)).flatten(),
    ..nib.stroke-items(nib.shorten(nib.shifted(wave, 0pt, -22pt), start: 10pt, end: 10pt), pen: nib.pencircle(2pt), fill: gold)),
  card(T("`join-smooth` : raccord tangent entre deux tracés", "`join-smooth`: tangent-continuous join of two paths"),
    ..{
      let a = nib.mp-path("(0,0)..(14,24){right}")
      let b = nib.mp-path("(60,4){dir -60}..(76,-14)..(92,0)")
      nib.stroke-items(nib.join-smooth(a, b), pen: nib.pencircle(2pt), fill: ink)
    }),
)
