#import "_h.typ": *

== #T("Measuring and querying", "Mesurer et interroger")

#T[
Paths are parametrised by *time*: a path of `n` segments has times from `0` to `n`; time `2.5` is the middle of the third segment (as in MetaPost's `point 2.5 of p`). Functions that return positions give Typst lengths; angles are Typst angles.
][
Les chemins sont paramétrés par le *temps* : un chemin de `n` segments a des temps de `0` à `n` ; le temps `2.5` est le milieu du troisième segment (comme `point 2.5 of p` en MetaPost). Les positions renvoyées sont des longueurs Typst, les angles des angles Typst.
]

#api("path-length", "path-length(p)",
  T[Number of Bézier segments of the path, i.e. its maximal time. (For the geometric length use `arclength`.)][Nombre de segments de Bézier du chemin, c'est-à-dire son temps maximal. (Pour la longueur géométrique, voir `arclength`.)],
  params: ( P("p", "path", none, [Any path.], [Un chemin quelconque.]), ),
  ret: T[an integer.][un entier.],
  ex: ```
let p = mp-path("(0,0)..(30,30)..(60,0)..(90,30)")
let q = mp-path("(0,0)..(30,30)..(60,0)..cycle")
[open: #path-length(p) segments \
 closed: #path-length(q) segments]
```)

#api("arclength", "arclength(p)",
  T[Total arc length of the path.][Longueur d'arc totale du chemin.],
  params: ( P("p", "path", none, [Any path.], [Un chemin quelconque.]), ),
  ret: T[a length.][une longueur.],
  ex: ```
let half = mp-path("(0,0){right}..(40,40){left}")
let full = mp-path("(0,0)..(40,40)..(0,80)..(-40,40)..cycle")
[arc: #calc.round(arclength(half).pt(), digits: 2) pt \
 loop: #calc.round(arclength(full).pt(), digits: 2) pt]
```)

#api("arctime", "arctime(p, len)",
  T[Time at which the path has covered the arc length `len` (MetaPost's `arctime len of p`). The result can then be given to `point-of`, `subpath`…][Temps auquel le chemin a parcouru la longueur d'arc `len` (`arctime len of p` de MetaPost). Le résultat peut être donné à `point-of`, `subpath`…],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("len", "length", none, [Distance travelled along the path.], [Distance parcourue le long du chemin.]),
  ),
  ret: T[a number (time).][un nombre (temps).],
  ex: ```
let p = mp-path("(0,0){up}..(40,50)..(80,0)..(120,50)")
let L = arclength(p)
// points every quarter of the length
// points à chaque quart de la longueur
let marks = (0, 0.25, 0.5, 0.75, 1).map(f =>
  point-of(p, arctime(p, L * f)))
mp-fig(
  draw(p, pen: pencircle(1pt), fill: gray),
  ..marks.map(m => mp-dot(m, pen: pencircle(5pt), fill: red)),
  pad: 4pt)
```)

#api("point-of", "point-of(p, t)",
  T[Point of the path at time `t` (`point t of p`). On a cyclic path times wrap around.][Point du chemin au temps `t` (`point t of p`). Sur un chemin cyclique, les temps se prolongent en boucle.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("t", "number", none, [Time: segment index + fraction.], [Temps : indice de segment + fraction.]),
  ),
  ret: T[a point `(x, y)` of lengths.][un point `(x, y)` en longueurs.],
  ex: ```
let p = mp-path("(0,0)..(30,40)..(60,0)..(90,40)..(120,0)")
mp-fig(
  draw(p, pen: pencircle(1pt), fill: gray),
  // integer times = the nodes; halves = mid-segments
  // temps entiers = les nœuds ; demis = milieux
  ..range(9).map(i => mp-dot(point-of(p, i / 2),
      pen: pencircle(if calc.even(i) { 5pt } else { 3pt }),
      fill: if calc.even(i) { red } else { blue })),
  pad: 4pt)
```)

#api("direction-of", "direction-of(p, t)",
  T[Tangent vector of the path at time `t` (not normalised; components in pt).][Vecteur tangent du chemin au temps `t` (non normalisé ; composantes en pt).],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("t", "number", none, [Time.], [Temps.]),
  ),
  ret: T[an array `(dx, dy)` of numbers.][un tableau `(dx, dy)` de nombres.],
  ex: ```
let p = mp-path("(0,0)..(40,40)..(80,0)")
let d = direction-of(p, 1)
let at = point-of(p, 1)
// draw the tangent at the top, scaled to a fixed length
// trace la tangente au sommet, à longueur fixe
let n = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
let e = (at.at(0) + d.at(0) / n * 25pt, at.at(1) + d.at(1) / n * 25pt)
mp-fig(
  draw(p, pen: pencircle(1.4pt), fill: gray),
  draw(straight(at, e), pen: pencircle(1pt), fill: red),
  pad: 4pt)
```)

