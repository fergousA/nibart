// « Hello Summer » : chat à la plage, redessiné avec nib d'après une illustration vectorielle plate.
// Coordonnées = pixels de l'image de référence (626×626, y vers le bas).
//   typst compile --root . examples/chat.typ
#import "../lib.typ": *
#import "../lib.typ" as nib

#set page(width: auto, height: auto, margin: 0pt)
#set text(font: "DejaVu Sans")

#let (W, H, s) = (626, 626, 0.9)
#let px(x, y) = (x * s * 1pt, (H - y) * s * 1pt)
#let PP(pts, cycle: false, tension: 1) = nib.mp-path-pts(pts.map(q => px(q.at(0), q.at(1))), cycle: cycle, tension: tension)
#let PL(pts, cycle: false) = nib.polyline(pts.map(q => px(q.at(0), q.at(1))), cycle: cycle)
#let u(v) = v * s * 1pt
#let rnd(seed) = calc.rem(seed * 1664525 + 1013904223, 4294967296)
#let r01(seed) = rnd(rnd(rnd(seed + 977))) / 4294967296
#let polar(cx, cy, r, a) = (cx + r * calc.cos(a), cy + r * calc.sin(a))

// palette
#let sand = rgb("#fdb233"); #let sand-dk = rgb("#dd8a22"); #let sand-shadow = rgb("#f29a2e")
#let sea = rgb("#7fd2e0"); #let sea-lt = rgb("#a2e2ec"); #let sea-dk = rgb("#62c0d2"); #let foam = rgb("#f4fcfd")
#let ink = rgb("#3a2230"); #let white = rgb("#fbf6ee"); #let cream = rgb("#f6ead8")
#let orange = rgb("#f08a35"); #let orange-dk = rgb("#c9641f")
#let pink = rgb("#f06aa8"); #let towel = rgb("#f7bcd8"); #let towel-dk = rgb("#eea2c8")
#let purple = rgb("#b47fe0"); #let purple-lt = rgb("#d8aaf2"); #let purple-dk = rgb("#8a55bd")

#let line-pen(w) = nib.pencircle(u(w))
#let stroke(pts, w, col, tension: 1) = nib.draw(PP(pts, tension: tension), pen: line-pen(w), fill: col)
#let taper(pts, w0, wm, w1, col) = nib.stroke-items(PP(pts), pen: nib.nibpen((at: 0%, width: u(w0), thinness: 100%), (at: 50%, width: u(wm), thinness: 100%), (at: 100%, width: u(w1), thinness: 100%)), fill: col, refine: 4)
#let shape(pts, fillc, line, w: 3.4, tension: 1) = (nib.mp-fill(PP(pts, cycle: true, tension: tension), fill: fillc), nib.draw(PP(pts, cycle: true, tension: tension), pen: line-pen(w), fill: line))
#let shape-l(pts, fillc, line, w: 3.4) = (nib.mp-fill(PL(pts, cycle: true), fill: fillc), nib.draw(PL(pts, cycle: true), pen: line-pen(w), fill: line))
#let ellipse-pts(cx, cy, rx, ry, rot: 0, n: 16) = range(n).map(i => {
  let a = i / n * 2 * calc.pi
  let (x, y) = (rx * calc.cos(a), ry * calc.sin(a))
  (cx + x * calc.cos(rot) - y * calc.sin(rot), cy + x * calc.sin(rot) + y * calc.cos(rot))
})
#let oval(cx, cy, rx, ry, fillc, line: none, rot: 0, w: 3) = {
  let p = ellipse-pts(cx, cy, rx, ry, rot: rot)
  (nib.mp-fill(PP(p, cycle: true), fill: fillc), ..if line != none { (nib.draw(PP(p, cycle: true), pen: line-pen(w), fill: line),) })
}
#let heart(cx, cy, r, rot: 0, n: 40) = range(n).map(i => {
  let t = i / n * 2 * calc.pi
  let x = 16 * calc.pow(calc.sin(t), 3)
  let y = 13 * calc.cos(t) - 5 * calc.cos(2 * t) - 2 * calc.cos(3 * t) - calc.cos(4 * t)
  let (x, y) = (x * r / 17, -y * r / 17)           // screen y down
  (cx + x * calc.cos(rot) - y * calc.sin(rot), cy + x * calc.sin(rot) + y * calc.cos(rot))
})

