// Calligraphie : les priorités opératoires sur un podium.
//   1re place  : les parenthèses        2e place : × et ÷ (même rang, de gauche à droite)        3e place : + et −
// Tout ce qui n'est pas du texte courant (signes, chiffres, podium, lauriers, étoiles, filets) est tracé à la plume avec nib.
//   typst compile --root . examples/podium.typ                       (français)
//   typst compile --root . --input lang=ar --font-path <dossier de ArabTeXNaskh-*.otf> examples/podium.typ   (arabe)
//   typst compile --root . --input lang=en examples/podium.typ       (anglais)
#import "../lib.typ" as nib

#let paper = rgb("#efe8d8"); #let ink = rgb("#2b2622"); #let muted = rgb("#6d6254")
#let red = rgb("#a83b32"); #let blue = rgb("#2f628c"); #let green = rgb("#4d7b47"); #let gold = rgb("#c9962c")
#let lang = sys.inputs.at("lang", default: "fr")
#let rtl = lang == "ar"
#set page(width: auto, height: auto, margin: 18pt, fill: paper)
#set text(font: if rtl { ("ArabTeX Naskh", "DejaVu Sans") } else { "Libertinus Serif" }, fill: ink, lang: lang, dir: if rtl { std.rtl } else { std.ltr })

#let tr = (
  fr: (title: [Priorités opératoires], sub: [Le podium du calcul], p1: [Parenthèses], p1a: [d'abord ce qui est], p1b: [entre parenthèses],
       p2a: [Multiplication], p2b: [et division], p2c: [de gauche à droite], p3a: [Addition], p3b: [et soustraction], p3c: [de gauche à droite],
       ex: [Exemple], foot: [① parenthèses   ② multiplication   ③ addition]),
  en: (title: [Order of operations], sub: [The podium of arithmetic], p1: [Brackets], p1a: [first, whatever is], p1b: [inside brackets],
       p2a: [Multiplication], p2b: [and division], p2c: [from left to right], p3a: [Addition], p3b: [and subtraction], p3c: [from left to right],
       ex: [Example], foot: [① brackets   ② multiplication   ③ addition]),
  ar: (title: [أولويات العمليات الحسابية], sub: [منصّة التتويج الحسابية], p1: [الأقواس], p1a: [نبدأ أوّلًا بما], p1b: [بين القوسين],
       p2a: [الضرب و القسمة], p2b: none, p2c: [من اليسار إلى اليمين], p3a: [الجمع و الطرح], p3b: none, p3c: [من اليسار إلى اليمين],
       ex: [مثال], foot: [① الأقواس   ② الضرب   ③ الجمع]),
).at(lang)

#let (W, H) = (520, 800)
#let pk = 0.88                                   // échelle du podium
#let Qx(x) = 260 + (x - 260) * pk
#let Qy(y) = 548 - (562 - y) * pk
#let dy = Qy(330) - 330                          // décalage du décor au-dessus du podium
#let px(x, y) = (x * 1pt, (H - y) * 1pt)
#let PP(pts, cycle: false, tension: 1) = nib.mp-path-pts(pts.map(q => px(q.at(0), q.at(1))), cycle: cycle, tension: tension)
#let PL(pts, cycle: false) = nib.polyline(pts.map(q => px(q.at(0), q.at(1))), cycle: cycle)
#let rnd(seed) = calc.rem(seed * 1664525 + 1013904223, 4294967296)
#let r01(seed) = rnd(rnd(rnd(seed + 977))) / 4294967296
#let polar(cx, cy, r, a) = (cx + r * calc.cos(a), cy + r * calc.sin(a))

// ── plumes
#let pen3(w, mid, end: 0.35, thin: 22%, ang: 38deg) = nib.nibpen(
  (at: 0%, width: w * 1pt, thinness: thin, angle: ang), (at: 50%, width: mid * 1pt, thinness: thin, angle: ang), (at: 100%, width: end * w * 1pt, thinness: thin, angle: ang))
#let sign-pen(w) = nib.nibpen((at: 0%, width: w * 0.45 * 1pt, thinness: 40%, angle: 40deg), (at: 50%, width: w * 1pt, thinness: 40%, angle: 40deg), (at: 100%, width: w * 0.45 * 1pt, thinness: 40%, angle: 40deg))
#let gesture(pts, pen, col, tension: 1) = nib.stroke-items(PP(pts, tension: tension), pen: pen, fill: col, refine: 5)
#let flat(pts, pen, col) = nib.stroke-items(PL(pts), pen: pen, fill: col, refine: 3)
#let ball(x, y, r, col) = nib.mp-dot(px(x, y), pen: nib.pencircle(r * 2pt), fill: col)

