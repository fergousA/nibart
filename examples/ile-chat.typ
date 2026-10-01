// Variante de ile.typ : même figure (île, serviette, point A, flèche « 6 m »), mais un chat à lunettes cœur remplace le bonhomme.
// Les coordonnées sont celles de l'image de référence (pixels, y vers le bas) ; `px` convertit en points y-haut.
//   typst compile --root . examples/ile-chat.typ
#import "../lib.typ" as nib

#set page(width: auto, height: auto, margin: 6pt)
#set text(font: "DejaVu Sans")

#let (W, H, s) = (1250, 1085, 0.36)
#let px(x, y) = (x * s * 1pt, (H - y) * s * 1pt)
#let PP(pts, cycle: false, tension: 1) = nib.mp-path-pts(pts.map(q => px(q.at(0), q.at(1))), cycle: cycle, tension: tension)
#let PL(pts, cycle: false) = nib.polyline(pts.map(q => px(q.at(0), q.at(1))), cycle: cycle)
#let u(v) = v * s * 1pt                     // a length in reference pixels
#let rnd(seed) = calc.rem(seed * 1664525 + 1013904223, 4294967296)
#let r01(seed) = rnd(rnd(rnd(seed + 977))) / 4294967296
#let polar(cx, cy, r, a) = (cx + r * calc.cos(a), cy + r * calc.sin(a))

#let sea = rgb("#6cb8ca"); #let sea2 = rgb("#58a7bd"); #let foam = rgb("#e9f7f8")
#let sand = rgb("#f8dba1"); #let rim = rgb("#f0bf86"); #let lagoon = rgb("#9fd3d1")
#let ink = rgb("#161616")

// ── mer : blob ondulé
#let sea-blob = PP(((40, 110), (150, 50), (330, 38), (520, 62), (700, 44), (880, 20), (1040, 6), (1160, 38), (1232, 150), (1236, 350), (1214, 560), (1240, 760), (1200, 905), (1120, 1002), (1000, 1050), (850, 1072), (700, 1042), (520, 1062), (360, 1078), (200, 1060), (100, 1012), (40, 900), (28, 700), (46, 520), (24, 330), (26, 200)), cycle: true)
// ── île : disque légèrement irrégulier
#let disc = PP(range(28).map(i => { let a = i / 28 * 2 * calc.pi; polar(642, 568, 438 + (r01(i * 3 + 1) - 0.5) * 12, a) }), cycle: true)

// ── traînées blanches de la mer (effilées)
#let streak(pts, w: 8, col: foam.transparentize(10%)) = nib.stroke-items(PP(pts), pen: nib.nibpen((at: 0%, width: u(1.2), thinness: 100%), (at: 50%, width: u(w), thinness: 100%), (at: 100%, width: u(1.2), thinness: 100%)), fill: col, refine: 4)
#let bold = (
  ((92, 142), (140, 100), (188, 62)), ((212, 232), (268, 208), (312, 130)), ((686, 54), (760, 76), (842, 62)),
  ((1142, 108), (1166, 160), (1196, 218)), ((82, 520), (96, 430), (130, 352)), ((1150, 420), (1162, 520), (1190, 580)),
  ((150, 856), (212, 925), (246, 968)), ((950, 978), (1010, 940), (1085, 880)), ((1182, 820), (1160, 896), (1112, 955)),
  ((395, 1010), (350, 1020), (300, 1002)),
)
#let fine = (
  ((60, 300), (90, 240), (150, 190)), ((230, 120), (330, 80), (450, 92)), ((790, 110), (900, 90), (1010, 130)),
  ((1090, 240), (1120, 330), (1110, 420)), ((1170, 640), (1140, 720), (1150, 800)), ((120, 620), (85, 700), (110, 780)),
  ((520, 1030), (610, 1010), (720, 1018)), ((860, 1030), (900, 1000), (960, 990)), ((240, 1040), (300, 1030), (370, 1040)),
  ((70, 880), (120, 940), (190, 990)), ((1040, 60), (1080, 100), (1115, 160)), ((330, 150), (380, 120), (440, 130)),
)
#let waves = (..fine.map(p => streak(p, w: 3.6, col: rgb("#9ed5e0").transparentize(10%))).flatten(), ..bold.map(p => streak(p, w: 9)).flatten())