// ── mer et plage
#let shore = ((-10, 412), (40, 374), (100, 340), (170, 318), (232, 292), (272, 268), (332, 250), (400, 238), (440, 222), (484, 202), (545, 196), (636, 168))
#let sea-pts = (..shore, (636, -10), (-10, -10))
#let sea-shape = nib.mp-fill(PP(sea-pts, cycle: true, tension: 1), fill: sea)
#let shoreline = PP(shore)
#let foam-band = nib.stroke-items(shoreline, pen: nib.nibpen((at: 0%, width: u(16), thinness: 100%), (at: 35%, width: u(10), thinness: 100%), (at: 70%, width: u(13), thinness: 100%), (at: 100%, width: u(20), thinness: 100%)), fill: foam, refine: 6)
#let wet = nib.draw(shoreline, pen: line-pen(30), fill: sand.lighten(12%).transparentize(40%))
#let streaks = (
  ((-10, 40), (60, 30), (140, 52)), ((20, 160), (90, 150), (170, 168)), ((380, 40), (470, 20), (560, 38)),
  ((420, 120), (500, 98), (600, 118)), ((240, 28), (300, 14), (340, 30)), ((-10, 260), (40, 245), (90, 262)),
  ((500, 160), (560, 146), (620, 150)), ((180, 110), (220, 96), (250, 108)),
).map(p => nib.stroke-items(PP(p), pen: nib.nibpen((at: 0%, width: u(1), thinness: 100%), (at: 50%, width: u(9), thinness: 100%), (at: 100%, width: u(1), thinness: 100%)), fill: sea-dk.transparentize(35%), refine: 4))
#let sea-dots = ((28, 240), (47, 264), (72, 283), (120, 296), (176, 252), (200, 276), (170, 276), (565, 155), (548, 172), (585, 162), (595, 150)).map(p => nib.mp-dot(px(..p), pen: line-pen(4.6), fill: foam))

// grains de sable
#let grains = range(70).map(i => {
  let (x, y) = (r01(i * 7 + 1) * 626, r01(i * 11 + 3) * 626)
  let above = y < 420 - x * 0.39 + 10
  if above { none } else { nib.mp-dot(px(x, y), pen: line-pen(2.4 + r01(i * 5) * 2), fill: sand-dk.transparentize(if calc.even(i) { 10% } else { 40% })) }
}).filter(x => x != none)

// ── lettrage « Hello Summer » (traits à la plume, ombre décalée)
#let loc(ox, oy, th, sh, k, pts) = pts.map(q => {
  let (x, y) = (q.at(0) * k, q.at(1) * k)
  let lx = x + sh * y
  (ox + lx * calc.cos(th) - y * calc.sin(th), oy - (lx * calc.sin(th) + y * calc.cos(th)))
})
#let word-strokes(ox, oy, th, k, strokes, w, col, d: (0, 0)) = strokes.map(p => {
  let pts = loc(ox + d.at(0), oy + d.at(1), th, 0.22, k, p)
  taper(pts, w * 0.45, w, w * 0.5, col)
})
#let hello-P = (
  ((0, 85), (2, 40), (0, 0)), ((40, 85), (40, 40), (38, 0)), ((2, 42), (20, 46), (38, 42)),
  ((58, 28), (92, 32), (90, 46), (76, 54), (62, 44), (58, 20), (72, 2), (92, 8)),
  ((108, 92), (109, 40), (112, 8), (122, 0)), ((130, 92), (131, 40), (134, 8), (144, 0)),
  ((154, 28), (164, 48), (180, 44), (184, 26), (172, 6), (158, 12), (154, 28)),
)
#let summer-P = (
  ((0, 56), (3, 14), (18, 0), (34, 14)), ((44, 56), (45, 10), (58, 4)),
  ((72, 0), (73, 56)), ((73, 40), (86, 56), (100, 42), (101, 0)), ((101, 40), (115, 56), (129, 42), (130, 0), (136, 6), (144, 4)),
  ((152, 0), (153, 56)), ((153, 40), (166, 56), (180, 42), (181, 0)), ((181, 40), (195, 56), (209, 42), (210, 0), (216, 6), (224, 4)),
  ((232, 28), (268, 30), (266, 46), (252, 56), (234, 44), (230, 20), (244, 2), (264, 8)),
  ((282, 0), (283, 56)), ((283, 38), (296, 54), (312, 52), (320, 42)),
)
#let big-S = ((160, 128), (122, 97), (78, 104), (55, 140), (72, 178), (120, 200), (164, 216), (150, 256), (106, 286), (66, 270), (50, 236))
#let lettering(col, d) = (
  ..word-strokes(198, 124, 17deg, 0.78, hello-P, 13, col, d: d),
  ..word-strokes(176, 222, 13.5deg, 1.13, summer-P, 15, col, d: d),
  taper(big-S.map(q => (q.at(0) + d.at(0), q.at(1) - d.at(1))), 5, 17, 6, col),
)
#let lettering-items = (..lettering(sea-lt.darken(6%), (3, -3)), ..lettering(white, (0, 0)))
#let sparks = (((160, 86), (184, 96)), ((162, 108), (180, 106)), ((166, 122), (178, 130)), ((362, 48), (374, 32)), ((372, 66), (394, 52)), ((382, 42), (394, 38))).map(p => stroke(p, 3.4, white))