// ── signes, tracés comme à la main
#let x-sign(cx, cy, h, col) = (
  ..gesture(((cx - h, cy - h), (cx, cy + 1), (cx + h + 2, cy + h)), sign-pen(9), col),
  ..gesture(((cx + h, cy - h - 1), (cx + 1, cy - 1), (cx - h - 2, cy + h + 1)), sign-pen(7), col))
#let div-sign(cx, cy, h, col) = (
  ..gesture(((cx - h - 3, cy + 1), (cx, cy - 1), (cx + h + 3, cy + 1)), sign-pen(8), col),
  ball(cx, cy - h * 0.72, 5.4, col), ball(cx, cy + h * 0.72 + 1, 5.4, col))
#let plus-sign(cx, cy, h, col) = (
  ..gesture(((cx - h, cy + 1), (cx, cy - 1), (cx + h, cy)), sign-pen(8), col),
  ..gesture(((cx + 1, cy - h - 1), (cx - 1, cy), (cx, cy + h + 1)), sign-pen(7), col))
#let minus-sign(cx, cy, h, col) = gesture(((cx - h - 3, cy + 2), (cx, cy - 1), (cx + h + 3, cy + 1)), sign-pen(9), col)
#let paren(cx, top, bot, col, open: true) = {
  let k = if open { 1 } else { -1 }; let m = (top + bot) / 2; let d = (bot - top)
  gesture(((cx + 15 * k, top), (cx - 1 * k, top + d * 0.27), (cx - 4 * k, m + 4), (cx - 1 * k, bot - d * 0.27), (cx + 15 * k, bot)),
    nib.nibpen((at: 0%, width: 4pt, thinness: 24%, angle: 40deg), (at: 50%, width: 17pt, thinness: 24%, angle: 40deg), (at: 100%, width: 4pt, thinness: 24%, angle: 40deg)), col)
}

// ── chiffres 1, 2, 3
#let digit(n, cx, cy, col) = {
  let pen = nib.nibpen((at: 0%, width: 5pt, thinness: 35%, angle: 40deg), (at: 50%, width: 9pt, thinness: 35%, angle: 40deg), (at: 100%, width: 4pt, thinness: 35%, angle: 40deg))
  let g(pts) = gesture(pts.map(q => (cx + q.at(0) * pk, cy + q.at(1) * pk)), pen, col)
  if n == 1 { (..g(((-10, -12), (2, -25))), ..g(((2, -25), (3, 0), (2, 27))), ..g(((-9, 27), (14, 27)))) }
  else if n == 2 { (..g(((-14, -13), (-8, -24), (3, -27), (13, -19), (12, -6), (2, 6), (-14, 27))), ..g(((-14, 27), (2, 27), (17, 27)))) }
  else { (..g(((-13, -21), (-1, -27), (12, -19), (9, -8), (-3, -2))), ..g(((-3, -2), (12, 4), (14, 16), (4, 27), (-14, 23)))) }
}

// ── podium : blocs à main levée
#let jit(pts, a: 1.4, seed: 1) = pts.enumerate().map(((i, q)) => (q.at(0) + (r01(seed * 13 + i * 5) - 0.5) * 2 * a, q.at(1) + (r01(seed * 17 + i * 7 + 3) - 0.5) * 2 * a))
#let block(x0, x1, top, bot, tint, edge, seed) = {
  let (x0, x1, top, bot) = (Qx(x0), Qx(x1), Qy(top), Qy(bot))
  let pts = jit(((x0, top), (x1, top), (x1, bot), (x0, bot)), seed: seed)
  (nib.mp-fill(PL(pts, cycle: true), fill: tint),
   nib.mp-fill(PL(((x0, top + 9), (x1, top + 9), (x1, top + 12), (x0, top + 12)), cycle: true), fill: edge.transparentize(55%)),
   ..flat(pts + (pts.at(0),), nib.nibpen(width: 4.6pt, thinness: 30%, angle: 40deg), ink))
}