#api("direction-angle", "direction-angle(p, t)",
  T[Angle of the tangent at time `t`, counter-clockwise from the x axis.][Angle de la tangente au temps `t`, anti-horaire depuis l'axe x.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("t", "number", none, [Time.], [Temps.]),
  ),
  ret: T[an angle.][un angle.],
  ex: ```
let p = mp-path("(0,0){up}..(40,40){right}..(80,0){down}")
let ang(t) = [#calc.round(direction-angle(p, t).deg())°]
mp-fig(
  draw(p, pen: pencircle(1.2pt), fill: gray),
  mp-label(ang(0), (-6pt, 20pt), align: right),
  mp-label(ang(1), (40pt, 48pt), align: bottom),
  mp-label(ang(2), (86pt, 20pt), align: left),
  pad: 14pt)
```)

#api("path-bbox", "path-bbox(p)",
  T[Bounding box of the path (of the curve itself, not of any pen).][Boîte englobante du chemin (de la courbe elle-même, pas d'une plume).],
  params: ( P("p", "path", none, [Path.], [Chemin.]), ),
  ret: T[a dictionary `(x0:, y0:, x1:, y1:)` of lengths.][un dictionnaire `(x0:, y0:, x1:, y1:)` de longueurs.],
  ex: ```
let p = mp-path("(0,0)..(30,50)..(70,10)..(90,40)")
let b = path-bbox(p)
// rectangle drawn from the box
// rectangle tracé d'après la boîte
let r = polyline(((b.x0, b.y0), (b.x1, b.y0),
  (b.x1, b.y1), (b.x0, b.y1)), cycle: true)
mp-fig(
  mp-skeleton(r, stroke: 0.6pt + red),
  draw(p, pen: pencircle(2pt), fill: rgb("#1a4f8b")),
  pad: 4pt)
```)

#api("closest-time", "closest-time(p, pos)",
  T[Time of the point of the path nearest to `pos`, and the distance to it.][Temps du point du chemin le plus proche de `pos`, et distance à ce point.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("pos", "point", none, [Reference point `(x, y)`.], [Point de référence `(x, y)`.]),
  ),
  ret: T[an array `(t, distance)`.][un tableau `(t, distance)`.],
  ex: ```
let p = mp-path("(0,0)..(40,40)..(80,0)")
let q = (30pt, 10pt)
let (t, d) = closest-time(p, q)
mp-fig(
  draw(p, pen: pencircle(1.5pt), fill: gray),
  mp-dot(q, pen: pencircle(5pt), fill: blue),
  mp-dot(point-of(p, t), pen: pencircle(5pt), fill: red),
  draw(straight(q, point-of(p, t)), pen: pencircle(0.6pt)),
  mp-label(text(7pt)[d = #calc.round(d.pt(), digits: 1)], (60pt, 30pt)),
  pad: 4pt)
```)

#api("intersection-times", "intersection-times(a, b)",
  T[All crossings of two paths, as pairs of times `(ta, tb)` sorted by `ta` (`intersectiontimes` of MetaPost, but returning *every* crossing).][Tous les croisements de deux chemins, sous forme de couples de temps `(ta, tb)` triés par `ta` (`intersectiontimes` de MetaPost, mais renvoyant *tous* les croisements).],
  params: (
    P("a", "path", none, [First path.], [Premier chemin.]),
    P("b", "path", none, [Second path.], [Second chemin.]),
  ),
  ret: T[an array of `(ta, tb)` pairs (empty if none).][un tableau de couples `(ta, tb)` (vide s'il n'y en a pas).],
  ex: ```
let a = mp-path("(0,0)..(40,50)..(80,0)..(120,50)")
let b = mp-path("(0,25)--(120,25)")
let xs = intersection-times(a, b)
mp-fig(
  draw(a, pen: pencircle(1.5pt), fill: blue),
  draw(b, pen: pencircle(1pt), fill: gray),
  ..xs.map(x => mp-dot(point-of(a, x.at(0)),
      pen: pencircle(6pt), fill: red)),
  mp-label(text(7pt)[#xs.len() crossings], (60pt, 60pt)),
  pad: 6pt)
```)

#api("intersection-point", "intersection-point(a, b)",
  T[The first crossing point of two paths (smallest time on `a`), or `none`.][Le premier point de croisement de deux chemins (plus petit temps sur `a`), ou `none`.],
  params: (
    P("a", "path", none, [First path.], [Premier chemin.]),
    P("b", "path", none, [Second path.], [Second chemin.]),
  ),
  ret: T[a point, or `none`.][un point, ou `none`.],
  ex: ```
let a = mp-path("(0,0)..(40,50)..(80,0)")
let b = mp-path("(0,35)--(80,15)")
let x = intersection-point(a, b)
mp-fig(
  draw(a, pen: pencircle(2pt)),
  draw(b, pen: pencircle(1pt), fill: blue),
  mp-dot(x, pen: pencircle(6pt), fill: red),
  pad: 5pt)
```)