// ── crabe
#let crab = {
  let red = rgb("#e23a52"); let red-dk = rgb("#b82a44"); let red-lt = rgb("#ee6070")
  (
    ..oval(175, 435, 88, 32, sand-shadow, rot: 0.05),
    stroke(((150, 352), (148, 388)), 6.5, red-dk), stroke(((188, 352), (192, 388)), 6.5, red-dk),
    nib.mp-dot(px(150, 350), pen: line-pen(10), fill: red-dk), nib.mp-dot(px(188, 350), pen: line-pen(10), fill: red-dk),
    // pattes
    ..(((128, 422), (108, 436), (126, 456)), ((134, 434), (120, 452), (138, 466)), ((150, 440), (142, 460), (154, 472)),
       ((224, 420), (246, 414), (252, 424)), ((216, 432), (240, 436), (246, 446)), ((204, 442), (224, 456), (226, 468))).map(p => stroke(p, 6, red-dk)),
    // bras + pinces
    stroke(((128, 398), (104, 388), (98, 368)), 10, red),
    stroke(((214, 392), (236, 376), (240, 356)), 11, red),
    ..shape(((80, 372), (78, 388), (98, 402), (122, 392), (114, 372), (104, 380), (96, 366)), red, red-dk, w: 2.4),
    ..shape(((212, 344), (218, 324), (238, 322), (266, 338), (258, 352), (244, 348), (256, 368), (238, 380), (222, 368)), red, red-dk, w: 2.4),
    ..oval(178, 408, 52, 40, red, line: red-dk, rot: 0.05, w: 2.4),
    ..oval(170, 392, 26, 14, red-lt.transparentize(45%), rot: -0.2),
    nib.draw(PP(((160, 414), (170, 408), (180, 414))), pen: line-pen(3.2), fill: ink),
    nib.draw(PP(((194, 410), (202, 404), (212, 410))), pen: line-pen(3.2), fill: ink),
    nib.draw(PP(((180, 426), (186, 430), (192, 426))), pen: line-pen(2.4), fill: ink),
  )
}

// ── serviette
#let towel-pts = ((150, 526), (424, 394), (586, 462), (300, 612))
#let towel-items = (
  ..shape-l(towel-pts, towel, towel-dk, w: 3),
  ..oval(372, 506, 168, 72, towel-dk.transparentize(35%), rot: -0.42),
)