// ── ornements
#let star(cx, cy, r, col, rot: -90deg) = {
  let pts = range(10).map(i => polar(cx, cy, if calc.even(i) { r } else { r * 0.42 }, rot.rad() + i * calc.pi / 5))
  (nib.mp-fill(PL(pts, cycle: true), fill: col), ..flat(pts + (pts.at(0),), nib.nibpen(width: 1.6pt, thinness: 40%, angle: 40deg), ink))
}
#let sparkle(cx, cy, r, col) = (..gesture(((cx, cy - r), (cx, cy + r)), sign-pen(3), col), ..gesture(((cx - r, cy), (cx + r, cy)), sign-pen(3), col))
#let leaf(x, y, ang, len, col) = {
  let t = (x + len * calc.cos(ang), y + len * calc.sin(ang)); let mid = polar(x, y, len * 0.5, ang + 0.18)
  nib.stroke-items(PP(((x, y), mid, t)), pen: nib.nibpen((at: 0%, width: 0.6pt, thinness: 100%), (at: 45%, width: len * 0.42 * 1pt, thinness: 100%), (at: 100%, width: 0.4pt, thinness: 100%)), fill: col, refine: 4)
}
#let bez2(p0, p1, p2, t) = ((1 - t) * (1 - t) * p0.at(0) + 2 * (1 - t) * t * p1.at(0) + t * t * p2.at(0), (1 - t) * (1 - t) * p0.at(1) + 2 * (1 - t) * t * p1.at(1) + t * t * p2.at(1))
#let laurel(p0, p1, p2, side, col) = {
  let n = 9
  let pts = range(n + 1).map(i => bez2(p0, p1, p2, i / n))
  (..gesture(pts, nib.nibpen((at: 0%, width: 3.4pt, thinness: 100%), (at: 100%, width: 1.2pt, thinness: 100%)), col.darken(25%)),
   ..range(1, n + 1).map(i => {
     let a = pts.at(i); let b = pts.at(i - 1)
     let tg = calc.atan2(a.at(0) - b.at(0), a.at(1) - b.at(1)).rad()
     (leaf(a.at(0), a.at(1), tg + 0.85 * side, 25, col), leaf(a.at(0), a.at(1), tg - 0.85 * side, 25, col.lighten(8%)))
   }).flatten())
}
#let rule(y, x0, x1, col, w: 5) = gesture(((x0, y), ((x0 + x1) / 2, y - 3), (x1, y + 1)), nib.nibpen((at: 0%, width: 0.3pt, thinness: 40%, angle: 30deg), (at: 30%, width: w * 1pt, thinness: 28%, angle: 30deg), (at: 100%, width: 0.2pt, thinness: 40%, angle: 30deg)), col)

#let block-text(body, x, y, size: 13, col: ink, style: "italic") = nib.mp-label(text(size: size * 1pt * (if rtl { 1.25 } else { 1 }), style: if rtl { "normal" } else { style }, fill: col, body), px(x, y))

// ── composition
#let frame = {
  let pts = jit(((16, 16), (W - 16, 16), (W - 16, H - 16), (16, H - 16)), a: 1.6, seed: 5)
  let pts2 = jit(((24, 24), (W - 24, 24), (W - 24, H - 24), (24, H - 24)), a: 1.2, seed: 9)
  (..flat(pts + (pts.at(0),), nib.nibpen(width: 3.6pt, thinness: 30%, angle: 40deg), ink), ..flat(pts2 + (pts2.at(0),), nib.nibpen(width: 1.2pt, thinness: 40%, angle: 40deg), ink.transparentize(30%)))
}
#let confetti = range(46).map(i => {
  let (x, y) = (40 + r01(i * 7 + 1) * 440, 150 + r01(i * 11 + 3) * 170)
  let col = (red, blue, green, gold).at(calc.rem(i, 4))
  if (x > 170 and x < 350 and y > 175) { none } else { ball(x, y, 1.6 + r01(i) * 2.2, col.transparentize(25%)) }
}).filter(x => x != none)