#api("self-intersections", "self-intersections(p)",
  T[Self-crossings of a path: pairs of times `(t1, t2)` with `t1 < t2` at which the path passes through the same point.][Auto-croisements d'un chemin : couples de temps `(t1, t2)` avec `t1 < t2` où le chemin repasse par un même point.],
  params: ( P("p", "path", none, [Path.], [Chemin.]), ),
  ret: T[an array of time pairs.][un tableau de couples de temps.],
  ex: ```
// a figure-eight loop § une boucle en huit
let p = mp-path("(0,0)..(30,30)..(60,0)..(30,-30)..(0,0)..(-30,30)..(-60,0)..(-30,-30)..cycle")
let xs = self-intersections(p)
mp-fig(
  draw(p, pen: pencircle(1.5pt), fill: gray),
  ..xs.map(x => mp-dot(point-of(p, x.at(0)),
      pen: pencircle(5pt), fill: red)),
  pad: 5pt)
```)

#api("frame-at", "frame-at(p, t)",
  T[Local frame of the path at time `t`: position and tangent direction. Give it to `in-frame` to place a drawing along the path.][Repère local du chemin au temps `t` : position et direction de la tangente. À donner à `in-frame` pour placer un dessin le long du chemin.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("t", "number", none, [Time.], [Temps.]),
  ),
  ret: T[a dictionary `(pos: (x, y), angle: angle)`.][un dictionnaire `(pos: (x, y), angle: angle)`.],
  ex: ```
let p = mp-path("(0,0)..(40,40)..(80,0)")
let f = frame-at(p, 1)
[position: (#calc.round(f.pos.at(0).pt()), #calc.round(f.pos.at(1).pt())) pt \
 angle: #calc.round(f.angle.deg())°]
```)

#api("in-frame", "in-frame(q, fr, scale: 1)",
  T[Places a path `q`, drawn in a *local* frame (x along the tangent, y to the left), into the frame `fr` returned by `frame-at`. Ideal for arrowheads, beads, thorns, hatching.][Place un chemin `q`, dessiné dans un repère *local* (x le long de la tangente, y à gauche), dans le repère `fr` renvoyé par `frame-at`. Idéal pour des pointes de flèche, des perles, des épines, des hachures.],
  params: (
    P("q", "path", none, [Path in local coordinates.], [Chemin en coordonnées locales.]),
    P("fr", "dictionary", none, [Frame from `frame-at` or `frames-along`.], [Repère issu de `frame-at` ou `frames-along`.]),
    P("scale", "number", "1", [Uniform scale applied before placing.], [Échelle uniforme appliquée avant la mise en place.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let p = mp-path("(0,0){up}..(50,40)..(100,0)")
// an arrowhead drawn pointing along +x
// une pointe de flèche dessinée vers +x
let head = polyline(((-8pt, 5pt), (0pt, 0pt), (-8pt, -5pt)))
let end = frame-at(p, path-length(p))
mp-fig(
  draw(p, pen: pencircle(1.4pt), fill: gray),
  draw(in-frame(head, end), pen: pencircle(1.4pt), fill: red),
  draw(in-frame(head, frame-at(p, 1), scale: 0.6),
    pen: pencircle(1.4pt), fill: blue),
  pad: 5pt)
```)

#api("frames-along", "frames-along(p, count: none, step: none, start: 0pt, end: 0pt)",
  T[Regularly spaced frames along a path (by arc length): `count` of them, evenly distributed (on a closed path, evenly around the loop), or one every `step`. Optional margins `start` and `end` are removed from the ends.][Repères régulièrement espacés le long d'un chemin (en abscisse curviligne) : `count` repères répartis uniformément (sur un chemin fermé, uniformément autour de la boucle), ou un tous les `step`. Les marges optionnelles `start` et `end` sont retirées aux extrémités.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("count", "integer or none", "none", [Number of frames.], [Nombre de repères.]),
    P("step", "length or none", "none", [Distance between frames (alternative to `count`).], [Distance entre repères (alternative à `count`).]),
    P("start", "length", "0pt", [Arc length skipped at the start.], [Longueur d'arc ignorée au début.]),
    P("end", "length", "0pt", [Arc length skipped at the end.], [Longueur d'arc ignorée à la fin.]),
  ),
  ret: T[an array of frames `(pos:, angle:)`.][un tableau de repères `(pos:, angle:)`.],
  ex: ```
let ring = mp-path("(0,0)..(30,30)..(60,0)..(30,-30)..cycle")
// 12 petals around a closed path, pointing outwards
// 12 pétales autour d'un chemin fermé, vers l'extérieur
let petal = mp-path("(0,0)..(8,3)..(16,0)..(8,-3)..cycle")
mp-fig(
  draw(ring, pen: pencircle(0.8pt), fill: gray),
  ..frames-along(ring, count: 12).map(f =>
    mp-fill(in-frame(petal, f), fill: rgb("#9a3324"))),
  pad: 4pt)
```)