// ── chat
#let cat = {
  let outline = ink
  (
    // dos orange derrière
    ..oval(436, 410, 44, 22, orange, rot: -0.2),
    // torse
    ..shape(((370, 380), (440, 392), (486, 420), (500, 462), (470, 508), (430, 504), (398, 468), (360, 418)), white, cream.darken(8%), w: 2.4),
    // bras droit posé sur la serviette
    taper(((478, 400), (494, 452), (456, 500)), 30, 42, 36, white), nib.draw(PP(((480, 402), (494, 452), (458, 500))), pen: line-pen(2), fill: cream.darken(8%)),
    ..oval(446, 498, 22, 14, white, line: cream.darken(8%), rot: -0.6, w: 2),
    // short violet
    ..shape(((258, 466), (300, 430), (346, 410), (400, 418), (452, 426), (470, 458), (444, 502), (402, 536), (352, 548), (304, 506)), purple, purple-dk, w: 3),
    ..range(9).map(i => {
      let (x, y) = ((290 + i * 20 + (calc.rem(i, 2)) * 10), 470 + calc.rem(i * 37, 62) - calc.rem(i, 3) * 6)
      let (x, y) = if i == 0 { (285, 478) } else if i == 1 { (330, 448) } else if i == 2 { (392, 440) } else if i == 3 { (436, 452) } else if i == 4 { (372, 500) } else if i == 5 { (322, 506) } else if i == 6 { (420, 500) } else if i == 7 { (360, 465) } else { (306, 456) }
      (..range(5).map(k => { let a = k * 2 * calc.pi / 5 + i; nib.mp-dot(px(..polar(x, y, 9, a)), pen: line-pen(10), fill: purple-lt) }), nib.mp-dot(px(x, y), pen: line-pen(5), fill: purple))
    }).flatten(),
    nib.draw(PP(((350, 470), (372, 476), (396, 472))), pen: line-pen(3), fill: purple-dk),
    // jambes + pattes (plantes vers nous)
    taper(((292, 462), (270, 482), (252, 500)), 34, 34, 30, white),
    taper(((372, 520), (350, 536), (332, 548)), 34, 34, 30, white),
    ..oval(244, 498, 24, 30, white, line: cream.darken(8%), rot: 0.2, w: 2),
    ..oval(244, 504, 13, 10, pink, rot: 0.1),
    ..(((228, 486), (243, 478), (258, 486))).map(p => nib.mp-dot(px(..p), pen: line-pen(8), fill: pink)),
    ..oval(326, 545, 26, 32, white, line: cream.darken(8%), rot: 0.2, w: 2),
    ..oval(327, 551, 13, 10, pink, rot: 0.1),
    ..(((312, 530), (327, 522), (342, 530))).map(p => nib.mp-dot(px(..p), pen: line-pen(8), fill: pink)),
    // bras tenant la glace
    ..shape(((292, 322), (316, 300), (346, 320), (344, 360), (316, 384), (296, 362)), orange, orange, w: 2),
    ..shape-l(((294, 326), (336, 320), (310, 374)), rgb("#e8a45c"), rgb("#b87630"), w: 2.4),
    nib.draw(PL(((304, 332), (320, 352))), pen: line-pen(2), fill: rgb("#b87630")), nib.draw(PL(((322, 330), (312, 350))), pen: line-pen(2), fill: rgb("#b87630")),
    ..shape(((284, 300), (292, 284), (318, 280), (346, 284), (350, 304), (336, 322), (300, 322)), rgb("#f6bcd6"), rgb("#e89ac0"), w: 2),
    ..shape(((292, 282), (298, 258), (320, 248), (340, 258), (344, 282), (318, 288)), rgb("#b8e8d8"), rgb("#8fcfba"), w: 2),
    nib.mp-dot(px(318, 240), pen: line-pen(13), fill: rgb("#f2a0c0")), nib.mp-dot(px(315, 237), pen: line-pen(4), fill: white),
    // tête : fond orange + blanc + oreilles
    ..shape-l(((398, 264), (408, 206), (452, 250)), orange, orange-dk, w: 2.4),
    ..shape-l(((500, 268), (538, 236), (548, 290), (536, 306)), white, cream.darken(10%), w: 2.4),
    ..shape(((372, 302), (384, 262), (430, 248), (490, 262), (536, 292), (546, 336), (512, 376), (456, 390), (402, 374), (368, 338)), white, cream.darken(8%), w: 2.4),
    ..shape(((388, 288), (396, 258), (430, 246), (470, 252), (482, 278), (452, 290), (420, 300)), orange, orange, w: 1.5),
    nib.draw(PP(((424, 210), (430, 226), (434, 244))), pen: line-pen(3), fill: outline), nib.draw(PP(((438, 208), (440, 226), (442, 244))), pen: line-pen(3), fill: outline),
    nib.draw(PP(((520, 248), (528, 258), (534, 272))), pen: line-pen(3), fill: outline), nib.draw(PP(((512, 262), (522, 268), (530, 282))), pen: line-pen(3), fill: outline),
    // museau
    ..oval(430, 346, 7, 5, rgb("#e88a8a")),
    nib.draw(PP(((408, 342), (420, 350), (430, 346), (440, 352), (452, 344))), pen: line-pen(2.6), fill: outline),
    // moustaches
    ..(((346, 298), (366, 308)), ((346, 312), (368, 316)), ((346, 326), (368, 324)), ((500, 352), (552, 349)), ((504, 362), (550, 372)), ((500, 374), (524, 386))).map(p => stroke(p, 2.4, outline)),
    // lunettes cœur
    ..{
      let lh = heart(400, 296, 50, rot: 0.25)
      let rh = heart(492, 318, 48, rot: 0.25)
      let frame(h) = (nib.mp-fill(PP(h, cycle: true), fill: pink), nib.draw(PP(h, cycle: true), pen: line-pen(3), fill: rgb("#d44b8a")))
      let inner(cx, cy, r, rot) = { let h = heart(cx, cy, r, rot: rot); (nib.mp-fill(PP(h, cycle: true), fill: rgb("#2b1838"))) }
      let bar(cx, cy, dx) = stroke(((cx + dx, cy - 28), (cx + dx - 8, cy + 26)), 5.4, rgb("#f4e6f4"))
      (..frame(lh), inner(400, 298, 37, 0.25), bar(400, 298, -10), bar(400, 298, 12),
       ..frame(rh), inner(492, 320, 35, 0.25), bar(492, 320, -8), bar(492, 320, 13),
       stroke(((440, 300), (456, 312)), 6, pink))
    },
  )
}

#nib.mp-fig(
  nib.mp-fill(PL(((-10, -10), (640, -10), (640, 640), (-10, 640)), cycle: true), fill: sand),
  wet, sea-shape, foam-band, ..streaks, ..sea-dots,
  ..grains,
  ..lettering-items, ..sparks,
  ..crab, ..towel-items, ..cat,
  width: W * s * 1pt, height: H * s * 1pt, origin: (0pt, 0pt), clip: true)