// ── sable : paillettes
#let specks = range(150).map(i => {
  let a = r01(i * 7 + 3) * 2 * calc.pi; let r = 405 * calc.sqrt(r01(i * 11 + 5))
  let (x, y) = polar(642, 568, r, a)
  let light = calc.even(i)
  nib.mp-dot(px(x, y), pen: nib.pencircle(u(2 + r01(i * 13 + 1) * 3.5)), fill: if light { rgb("#fdeecb").transparentize(25%) } else { rgb("#ebc58a").transparentize(45%) })
})
#let glow = nib.mp-dot(px(570, 345), pen: nib.pencircle(u(52)), fill: rgb("#fcebc8").transparentize(35%))

// ── étoile de mer
#let starfish = {
  let pts = range(10).map(i => { let r = if calc.even(i) { 46 } else { 21 }; polar(462, 808, r, i * calc.pi / 5 + 0.35) })
  (nib.mp-fill(PP(pts, cycle: true, tension: 1.4), fill: rgb("#efba98")),
   ..range(5).map(i => nib.mp-dot(px(..polar(462, 808, 26, i * 2 * calc.pi / 5 + 0.35)), pen: nib.pencircle(u(4)), fill: rgb("#f8d9c2"))))
}

// ── serviette
#let TL = (796, 425); #let TR = (1022, 520); #let BR = (815, 842); #let BL = (605, 735)
#let towel-pts = (TL, ((TL.at(0) + TR.at(0)) / 2, (TL.at(1) + TR.at(1)) / 2 - 3), TR, ((TR.at(0) + BR.at(0)) / 2 + 6, (TR.at(1) + BR.at(1)) / 2), BR, ((BR.at(0) + BL.at(0)) / 2, (BR.at(1) + BL.at(1)) / 2 + 5), BL, ((BL.at(0) + TL.at(0)) / 2 - 4, (BL.at(1) + TL.at(1)) / 2))
#let towel = (
  nib.mp-fill(PL(towel-pts, cycle: true), fill: rgb("#fcfcf7")),
  nib.draw(PL(towel-pts, cycle: true), pen: nib.broadnib(u(5), t: u(3), angle: 40deg), fill: rgb("#d8d8d2")),
  ..range(46).map(i => {
    let (a, b) = (r01(i * 5 + 2) * 0.9 + 0.05, r01(i * 9 + 4) * 0.9 + 0.05)
    let x = (1 - a) * (1 - b) * TL.at(0) + a * (1 - b) * TR.at(0) + (1 - a) * b * BL.at(0) + a * b * BR.at(0)
    let y = (1 - a) * (1 - b) * TL.at(1) + a * (1 - b) * TR.at(1) + (1 - a) * b * BL.at(1) + a * b * BR.at(1)
    nib.mp-dot(px(x, y), pen: nib.pencircle(u(3.4)), fill: rgb("#b9c9ea"))
  }),
)

// ── chat allongé sur le dos (vu de dessus) : dessiné debout en coordonnées locales, puis tourné de 22,5°
#let (hx, hy) = (866, 531)
#let (ca, sa) = (calc.cos(22.5deg), calc.sin(22.5deg))
#let ck = 1.08
#let T(q) = { let (x, y) = (q.at(0) * ck, q.at(1) * ck); (hx + x * ca - y * sa, hy + x * sa + y * ca) }
#let CP(pts, cycle: false, tension: 1) = PP(pts.map(T), cycle: cycle, tension: tension)
#let CL(pts) = PL(pts.map(T), cycle: true)
#let cw = rgb("#fbf6ee"); #let ccream = rgb("#d6c8b2"); #let co = rgb("#f08a35"); #let cod = rgb("#c9641f")
#let cpink = rgb("#f06aa8"); #let cpurple = rgb("#b47fe0"); #let cpurple-lt = rgb("#d8aaf2"); #let cpurple-dk = rgb("#8a55bd"); #let cink = rgb("#3a2230")
#let cpen(w) = nib.pencircle(u(w))
#let cshape(pts, fillc, line, w: 2.6) = (nib.mp-fill(CP(pts, cycle: true), fill: fillc), nib.draw(CP(pts, cycle: true), pen: cpen(w), fill: line))
#let cpoly(pts, fillc, line, w: 2.6) = (nib.mp-fill(CL(pts), fill: fillc), nib.draw(CL(pts), pen: cpen(w), fill: line))
#let cstroke(pts, w, col) = nib.draw(CP(pts), pen: cpen(w), fill: col)
#let ctube(pts, w, col, line) = (
  ..nib.stroke-items(CP(pts), pen: nib.nibpen((at: 0%, width: u(w + 4), thinness: 100%), (at: 100%, width: u(w + 3), thinness: 100%)), fill: line, refine: 4),
  ..nib.stroke-items(CP(pts), pen: nib.nibpen((at: 0%, width: u(w), thinness: 100%), (at: 100%, width: u(w - 2), thinness: 100%)), fill: col, refine: 4))
