#import "_h.typ": *

== #T("Cutting and editing", "Découper et modifier")

#T[
These functions return *new* paths (paths are immutable). Those that cut a path into pieces return an array of paths.
][
Ces fonctions renvoient de *nouveaux* chemins (les chemins sont immuables). Celles qui découpent un chemin en morceaux renvoient un tableau de chemins.
]

#api("subpath", "subpath(p, t0, t1)",
  T[Part of the path between times `t0` and `t1` (`subpath (t0, t1) of p`). If `t1 < t0` the part is traversed backwards. On a cyclic path the part may wrap around the start; negative times are allowed.][Portion du chemin entre les temps `t0` et `t1` (`subpath (t0, t1) of p`). Si `t1 < t0`, la portion est parcourue à rebours. Sur un chemin cyclique, elle peut passer par le départ ; les temps négatifs sont permis.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("t0", "number", none, [Start time.], [Temps de départ.]),
    P("t1", "number", none, [End time.], [Temps d'arrivée.]),
  ),
  ret: T[an open path.][un chemin ouvert.],
  ex: ```
let p = mp-path("(0,0)..(30,40)..(60,0)..(90,40)..(120,0)")
mp-fig(
  draw(p, pen: pencircle(1pt), fill: gray),
  // from the middle of segment 1 to the node 3
  // du milieu du segment 1 au nœud 3
  draw(subpath(p, 0.5, 3), pen: pencircle(4pt),
    fill: rgb("#1a4f8b").transparentize(30%)),
  pad: 5pt)
```)

#api("reverse", "reverse(p)",
  T[The same path traversed in the opposite direction.][Le même chemin parcouru dans l'autre sens.],
  params: ( P("p", "path", none, [Path.], [Chemin.]), ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0){up}..(40,40)..(80,0)")
// both are drawn with a pen that thickens along the path
// les deux sont tracés avec une plume qui épaissit le long du chemin
let pen = nibpen((at: 0%, width: 2pt), (at: 100%, width: 10pt))
let r = shifted(reverse(p), 0pt, -14pt)
mp-fig(
  ..stroke-items(p, pen: pen, fill: blue),
  ..stroke-items(r, pen: pen, fill: red),
  pad: 4pt)
```)

#api("shorten", "shorten(p, start: 0pt, end: 0pt)",
  T[Removes a length from the beginning and/or the end of an open path (e.g. to stop a line before an arrowhead).][Retire une longueur au début et/ou à la fin d'un chemin ouvert (par exemple pour arrêter une ligne avant une pointe de flèche).],
  params: (
    P("p", "path", none, [Open path.], [Chemin ouvert.]),
    P("start", "length", "0pt", [Arc length removed at the start.], [Longueur d'arc retirée au début.]),
    P("end", "length", "0pt", [Arc length removed at the end.], [Longueur d'arc retirée à la fin.]),
  ),
  ret: T[a path (error if nothing is left).][un chemin (erreur s'il ne reste rien).],
  ex: ```
let p = mp-path("(0,0)..(50,40)..(100,0)")
mp-fig(
  draw(p, pen: pencircle(1pt), fill: gray),
  draw(shorten(p, start: 15pt, end: 30pt),
    pen: pencircle(5pt), fill: rgb("#7a2e0e")),
  pad: 4pt)
```)

#api("split-at", "split-at(p, times)",
  T[Cuts a path at the given times. An open path cut at `n` times gives `n + 1` pieces; a closed path gives `n` pieces (the last one wraps around the start).][Coupe un chemin aux temps donnés. Un chemin ouvert coupé en `n` temps donne `n + 1` morceaux ; un chemin fermé donne `n` morceaux (le dernier passe par le départ).],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("times", "array of numbers", none, [Cutting times.], [Temps de coupe.]),
  ),
  ret: T[an array of paths.][un tableau de chemins.],
  ex: ```
let ring = mp-path("(0,0)..(30,30)..(60,0)..(30,-30)..cycle")
let cols = (red, blue, green)
let parts = split-at(ring, (0.5, 1.5, 3))
mp-fig(
  ..parts.enumerate().map(((i, q)) => draw(
    q, pen: pencircle(4pt), fill: cols.at(i))),
  pad: 4pt)
```)

#api("remove-intervals", "remove-intervals(p, ivs, min-piece: 0.05pt)",
  T[Removes arc-length intervals from a path and returns the remaining pieces. On closed paths the intervals may wrap around the start; the piece that straddles the seam is welded back together. Basis of over/under crossings.][Retire des intervalles d'abscisse curviligne d'un chemin et renvoie les morceaux restants. Sur un chemin fermé, les intervalles peuvent passer par le départ ; le morceau à cheval sur la jointure est ressoudé. Base des croisements dessus/dessous.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("ivs", "array of pairs", none, [Intervals `((a, b), …)` of arc length (lengths).], [Intervalles `((a, b), …)` d'abscisse curviligne (longueurs).]),
    P("min-piece", "length", "0.05pt", [Pieces shorter than this are dropped.], [Les morceaux plus courts sont abandonnés.]),
  ),
  ret: T[an array of paths.][un tableau de chemins.],
  ex: ```
let p = mp-path("(0,0)..(50,40)..(100,0)..(150,40)")
// remove two holes: [30, 45] and [90, 110]
// retire deux trous : [30, 45] et [90, 110]
let pieces = remove-intervals(p,
  ((30pt, 45pt), (90pt, 110pt)))
mp-fig(
  ..pieces.map(q => draw(q, pen: pencircle(4pt),
    fill: rgb("#1a4f8b"))),
  pad: 4pt)
```)

#api("gap-at", "gap-at(p, times, half)",
  T[Opens a gap of half-length `half` (arc length) around each of the given times, and returns the pieces.][Ouvre un trou de demi-longueur `half` (abscisse curviligne) autour de chacun des temps donnés, et renvoie les morceaux.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("times", "array of numbers", none, [Times at which to cut.], [Temps où couper.]),
    P("half", "length or array", none, [Half-length of each gap (one value, or one per time).], [Demi-longueur de chaque trou (une valeur, ou une par temps).]),
  ),
  ret: T[an array of paths.][un tableau de chemins.],
  ex: ```
// two strands crossing: the red one passes under
// deux brins qui se croisent : le rouge passe dessous
let a = mp-path("(0,0)..(40,40)..(80,0)")
let b = mp-path("(0,30)..(40,0)..(80,30)")
let ts = intersection-times(a, b).map(x => x.at(0))
mp-fig(
  draw(b, pen: pencircle(5pt), fill: blue),
  ..gap-at(a, ts, 6pt).map(q =>
    draw(q, pen: pencircle(5pt), fill: red)),
  pad: 4pt)
```)

#api("weld", "weld(paths, tol: 0.05pt)",
  T[Joins consecutive paths of a list whenever the end of one lies within `tol` of the start of the next one.][Raccorde les chemins consécutifs d'une liste dès que la fin de l'un est à moins de `tol` du début du suivant.],
  params: (
    P("paths", "array of paths", none, [Pieces, in order.], [Morceaux, dans l'ordre.]),
    P("tol", "length", "0.05pt", [Distance below which two ends are considered equal.], [Distance en dessous de laquelle deux extrémités sont confondues.]),
  ),
  ret: T[an array of paths (fewer than given if some were welded).][un tableau de chemins (moins nombreux si des soudures ont eu lieu).],
  ex: ```
let p = mp-path("(0,0)..(50,40)..(100,0)")
let (a, b, c) = split-at(p, (0.7, 1.4))
// a-b-c are three pieces; weld puts them back together
// a-b-c sont trois morceaux ; weld les remet bout à bout
let w = weld((a, b, c))
[pieces: 3 → #w.len()]
```)

#api("fit-between", "fit-between(p, a, b)",
  T[Applies to `p` the similarity (rotation + uniform scaling + translation) that maps its start to `a` and its end to `b`. Use it to stretch an ornament between two points.][Applique à `p` la similitude (rotation + échelle uniforme + translation) qui envoie son début sur `a` et sa fin sur `b`. Sert à étirer un ornement entre deux points.],
  params: (
    P("p", "path", none, [Path whose end points differ.], [Chemin dont les extrémités diffèrent.]),
    P("a", "point", none, [Target of the start point.], [Cible du point de départ.]),
    P("b", "point", none, [Target of the end point.], [Cible du point d'arrivée.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
// a wave drawn once, stretched between several point pairs
// une vague dessinée une fois, étirée entre plusieurs paires de points
let wave = mp-path("(0,0)..(10,8)..(20,-8)..(30,0)")
let pairs = (((0pt, 0pt), (60pt, 0pt)), ((0pt, 10pt), (50pt, 40pt)),
  ((0pt, -10pt), (30pt, -40pt)))
mp-fig(
  ..pairs.map(((a, b)) => draw(fit-between(wave, a, b),
    pen: pencircle(1.5pt), fill: rgb("#7a2e0e"))),
  pad: 4pt)
```)

#api("offset", "offset(p, d, tol: 0.02pt)",
  T[Parallel curve at signed distance `d` from the path (positive = to the *left* of the direction of travel). Pieces are joined by straight bevels; on a closed path the result is closed.][Courbe parallèle à la distance signée `d` du chemin (positive = à *gauche* du sens de parcours). Les morceaux sont raccordés par des biseaux droits ; sur un chemin fermé le résultat est fermé.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("d", "length", none, [Signed distance.], [Distance signée.]),
    P("tol", "length", "0.02pt", [Approximation accuracy.], [Précision de l'approximation.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path-pts(((0pt, 0pt), (20pt, 12pt), (44pt, 2pt),
  (54pt, 26pt), (28pt, 44pt)), cycle: true)
mp-fig(
  ..range(-2, 3).map(k => stroke-items(
    offset(p, k * 4pt), pen: pencircle(0.8pt),
    fill: if k < 0 { green } else if k == 0 { red } else { blue })
  ).flatten(),
  pad: 3pt)
```)

== #T("Transformations", "Transformations")

#T[
Affine maps, as in MetaPost (`shifted`, `scaled`, `rotated`…). They act on the *path* — apply them before drawing. In MetaPost `p scaled 2 shifted (1,1)` reads left to right; here, nest the calls: `shifted(scaled(p, 2), 1pt, 1pt)`.
][
Transformations affines, comme en MetaPost (`shifted`, `scaled`, `rotated`…). Elles agissent sur le *chemin* — à appliquer avant de dessiner. En MetaPost `p scaled 2 shifted (1,1)` se lit de gauche à droite ; ici, imbriquez les appels : `shifted(scaled(p, 2), 1pt, 1pt)`.
]


#api("shifted", "shifted(p, dx, dy)",
  T[Translates the path by `(dx, dy)`.][Translate le chemin de `(dx, dy)`.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("dx", "length", none, [Horizontal shift.], [Décalage horizontal.]),
    P("dy", "length", none, [Vertical shift (y up).], [Décalage vertical (y vers le haut).]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0){up}..(14,30)..(28,0)")
mp-fig(
  ..range(5).map(i => draw(shifted(p, i * 18pt, 0pt),
    pen: pencircle(2pt), fill: red.lighten(i * 14%))),
  pad: 4pt)
```)

#api("scaled", "scaled(p, s)",
  T[Scales the path by the factor `s` about the origin.][Met le chemin à l'échelle `s` autour de l'origine.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("s", "number", none, [Scale factor (negative = point reflection).], [Facteur d'échelle (négatif = symétrie centrale).]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0){up}..(14,30)..(28,0)")
mp-fig(
  ..(0.4, 0.7, 1, 1.5).map(s => draw(scaled(p, s),
    pen: pencircle(1.5pt), fill: blue)),
  pad: 4pt)
```)

#api("xscaled", "xscaled(p, s)",
  T[Scales horizontally only (`x` multiplied by `s`).][Étire horizontalement seulement (`x` multiplié par `s`).],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("s", "number", none, [Horizontal factor.], [Facteur horizontal.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0)..(15,15)..(30,0)..(15,-15)..cycle")
mp-fig(
  draw(p, pen: pencircle(1.5pt), fill: gray),
  draw(shifted(xscaled(p, 2), 80pt, 0pt),
    pen: pencircle(1.5pt), fill: red),
  pad: 4pt)
```)

#api("yscaled", "yscaled(p, s)",
  T[Scales vertically only (`y` multiplied by `s`). A negative factor flips the path upside down.][Étire verticalement seulement (`y` multiplié par `s`). Un facteur négatif retourne le chemin tête en bas.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("s", "number", none, [Vertical factor.], [Facteur vertical.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0){up}..(14,30)..(28,0)")
mp-fig(
  draw(p, pen: pencircle(2pt), fill: gray),
  draw(yscaled(p, -1), pen: pencircle(2pt), fill: red),
  draw(shifted(yscaled(p, 0.4), 40pt, 0pt),
    pen: pencircle(2pt), fill: blue),
  pad: 4pt)
```)

#api("slanted", "slanted(p, s)",
  T[Shear: every point `(x, y)` becomes `(x + s·y, y)`. Handy to slant lettering.][Cisaillement : chaque point `(x, y)` devient `(x + s·y, y)`. Pratique pour pencher une écriture.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("s", "number", none, [Slant (`0.25` ≈ 14°).], [Inclinaison (`0.25` ≈ 14°).]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0)--(0,40)--(25,40)--(25,0)--cycle")
mp-fig(
  ..(0, 0.25, 0.6).enumerate().map(((i, s)) =>
    draw(shifted(slanted(p, s), i * 45pt, 0pt),
      pen: pencircle(2pt), fill: rgb("#1a4f8b"))),
  pad: 4pt)
```)

#api("rotated", "rotated(p, a, about: (0pt, 0pt))",
  T[Rotates the path counter-clockwise by the angle `a` about the point `about`.][Fait tourner le chemin dans le sens anti-horaire de l'angle `a` autour du point `about`.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("a", "angle", none, [Angle (a number is read as degrees).], [Angle (un nombre est lu en degrés).]),
    P("about", "point", "(0pt, 0pt)", [Centre of rotation.], [Centre de rotation.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(10,0){up}..(24,30)..(38,0)")
// seven copies around the origin
// sept copies autour de l'origine
mp-fig(
  ..range(7).map(i => draw(rotated(p, i * 51.4deg),
    pen: broadnib(5pt, t: 1pt, angle: 30deg),
    fill: rgb("#7a2e0e").lighten(i * 9%))),
  pad: 3pt)
```)

#api("reflected", "reflected(p, angle: 90deg)",
  T[Mirror image about the line through the origin whose direction is `angle` (`90deg` = vertical axis: left ↔ right; `0deg` = horizontal axis).][Symétrique par rapport à la droite passant par l'origine de direction `angle` (`90deg` = axe vertical : gauche ↔ droite ; `0deg` = axe horizontal).],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("angle", "angle", "90deg", [Direction of the mirror line.], [Direction de l'axe du miroir.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(4,0){up}..(24,24)..(44,10)")
let pen = pencircle(2.5pt)
mp-fig(
  draw(p, pen: pen, fill: blue),
  draw(reflected(p), pen: pen, fill: red),
  draw(reflected(p, angle: 0deg), pen: pen, fill: green),
  draw(reflected(p, angle: 45deg), pen: pen, fill: orange),
  pad: 4pt)
```)

#api("transformed", "transformed(p, a, b, c, d, e: 0pt, f: 0pt)",
  T[General affine map: `(x, y) ↦ (a·x + c·y + e, b·x + d·y + f)`. All the other transformations are special cases (`rotated` is `a = d = cos θ`, `b = sin θ`, `c = −sin θ`).][Transformation affine générale : `(x, y) ↦ (a·x + c·y + e, b·x + d·y + f)`. Toutes les autres transformations en sont des cas particuliers (`rotated` : `a = d = cos θ`, `b = sin θ`, `c = −sin θ`).],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("a, b, c, d", "number", none, [Coefficients of the 2×2 matrix.], [Coefficients de la matrice 2×2.]),
    P("e", "length", "0pt", [Horizontal translation.], [Translation horizontale.]),
    P("f", "length", "0pt", [Vertical translation.], [Translation verticale.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let sq = mp-path("(0,0)--(30,0)--(30,30)--(0,30)--cycle")
// a unit square sheared and stretched into a parallelogram
// un carré cisaillé et étiré en parallélogramme
let para = transformed(sq, 1.5, 0, 0.7, 0.8, e: 10pt, f: 0pt)
mp-fig(
  draw(sq, pen: pencircle(1.5pt), fill: gray),
  draw(para, pen: pencircle(1.5pt), fill: red),
  pad: 4pt)
```)
