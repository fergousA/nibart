// nibart — boîtes et diagrammes façon « templates de présentation » (cartes, processus, SWOT, pyramide, cycle…)
// Toutes les formes sont des chemins Hobby ; les contours sont tracés à la plume (plume large, pression variable).
#import "../lib.typ": *
#let lang = sys.inputs.at("lang", default: "fr")
#let T(en, fr) = if lang == "fr" { fr } else { en }

#let paper = rgb("#f7f3ea")
#let ink = rgb("#1d2b53")
#let c-coral = rgb("#e8604c")
#let c-amber = rgb("#f2a93b")
#let c-teal = rgb("#1fa59b")
#let c-blue = rgb("#3b6fd8")
#let c-violet = rgb("#7a54c6")
#let muted = rgb("#5d6680")

#set page(width: 960pt, height: 540pt, margin: 0pt, fill: paper)
#set text(font: "DejaVu Sans", size: 11pt, fill: ink)
#set par(leading: 0.55em, justify: false)

#let n(x) = str(calc.round(x, digits: 3))
#let P(x, y) = "(" + n(x) + "," + n(y) + ")"
#let polar(r, a) = (r * calc.cos(a), r * calc.sin(a))
#let mixc(a, b, t) = color.mix((a, (1 - t) * 100%), (b, t * 100%))
#let nibpen = broadnib(3.2pt, t: 1.1pt, angle: 35deg)
#let fine = broadnib(2.2pt, t: 0.8pt, angle: 35deg)

// rectangle arrondi (chemin fermé, côtés droits par directions {…})
#let rr(x, y, w, h, r) = (
  P(x + r, y), "{right}..{right}", P(x + w - r, y), "{right}..{up}", P(x + w, y + r), "{up}..{up}",
  P(x + w, y + h - r), "{up}..{left}", P(x + w - r, y + h), "{left}..{left}",
  P(x + r, y + h), "{left}..{down}", P(x, y + h - r), "{down}..{down}",
  P(x, y + r), "{down}..{right}", P(x + r, y), "{right}..cycle").join()

// ───────────────────────────────────────────────────────────── primitives
#let lab(body, x, y, al: center + horizon) = mp-label(body, (x * 1pt, y * 1pt), align: al)
#let tb(w, body, size: 10pt, fill: ink, al: center, weight: "regular") = block(width: w * 1pt, align(al, text(size: size, fill: fill, weight: weight, body)))
#let fillp(spec, col) = mp-fill(mp-path(spec), fill: col)
#let ol(spec, col: ink, pen: nibpen) = draw(mp-path(spec), pen: pen, fill: col)
#let poly(pts, cycle: true) = pts.map(q => P(q.at(0), q.at(1))).join("--") + if cycle { "--cycle" } else { "" }
#let circ(cx, cy, r) = P(cx + r, cy) + ".." + P(cx, cy + r) + ".." + P(cx - r, cy) + ".." + P(cx, cy - r) + "..cycle"
#let shadow(spec) = {
  let p = mp-path(spec)
  ((1.5, -2.0), (3.5, -4.5), (6.0, -8.0)).map(d => mp-fill(shifted(p, d.at(0) * 1pt, d.at(1) * 1pt), fill: luma(0).transparentize(93%)))
}
#let soft(c, t: 0.82) = mixc(c, white, t)
#let deep(c, t: 0.32) = mixc(c, ink, t)
#let slide-title(title, sub, col: c-coral) = (
  lab(text(size: 27pt, weight: "bold", title), 54, 492, al: left + horizon),
  draw(mp-path(P(54, 468) + ".." + P(140, 463) + ".." + P(250, 469) + ".." + P(360, 464)),
    pens: ((1.5, 0.7, 30), (6, 1.7, 30), (7, 1.9, 30), (1.5, 0.7, 30)), fill: col),
  lab(text(size: 11pt, fill: muted, sub), 54, 444, al: left + horizon),
)
#let arrow(x0, y0, x1, y1, col, w: 7) = {
  let (dx, dy) = (x1 - x0, y1 - y0)
  let l = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / l, dy / l)
  let (hl, hw) = (w * 2.3, w * 1.4)
  let (bx, by) = (x1 - ux * hl, y1 - uy * hl)
  (
    draw(mp-path(P(x0, y0) + ".." + P(bx, by)), pens: ((w * 0.3, w * 0.3, 0), (w, w, 0)), fill: col),
    fillp(poly(((x1, y1), (bx - uy * hw, by + ux * hw), (bx + uy * hw, by - ux * hw))), col),
  )
}
#let arc-arrow(cx, cy, r, a0, a1, col, w: 9) = {
  let ang(i) = (a0 + (a1 - 12 - a0) * i / 4) * calc.pi / 180
  let pts = range(5).map(i => polar(r, ang(i)))
  let path = mp-path(pts.map(q => P(cx + q.at(0), cy + q.at(1))).join(".."))
  let ea = (a1 - 12) * calc.pi / 180
  let tip = polar(r + 0, a1 * calc.pi / 180)
  let bc = polar(r, ea)
  let rad = (calc.cos(ea), calc.sin(ea))
  (
    draw(path, pens: range(5).map(i => (w * (0.35 + 0.65 * i / 4), w * (0.35 + 0.65 * i / 4), 0)), fill: col),
    fillp(poly(((cx + tip.at(0), cy + tip.at(1)), (cx + bc.at(0) + rad.at(0) * w * 1.35, cy + bc.at(1) + rad.at(1) * w * 1.35), (cx + bc.at(0) - rad.at(0) * w * 1.35, cy + bc.at(1) - rad.at(1) * w * 1.35))), col),
  )
}
#let card(x, y, w, h, r: 20, col: white) = {
  let s = rr(x, y, w, h, r)
  (..shadow(s), fillp(s, col), ol(s))
}
#let bub(x, y, w, h, r, tx) = (
  P(x + r, y), "{right}..{right}", P(tx - 24, y), "{1,-1.3}..", "{0.3,-1}", P(tx, y - 34), "{0.3,1}..",
  "{1,1.3}", P(tx + 18, y), "{right}..{right}", P(x + w - r, y), "{right}..{up}", P(x + w, y + r), "{up}..{up}",
  P(x + w, y + h - r), "{up}..{left}", P(x + w - r, y + h), "{left}..{left}",
  P(x + r, y + h), "{left}..{down}", P(x, y + h - r), "{down}..{down}",
  P(x, y + r), "{down}..{right}", P(x + r, y), "{right}..cycle").join()