#let cell(cx, cy, rx, ry, fillc, line: none, w: 2.4, n: 16) = {
  let p = range(n).map(i => { let t = i / n * 2 * calc.pi; (cx + rx * calc.cos(t), cy + ry * calc.sin(t)) })
  (nib.mp-fill(CP(p, cycle: true), fill: fillc), ..if line != none { (nib.draw(CP(p, cycle: true), pen: cpen(w), fill: line),) })
}
#let cheart(cx, cy, r, n: 36) = range(n).map(i => {
  let t = i / n * 2 * calc.pi
  let x = 16 * calc.pow(calc.sin(t), 3)
  let y = 13 * calc.cos(t) - 5 * calc.cos(2 * t) - 2 * calc.cos(3 * t) - calc.cos(4 * t)
  (cx + x * r / 17, cy - y * r / 17)
})
#let cflower(x, y) = (..range(5).map(k => nib.mp-dot(px(..T(polar(x, y, 6, k * 2 * calc.pi / 5 + x))), pen: cpen(7), fill: cpurple-lt)), nib.mp-dot(px(..T((x, y))), pen: cpen(3.6), fill: cpurple))
#let paw(x, y) = (
  ..cell(x, y, 19, 23, cw, line: ccream), ..cell(x, y + 4, 10, 8, cpink),
  ..((x - 11, y - 8), (x, y - 14), (x + 11, y - 8)).map(p => nib.mp-dot(px(..T(p)), pen: cpen(6), fill: cpink)))