#let example = {
  let e(body) = text(size: 22pt, font: "Libertinus Serif", body)
  let b(col, body) = text(fill: col, weight: "bold", body)
  set text(dir: std.ltr)
  grid(columns: 3, column-gutter: 12pt, row-gutter: 9pt, align: (right, center, left),
    e[2 + 3 × #b(red)[(4 − 1)]], e[=], e[2 + #b(blue)[3 × 3]],
    [], e[=], e[#b(green)[2 + 9]],
    [], e[=], e[#b(ink)[11]])
}

#let (T1, T2, T3) = (Qy(330), Qy(386), Qy(422))
#let (cl, cc, cr) = ((Qx(40) + Qx(190)) / 2, 260, (Qx(330) + Qx(480)) / 2)
#let lines(x, top, ..items) = items.pos().filter(q => q.at(1) != none).map(q => block-text(q.at(1), x, top + q.at(0), size: q.at(2), col: if q.at(3) { muted } else { ink })).flatten()

#nib.mp-fig(
  ..frame,
  // titre
  nib.mp-label(text(size: if rtl { 44pt } else { 35pt }, style: if rtl { "normal" } else { "italic" }, weight: if rtl { "bold" } else { "regular" }, fill: ink, tr.title), px(260, if rtl { 62 } else { 78 })),
  ..gesture(((96, 106), (170, 97), (250, 104), (340, 96), (418, 102), (448, 88)), pen3(3, 7, end: 0.1), red),
  ..gesture(((140, 117), (250, 111), (372, 115)), pen3(1.2, 2.6, end: 0.1), gold),
  block-text(tr.sub, 260, 136, size: 13, col: muted),
  ..confetti,
  // lauriers + étoiles autour de la 1re place
  ..laurel((200, 322 + dy), (150, 290 + dy), (176, 214 + dy), 1, green), ..laurel((320, 322 + dy), (370, 290 + dy), (344, 214 + dy), -1, green),
  ..star(260, 178 + dy, 16, gold), ..star(228, 196 + dy, 8, gold.lighten(10%)), ..star(292, 196 + dy, 8, gold.lighten(10%)),
  ..sparkle(100, 250, 9, gold), ..sparkle(424, 240, 10, gold), ..sparkle(64, 296, 6, red),
  // blocs : 2e à gauche, 1re au centre, 3e à droite
  ..block(40, 190, 386, 562, rgb("#d3dbe2"), blue, 3),
  ..block(330, 480, 422, 562, rgb("#e8cdb2"), green, 4),
  ..block(190, 330, 330, 562, rgb("#f2dc9c"), gold, 2),
  // signes sur les blocs
  ..paren(226, 208 + dy, 316 + dy, red), ..paren(294, 208 + dy, 316 + dy, red, open: false),
  ..x-sign(cl - 25, T2 - 27, 19 * pk, blue), ..div-sign(cl + 25, T2 - 27, 19 * pk, blue),
  ..plus-sign(cr - 25, T3 - 25, 19 * pk, green), ..minus-sign(cr + 25, T3 - 25, 19 * pk, green),
  // numéros et légendes
  ..digit(1, cc, T1 + 47, red),
  ..lines(cc, T1, (96, tr.p1, 15, false), (122, tr.p1a, 10.5, true), (if rtl { 140 } else { 137 }, tr.p1b, 10.5, true)),
  ..digit(2, cl, T2 + 43, blue),
  ..if tr.p2b == none { lines(cl, T2, (86, tr.p2a, 13.5, false), (110, tr.p2c, 10.5, true)) } else { lines(cl, T2, (80, tr.p2a, 13.5, false), (96, tr.p2b, 13.5, false), (118, tr.p2c, 10.5, true)) },
  ..digit(3, cr, T3 + 43, green),
  ..if tr.p3b == none { lines(cr, T3, (84, tr.p3a, 13.5, false), (108, tr.p3c, 10.5, true)) } else { lines(cr, T3, (79, tr.p3a, 13.5, false), (95, tr.p3b, 13.5, false), (113, tr.p3c, 10.5, true)) },
  ..rule(553, 30, W - 30, ink),
  // exemple : une étape par ligne
  ..gesture(((150, 602), (170, 596), (190, 602)), pen3(1.2, 2.4, end: 0.1), gold), ..gesture(((330, 602), (350, 596), (370, 602)), pen3(1.2, 2.4, end: 0.1), gold),
  block-text(tr.ex, 260, 600, size: 13, col: muted),
  nib.mp-label(example, px(260, 676)),
  block-text(tr.foot, 260, 752, size: 11, col: muted),
  ..rule(772, 150, 370, red, w: 3),
  width: W * 1pt, height: H * 1pt, origin: (0pt, 0pt), clip: true)