#let FIG(..items) = mp-fig(..items, width: 960pt, height: 540pt)

// ═════════════════════════════════════════════════════ 1. trois cartes
#let step-card(x, col, num, title, body, icon) = {
    (
    card(x, 92, 250, 288, r: 24),
    fillp(rr(x + 40, 110, 170, 10, 5), soft(col, t: 0.6)),
    ..icon,
    fillp(circ(x + 125, 380, 33), col),
    draw(mp-path(circ(x + 125, 380, 33)), pen: nibpen, fill: ink),
    lab(text(size: 22pt, weight: "bold", fill: white, num), x + 125, 380),
    lab(text(size: 17pt, weight: "bold", fill: col, title), x + 125, 232),
    lab(tb(200, body, size: 10.5pt), x + 125, 212, al: center + top),
  )
}
#let ico-target(cx, cy, col) = (
  draw(mp-path(circ(cx, cy, 36)), pen: broadnib(5pt, t: 2pt, angle: 35deg), fill: col),
  draw(mp-path(circ(cx, cy, 21)), pen: broadnib(5pt, t: 2pt, angle: 35deg), fill: col),
  fillp(circ(cx, cy, 7), col),
  ..arrow(cx + 50, cy + 44, cx + 4, cy + 4, ink, w: 4.5),
)
#let ico-bars(cx, cy, col) = (
  ..range(4).map(i => {
    let hh = 20 + 15 * i
    let s = rr(cx - 40 + 21 * i, cy - 34, 15, hh, 4)
    (fillp(s, soft(col, t: 0.75 - 0.2 * i)), ol(s, col: col, pen: fine))
  }).flatten(),
  ..arrow(cx - 48, cy - 6, cx + 44, cy + 44, ink, w: 4.5),
)
#let ico-check(cx, cy, col) = (
  fillp(circ(cx, cy, 36), soft(col, t: 0.8)),
  draw(mp-path(circ(cx, cy, 36)), pen: broadnib(5pt, t: 2pt, angle: 35deg), fill: col),
  draw(mp-path(P(cx - 18, cy - 1) + "--" + P(cx - 6, cy - 15) + "--" + P(cx + 20, cy + 16)), pens: ((5, 4, 0), (12, 9, 0), (5, 4, 0)), fill: col),
)
#FIG(
  ..slide-title(T("Three steps to the result", "Trois étapes vers le résultat"), T("Calligraphic-outline cards: broad nib at 35°, soft shadow, numbered badges", "Cartes à contour calligraphié : plume large à 35°, ombre douce, pastilles numérotées")),
  step-card(60, c-coral, "1", T("Frame", "Cadrer"), T("Define the goal, the scope and the success indicators before starting.", "Définir l'objectif, le périmètre et les indicateurs de réussite avant de démarrer."), ico-target(185, 300, c-coral)),
  step-card(365, c-blue, "2", T("Build", "Construire"), T("Iterate in small steps, measure every result and adjust the course.", "Itérer par petites étapes, mesurer chaque résultat et ajuster la trajectoire."), ico-bars(490, 300, c-blue)),
  step-card(670, c-teal, "3", T("Deliver", "Livrer"), T("Validate with the users, document and hand everything over to the team.", "Valider avec les utilisateurs, documenter et transmettre le tout à l'équipe."), ico-check(795, 300, c-teal)),
  ..arrow(316, 215, 359, 215, c-amber, w: 8),
  ..arrow(621, 215, 664, 215, c-amber, w: 8),
)