#let hero = (
  // ombre portée douce sur la serviette
  ..cell(14, 130, 78, 160, rgb("#9a9a90").transparentize(82%)),
  // queue orange
  ..nib.stroke-items(CP(((-34, 192), (-80, 218), (-108, 196), (-104, 160))), pen: nib.nibpen((at: 0%, width: u(22), thinness: 100%), (at: 100%, width: u(13), thinness: 100%)), fill: co, refine: 4),
  nib.mp-dot(px(..T((-104, 160))), pen: cpen(14), fill: cw),
  // jambes + pattes (plantes roses vers nous)
  ..ctube(((-18, 150), (-30, 200), (-31, 250)), 30, cw, ccream), ..ctube(((18, 150), (28, 198), (31, 248)), 30, cw, ccream),
  ..paw(-31, 264), ..paw(32, 262),
  // torse + short à fleurs
  ..cshape(((-38, 50), (0, 40), (40, 50), (46, 110), (38, 160), (0, 170), (-38, 160), (-46, 110)), cw, ccream),
  ..cshape(((-42, 126), (0, 118), (44, 126), (51, 168), (34, 206), (0, 192), (-34, 206), (-51, 168)), cpurple, cpurple-dk, w: 3),
  ..cflower(-24, 148), ..cflower(22, 140), ..cflower(28, 174), ..cflower(-6, 172), ..cflower(-30, 186),
  cstroke(((-8, 146), (2, 152), (12, 148)), 2.4, cpurple-dk),
  // bras le long du corps
  ..ctube(((-36, 62), (-62, 100), (-66, 148)), 22, cw, ccream), ..ctube(((36, 62), (64, 104), (66, 146)), 22, cw, ccream),
  ..cell(-66, 156, 13, 12, cw, line: ccream), ..cell(66, 154, 13, 12, cw, line: ccream),
  // oreilles puis tête
  ..cpoly(((-46, -14), (-44, -66), (-8, -38)), co, cod), ..cpoly(((46, -14), (44, -66), (8, -38)), cw, ccream),
  cstroke(((-34, -56), (-31, -42)), 2.2, cink), cstroke(((-26, -52), (-24, -40)), 2.2, cink), cstroke(((34, -56), (31, -42)), 2.2, cink), cstroke(((26, -52), (24, -40)), 2.2, cink),
  ..cshape(((-52, -2), (-46, -32), (0, -46), (46, -32), (54, -2), (42, 32), (0, 46), (-42, 32)), cw, ccream),
  ..cshape(((-46, -18), (-38, -34), (-6, -42), (10, -30), (-8, -16), (-30, -8)), co, co, w: 1.2),
  // museau, moustaches
  ..cell(2, 25, 6, 4, rgb("#e88a8a")),
  cstroke(((-12, 30), (-4, 36), (2, 31), (8, 36), (16, 30)), 2.2, cink),
  ..(((-46, 16), (-68, 10)), ((-46, 25), (-70, 27)), ((48, 16), (70, 10)), ((48, 25), (72, 27))).map(p => cstroke(p, 2, cink)),
  // lunettes cœur
  ..{
    let lh = cheart(-24, -4, 27); let rh = cheart(27, -4, 27)
    let fr(h) = (nib.mp-fill(CP(h, cycle: true), fill: cpink), nib.draw(CP(h, cycle: true), pen: cpen(2.6), fill: rgb("#d44b8a")))
    let inn(cx, cy) = nib.mp-fill(CP(cheart(cx, cy, 19), cycle: true), fill: rgb("#2b1838"))
    (..fr(lh), inn(-24, -3), cstroke(((-32, -16), (-35, 8)), 3.4, rgb("#f4e6f4")), cstroke(((-18, -16), (-21, 8)), 3.4, rgb("#f4e6f4")),
     ..fr(rh), inn(27, -3), cstroke(((19, -16), (16, 8)), 3.4, rgb("#f4e6f4")), cstroke(((33, -16), (30, 8)), 3.4, rgb("#f4e6f4")),
     cstroke(((-2, -6), (4, -6)), 4, cpink))
  },
)

// ── point A, lettre A, flèche double « 6 m »
#let dot-A = nib.mp-dot(px(636, 566), pen: nib.pencircle(u(38)), fill: rgb("#ee4330"))
#let letter-A = nib.mp-label(text(size: u(138), style: "italic", weight: "medium", fill: ink)[A], px(640, 488))
#let (pa, pb) = ((286, 800), (614, 586))
#let ang = calc.atan2(pb.at(0) - pa.at(0), -(pb.at(1) - pa.at(1)))   // screen y is down → flip for maths angle
#let head(tip, dir) = (-0.55, 0.55).map(d => { let a = dir + d * 1rad; nib.draw(PP((tip, (tip.at(0) - 34 * calc.cos(a), tip.at(1) + 34 * calc.sin(a)), (tip.at(0) - 66 * calc.cos(a), tip.at(1) + 66 * calc.sin(a)))), pen: nib.pencircle(u(9.5)), fill: ink) })
#let arrow = (
  ..nib.stroke-items(PP((pa, (450, 692), pb)), pen: nib.nibpen((at: 0%, width: u(5), thinness: 100%), (at: 50%, width: u(14), thinness: 100%), (at: 100%, width: u(5), thinness: 100%)), fill: ink, refine: 4),
  ..head(pb, ang), ..head(pa, ang + 180deg),
)
#let label-6m = nib.mp-label(rotate(-33deg, text(size: u(118), style: "italic", fill: ink)[6 m]), px(440, 622))

#nib.mp-fig(
  nib.draw(sea-blob, pen: nib.pencircle(u(10)), fill: sea2), nib.mp-fill(sea-blob, fill: sea),
  ..waves,
  nib.draw(disc, pen: nib.pencircle(u(40)), fill: lagoon), nib.draw(disc, pen: nib.pencircle(u(24)), fill: rim), nib.mp-fill(disc, fill: sand),
  glow, ..specks, ..starfish, ..towel, ..hero, dot-A, letter-A, ..arrow, label-6m,
  width: W * s * 1pt, height: H * s * 1pt, origin: (0pt, 0pt), clip: true)
