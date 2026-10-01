// Reproduction avec nib de la figure « 1am-2425-dm2-fig01 » (île, serviette, point A, flèche « 6 m »).
// Les coordonnées sont celles de l'image de référence (pixels, y vers le bas) ; `px` convertit en points y-haut.
//   typst compile --root . examples/ile.typ
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

// ── personnage allongé (vu de dessus, d'après le détail de la référence)
#let outl = nib.broadnib(u(4), t: u(2.4), angle: 40deg)
#let tap3(pts, w0, wm, w1, col) = nib.stroke-items(PP(pts), pen: nib.nibpen((at: 0%, width: u(w0), thinness: 100%), (at: 55%, width: u(wm), thinness: 100%), (at: 100%, width: u(w1), thinness: 100%)), fill: col, refine: 4)
#let blob(pts, fillc, line, tension: 1) = (nib.mp-fill(PP(pts, cycle: true, tension: tension), fill: fillc), nib.draw(PP(pts, cycle: true, tension: tension), pen: outl, fill: line))
#let poly(pts, fillc, line) = (nib.mp-fill(PL(pts, cycle: true), fill: fillc), nib.draw(PL(pts, cycle: true), pen: nib.pencircle(u(3.2)), fill: line))
#let hero = (
  // pantalon bleu (ellipse allongée) + ombre, bottes
  ..blob(((790, 600), (828, 604), (832, 652), (804, 708), (758, 700), (750, 650)), rgb("#3b50b2"), rgb("#26357f")),
  ..blob(((800, 650), (832, 656), (804, 708), (770, 702)), rgb("#2c3d98"), rgb("#2c3d98")),
  nib.draw(PP(((786, 614), (776, 646), (782, 680))), pen: nib.pencircle(u(5)), fill: rgb("#5a70d0").transparentize(35%)),
  ..blob(((776, 702), (792, 714), (770, 752), (738, 792), (722, 776), (744, 738)), rgb("#3b302d"), rgb("#1c1614"), tension: 1.3),
  nib.draw(PP(((728, 772), (744, 762), (756, 744))), pen: nib.pencircle(u(4)), fill: rgb("#6b5a54")),
  // manches noires (pointues à l'épaule)
  ..tap3(((806, 572), (762, 597), (724, 632), (692, 664)), 6, 26, 22, ink),
  ..tap3(((832, 580), (846, 640), (862, 700), (876, 742)), 8, 24, 22, ink),
  nib.mp-dot(px(876, 722), pen: nib.penellipse(u(14), u(28), angle: 78deg), fill: rgb("#f3c640")), nib.mp-dot(px(702, 668), pen: nib.pencircle(u(12)), fill: rgb("#4a4a4a")),
  // foulard jaune, mains
  ..poly(((784, 548), (832, 538), (878, 570), (902, 592), (852, 600), (800, 584)), rgb("#f3c640"), rgb("#b9801a")),
  ..tap3(((804, 522), (796, 502), (808, 486)), 10, 16, 8, rgb("#f0a25a")),
  ..tap3(((896, 550), (926, 554), (954, 564)), 12, 22, 12, rgb("#f0a25a")), ..blob(((940, 562), (960, 566), (962, 584), (944, 586)), rgb("#fde6cc"), rgb("#c98a5a")),
  // visage (sous les cheveux)
  ..blob(((804, 516), (812, 490), (842, 480), (872, 498), (874, 530), (846, 548), (816, 542)), rgb("#fde6cc"), rgb("#c98a5a")),
  nib.mp-dot(px(820, 538), pen: nib.penellipse(u(16), u(9), angle: 20deg), fill: rgb("#f7b489").transparentize(40%)),
  nib.mp-dot(px(836, 514), pen: nib.penellipse(u(9), u(18), angle: 95deg), fill: rgb("#2a1f52")), nib.mp-dot(px(834, 509), pen: nib.pencircle(u(3.2)), fill: white),
  nib.draw(PP(((818, 536), (828, 541), (838, 537))), pen: nib.pencircle(u(2.8)), fill: rgb("#c4582e")),
  // cheveux : grosse masse cyan qui recouvre le côté droit du visage, pointes
  
  ..poly(((864, 500), (860, 472), (876, 460), (880, 440), (896, 454), (914, 446), (928, 460), (946, 470), (938, 486), (960, 494), (940, 508), (936, 526), (912, 540), (884, 536), (868, 520)), rgb("#3f9fdc"), rgb("#2a5fa8")),
  nib.draw(PP(((876, 460), (908, 456), (930, 476))), pen: nib.broadnib(u(6), t: u(2.6), angle: 40deg), fill: rgb("#8fd6f2")),
  nib.draw(PP(((880, 516), (900, 524), (920, 514))), pen: nib.broadnib(u(5), t: u(2), angle: 40deg), fill: rgb("#3474b8")),
  // mèches violettes sur le front
  ..poly(((808, 496), (812, 466), (830, 454), (842, 466), (856, 456), (868, 476), (866, 496), (846, 488), (826, 502)), rgb("#4f3fa6"), rgb("#2c2468")),
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