// ═════════════════════════════════════════════════════ 2. processus & chronologie
#pagebreak()
#let chev(x, y, w, h, nt, col, first: false) = {
  let pts = if first {
    ((x, y), (x + w - nt, y), (x + w, y + h / 2), (x + w - nt, y + h), (x, y + h))
  } else {
    ((x, y), (x + w - nt, y), (x + w, y + h / 2), (x + w - nt, y + h), (x, y + h), (x + nt, y + h / 2))
  }
  let sp = poly(pts)
  (..shadow(sp), fillp(sp, col), ol(sp, col: deep(col), pen: fine))
}
#let proc = (
  ("01", T("Listen", "Écouter"), T("Gather needs and constraints.", "Recueillir les besoins et les contraintes."), c-coral),
  ("02", T("Analyse", "Analyser"), T("Prioritise and cost the options.", "Prioriser et chiffrer les options."), c-amber),
  ("03", T("Design", "Concevoir"), T("Draw the target solution.", "Dessiner la solution cible."), c-teal),
  ("04", T("Test", "Tester"), T("Validate on a real sample.", "Valider sur un échantillon réel."), c-blue),
  ("05", T("Deploy", "Déployer"), T("Roll out and train the teams.", "Généraliser et former les équipes."), c-violet),
)
#let miles = (
  (200, 170, "2022", T("Idea and first sketches", "Idée et premiers croquis"), c-coral),
  (340, 92, "2023", T("Working prototype", "Prototype fonctionnel"), c-amber),
  (480, 170, "2024", T("Pilot with 3 customers", "Pilote chez 3 clients"), c-teal),
  (620, 92, "2025", T("Public launch", "Lancement public"), c-blue),
  (760, 170, "2026", T("Scaling up", "Passage à l'échelle"), c-violet),
)
#FIG(
  ..slide-title(T("Five-step process and timeline", "Processus en cinq étapes et chronologie"), T("Chevrons with drop shadow; timeline drawn as a pen stroke of varying pressure", "Chevrons à ombre portée ; chronologie tracée comme un trait de plume à pression variable"), col: c-blue),
  ..proc.enumerate().map(((i, q)) => {
    let x = 50 + 172 * i
    (
      ..chev(x, 320, 188, 84, 34, q.at(3), first: i == 0),
      lab(text(size: 11pt, fill: white, weight: "bold", q.at(0)), x + 92 + 8 * calc.min(i, 1), 386),
      lab(text(size: 14pt, fill: white, weight: "bold", q.at(1)), x + 92 + 8 * calc.min(i, 1), 358),
      lab(tb(140, q.at(2), size: 9.5pt, fill: muted), x + 96 + 8 * calc.min(i, 1), 300, al: center + top),
    )
  }).flatten(),
  draw(mp-path(P(50, 130) + ".." + P(200, 170) + ".." + P(340, 92) + ".." + P(480, 170) + ".." + P(620, 92) + ".." + P(760, 170) + ".." + P(910, 130)),
    pens: ((2, 1, 30), (7, 2.2, 30), (9, 2.6, 30), (9, 2.6, 30), (9, 2.6, 30), (7, 2.2, 30), (2, 1, 30)), fill: ink),
  ..miles.map(m => {
    let (x, y, yr, txt, col) = m
    let up = y > 130
    let y1 = if up { y + 34 } else { y - 34 }
    let body = block(width: 150pt, align(center, {
      text(size: 15pt, weight: "bold", fill: col, yr); linebreak(); text(size: 10pt, fill: ink, txt)
    }))
    (
      draw(mp-path(P(x, y) + ".." + P(x, y1)), pen: fine, fill: col),
      fillp(circ(x, y, 15), white),
      draw(mp-path(circ(x, y, 15)), pen: fine, fill: ink),
      fillp(circ(x, y, 9), col),
      lab(body, x, y1 + if up { 4 } else { -4 }, al: center + (if up { bottom } else { top })),
    )
  }).flatten(),
)

// ═════════════════════════════════════════════════════ 3. SWOT & pyramide
#pagebreak()
#let swot-box(x, y, letter, name, items, col) = {
  let (w, h, c) = (215, 165, 26)
  let sp = poly(((x, y), (x + w, y), (x + w, y + h - c), (x + w - c, y + h), (x, y + h)))
  let head = poly(((x, y + h - 40), (x + w, y + h - 40), (x + w, y + h - c), (x + w - c, y + h), (x, y + h)))
  let fold = poly(((x + w - c, y + h), (x + w - c, y + h - c), (x + w, y + h - c)))
  (
    ..shadow(sp), fillp(sp, white), fillp(head, col), fillp(fold, deep(col)),
    ol(sp),
    lab(text(size: 15pt, weight: "bold", fill: white, letter), x + 22, y + h - 20),
    lab(text(size: 12pt, weight: "bold", fill: white, name), x + 42, y + h - 20, al: left + horizon),
    lab(tb(w - 34, items.map(t => [• #t]).join(linebreak()), size: 11pt, al: left), x + 17, y + h - 52, al: left + top),
  )
}
#let pyr = (
  ("Vision", T("the course", "le cap"), c-coral),
  (T("Strategy", "Stratégie"), T("the structuring choices", "les choix structurants"), c-amber),
  (T("Tactics", "Tactique"), T("the action plans per team", "les plans d'action par équipe"), c-teal),
  (T("Operations", "Opérations"), T("daily execution and indicators", "l'exécution quotidienne et les indicateurs"), c-blue),
)
#let half(y) = (430 - y) / 368 * 185
#FIG(
  ..slide-title(T("SWOT matrix and pyramid", "Matrice SWOT et pyramide"), T("Dog-eared corners with a dark fold; pyramid in separate slices, all outlined with the pen", "Coins cornés à pli foncé ; pyramide en tranches séparées, toutes contournées à la plume"), col: c-teal),
  swot-box(50, 250, "S", T("Strengths", "Forces"), (T("Experienced team", "Équipe expérimentée"), T("Differentiating product", "Produit différenciant"), T("Loyal customer base", "Base clients fidèle")), c-teal),
  swot-box(290, 250, "W", T("Weaknesses", "Faiblesses"), (T("Limited marketing budget", "Budget marketing limité"), T("Dependence on one supplier", "Dépendance à un fournisseur"), T("Poorly documented processes", "Processus peu documentés")), c-coral),
  swot-box(50, 60, "O", T("Opportunities", "Opportunités"), (T("Growing market", "Marché en croissance"), T("New partnerships", "Nouveaux partenariats"), T("Favourable regulation", "Réglementation favorable")), c-blue),
  swot-box(290, 60, "T", T("Threats", "Menaces"), (T("Better-funded competitors", "Concurrents mieux financés"), T("Fast-changing usage", "Évolution rapide des usages"), T("Supply tensions", "Tensions d'approvisionnement")), c-amber),
  fillp(circ(277.5, 237.5, 31), white),
  draw(mp-path(circ(277.5, 237.5, 31)), pen: nibpen, fill: ink),
  lab(text(size: 12pt, weight: "bold", "SWOT"), 277.5, 237.5),
  ..pyr.enumerate().map(((k, q)) => {
    let yt = 430 - 92 * k
    let yb = yt - 92 + 7
    let pts = if k == 0 { ((735, yt), (735 + half(yb), yb), (735 - half(yb), yb)) } else { ((735 - half(yt), yt), (735 + half(yt), yt), (735 + half(yb), yb), (735 - half(yb), yb)) }
    let sp = poly(pts)
    (
      ..shadow(sp), fillp(sp, q.at(2)), ol(sp, col: deep(q.at(2)), pen: fine),
      lab(text(size: if k == 0 { 11pt } else { 14pt }, fill: white, weight: "bold", q.at(0)), 735, yt - (if k == 0 { 60 } else { 34 })),
      if k > 0 { lab(tb(150 + 40 * k, q.at(1), size: 9pt, fill: white), 735, yt - 58) },
    )
  }).flatten(),
)

// ═════════════════════════════════════════════════════ 4. cycle, alvéoles, indicateurs
#pagebreak()
#let hex(cx, cy, r) = poly(range(6).map(j => { let q = polar(r, j * calc.pi / 3); (cx + q.at(0), cy + q.at(1)) }))
#let cyc = (("1", T("Plan", "Planifier"), c-coral), ("2", T("Do", "Faire"), c-amber), ("3", T("Check", "Vérifier"), c-teal), ("4", T("Act", "Agir"), c-blue))
#let hexes = ((T("Quality", "Qualité"), c-coral), (T("Time", "Délai"), c-amber), (T("Cost", "Coût"), c-teal), (T("Risk", "Risque"), c-blue), (T("Team", "Équipe"), c-violet), (T("Customer", "Client"), rgb("#d9588f")))
#let kpis = (("Budget", 0.58, c-amber), (T("Deadlines", "Délais"), 0.81, c-teal), (T("Quality", "Qualité"), 0.93, c-blue))
#FIG(
  ..slide-title(T("Cycle, honeycomb and indicators", "Cycle, alvéoles et indicateurs"), T("Curved arrows with tapered heads, honeycomb, gauge and progress bars", "Flèches courbes à pointe effilée, nid d'abeilles, jauge et barres de progression"), col: c-violet),
  // cycle
  ..cyc.enumerate().map(((k, q)) => {
    let a0 = k * 90 + 8
    let a1 = k * 90 + 84
    let mid = (k * 90 + 46) * calc.pi / 180
    let (lx, ly) = (235 + 138 * calc.cos(mid), 235 + 138 * calc.sin(mid))
    let bx = rr(lx - 54, ly - 25, 108, 50, 14)
    (
      ..arc-arrow(235, 235, 88, a0, a1, q.at(2), w: 11),
      ..card(lx - 54, ly - 25, 108, 50, r: 14, col: soft(q.at(2), t: 0.85)),
      lab(text(size: 12pt, weight: "bold", fill: deep(q.at(2), t: 0.2), [#q.at(0) · #q.at(1)]), lx, ly),
    )
  }).flatten(),
  fillp(circ(235, 235, 44), ink),
  draw(mp-path(circ(235, 235, 44)), pen: fine, fill: c-amber),
  lab(text(size: 14pt, weight: "bold", fill: white, "PDCA"), 235, 235),
  // alvéoles
  ..hexes.enumerate().map(((k, q)) => {
    let a = (30 + 60 * k) * calc.pi / 180
    let (x, y) = (610 + 94 * calc.cos(a), 235 + 94 * calc.sin(a))
    (..shadow(hex(x, y, 50)), fillp(hex(x, y, 50), q.at(1)), ol(hex(x, y, 50), col: deep(q.at(1)), pen: fine), lab(text(size: 11.5pt, weight: "bold", fill: white, q.at(0)), x, y))
  }).flatten(),
  ..shadow(hex(610, 235, 50)), fillp(hex(610, 235, 50), ink), ol(hex(610, 235, 50), col: c-amber, pen: fine),
  lab(text(size: 12pt, weight: "bold", fill: white, T("Project", "Projet")), 610, 235),
  // jauge
  draw(mp-path(circ(850, 345, 42)), pen: pencircle(10pt), fill: soft(c-coral, t: 0.8)),
  draw(mp-path(range(7).map(i => { let a = (90 - 259.2 * i / 6) * calc.pi / 180; P(850 + 42 * calc.cos(a), 345 + 42 * calc.sin(a)) }).join("..")),
    pens: range(7).map(i => (10, 10, 0)), fill: c-coral),
  lab(text(size: 19pt, weight: "bold", fill: c-coral, "72 %"), 850, 345),
  lab(text(size: 9.5pt, fill: muted, T("Overall progress", "Avancement global")), 850, 288),
  // barres
  ..kpis.enumerate().map(((k, q)) => {
    let y = 232 - 52 * k
    (
      lab(text(size: 10pt, weight: "bold", [#q.at(0) · #calc.round(q.at(1) * 100) %]), 770, y + 24, al: left + horizon),
      fillp(rr(770, y, 150, 13, 6.5), luma(228)),
      fillp(rr(770, y, 150 * q.at(1), 13, 6.5), q.at(2)),
      ol(rr(770, y, 150, 13, 6.5), pen: broadnib(1.8pt, t: 0.6pt, angle: 35deg)),
    )
  }).flatten(),
)

// ═════════════════════════════════════════════════════ 5. bannière, bulles, chiffres
#pagebreak()
#let stats = (("98 %", T("satisfaction", "de satisfaction"), T("survey of 1,200 users", "enquête auprès de 1 200 utilisateurs"), c-coral), ("×3", T("faster", "plus rapide"), T("average processing time", "temps moyen de traitement"), c-blue), ("12 j", T("to get started", "de mise en route"), T("from order to production", "de la commande à la production"), c-teal))
#FIG(
  // bannière à rubans
  ..shadow(poly(((300, 425), (660, 425), (660, 487), (300, 487)))),
  fillp(poly(((225, 410), (312, 410), (312, 472), (225, 472), (250, 441))), deep(c-coral, t: 0.12)),
  ol(poly(((225, 410), (312, 410), (312, 472), (225, 472), (250, 441))), pen: fine),
  fillp(poly(((735, 410), (648, 410), (648, 472), (735, 472), (710, 441))), deep(c-coral, t: 0.12)),
  ol(poly(((735, 410), (648, 410), (648, 472), (735, 472), (710, 441))), pen: fine),
  fillp(poly(((300, 425), (312, 410), (312, 425))), deep(c-coral, t: 0.5)),
  fillp(poly(((660, 425), (648, 410), (648, 425))), deep(c-coral, t: 0.5)),
  fillp(poly(((300, 425), (660, 425), (660, 487), (300, 487))), c-coral),
  ol(poly(((300, 425), (660, 425), (660, 487), (300, 487))), pen: nibpen),
  lab(text(size: 21pt, weight: "bold", fill: white, T("Banners, bubbles and figures", "Bannières, bulles et chiffres")), 480, 456),
  // bulles
  ..shadow(bub(70, 260, 380, 110, 24, 150)), fillp(bub(70, 260, 380, 110, 24, 150), soft(c-amber, t: 0.6)), ol(bub(70, 260, 380, 110, 24, 150)),
  lab(tb(330, [#T("“A well-chosen pen is worth a long speech.”", "« Une plume bien choisie vaut mieux qu'un long discours. »")], size: 14pt, al: left), 100, 315, al: left + horizon),
  ..shadow(bub(510, 260, 380, 110, 24, 800)), fillp(bub(510, 260, 380, 110, 24, 800), soft(c-teal, t: 0.6)), ol(bub(510, 260, 380, 110, 24, 800)),
  lab(tb(330, [#T("“Everything is a path: just give it a pen.”", "« Tout est un chemin : il suffit de lui donner une plume. »")], size: 14pt, al: left), 540, 315, al: left + horizon),
  // chiffres clés
  ..stats.enumerate().map(((k, q)) => {
    let x = 70 + 280 * k
    (
      ..card(x, 50, 260, 150, r: 22),
      fillp(rr(x, 50, 14, 150, 7), q.at(3)),
      lab(text(size: 44pt, weight: "bold", fill: q.at(3), q.at(0)), x + 36, 150, al: left + horizon),
      draw(mp-path(P(x + 36, 118) + ".." + P(x + 90, 115) + ".." + P(x + 150, 119)), pens: ((1, 0.6, 30), (5, 1.6, 30), (1, 0.6, 30)), fill: q.at(3)),
      lab(text(size: 13pt, weight: "bold", q.at(1)), x + 36, 98, al: left + horizon),
      lab(tb(200, q.at(2), size: 9.5pt, fill: muted, al: left), x + 36, 82, al: left + top),
    )
  }).flatten(),
)
