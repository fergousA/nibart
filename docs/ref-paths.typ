#import "_h.typ": *

== #T("Building paths", "Construire des chemins")

#T[
A *path* is an opaque value: a list of cubic Bézier segments, open or cyclic. Every function below returns one. Coordinates are Typst lengths (plain numbers mean pt); *y points up*.
][
Un *chemin* est une valeur opaque : une liste de segments de Bézier cubiques, ouverte ou cyclique. Chaque fonction ci-dessous en renvoie un. Les coordonnées sont des longueurs Typst (un nombre seul vaut des pt) ; *y est orienté vers le haut*.
]

#api("mp-path", "mp-path(spec, unit: 1pt)",
  T[Parses a path written in the MetaPost language and computes the smooth curve with Hobby's algorithm. Supported syntax: points `(x,y)`; joins `..` (Hobby curve), `...` (treated as `..`) and `--` (straight line); direction specifiers `{up}`, `{down}`, `{left}`, `{right}`, `{dir 45}`, `{x,y}`, `{curl 2}`; `tension a` and `tension a and b`; `controls P` and `controls P and Q`; `cycle` to close the path.][Analyse un chemin écrit dans le langage MetaPost et calcule la courbe lisse par l'algorithme de Hobby. Syntaxe prise en charge : points `(x,y)` ; liaisons `..` (courbe de Hobby), `...` (traité comme `..`) et `--` (droite) ; directions `{up}`, `{down}`, `{left}`, `{right}`, `{dir 45}`, `{x,y}`, `{curl 2}` ; `tension a` et `tension a and b` ; `controls P` et `controls P and Q` ; `cycle` pour fermer le chemin.],
  params: (
    P("spec", "string", none, [The path specification.], [La spécification du chemin.]),
    P("unit", "length", "1pt", [Unit that multiplies every plain number of `spec`.], [Unité par laquelle sont multipliés tous les nombres de `spec`.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
// four specifications, drawn as skeletons § quatre spécifications, tracées en squelette
let a = mp-path("(0,0)..(30,30)..(60,0)")                  // plain Hobby curve § courbe de Hobby simple
// imposed direction + tension  § direction imposée + tension
let b = mp-path("(0,-10){right}..tension 2..(60,-10)")
// explicit Bézier controls  § contrôles de Bézier explicites
let c = mp-path("(0,-20)..controls (20,-40) and (40,0)..(60,-20)")
let d = mp-path("(75,0)..(105,0)..(90,-25)..cycle")        // closed path § chemin fermé
// numbers are multiplied by `unit`  § nombres multipliés par `unit`
let e = mp-path("(0,0)..(3,2)..(6,0)", unit: 5pt)
mp-fig(
  mp-skeleton(a, stroke: 0.7pt + blue),
  mp-skeleton(b, stroke: 0.7pt + red),
  mp-skeleton(c, stroke: 0.7pt + green),
  mp-skeleton(d, stroke: 0.7pt + purple),
  mp-skeleton(shifted(e, 0pt, -40pt), stroke: 0.7pt + orange),
  pad: 4pt)
```)

#api("mp-path-pts", "mp-path-pts(pts, cycle: false, tension: 1, curl: none)",
  T[Smooth (Hobby) path through a list of points. Handy when the points are computed in a loop and you do not want to build a specification string.][Chemin lisse (Hobby) passant par une liste de points. Pratique quand les points sont calculés dans une boucle et qu'on ne veut pas fabriquer de chaîne de spécification.],
  params: (
    P("pts", "array of points", none, [Points `(x, y)`, each coordinate a length.], [Points `(x, y)`, chaque coordonnée étant une longueur.]),
    P("cycle", "bool", "false", [Close the path smoothly.], [Ferme le chemin de façon lisse.]),
    P("tension", "number", "1", [Tension of every join (as in `..tension t..`); larger = tighter curve.], [Tension de chaque liaison (comme `..tension t..`) ; plus grand = courbe plus tendue.]),
    P("curl", "number or none", "none", [Curl at the first point of an open path (`{curl c}`); `0` = flat ends.], [« Curl » au premier point d'un chemin ouvert (`{curl c}`) ; `0` = extrémité plate.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
// ten points of a damped wave § dix points d'une onde amortie
let pts = range(10).map(i =>
  (i * 8pt, 14pt * calc.sin(i * 70deg) * calc.pow(0.9, i)))
// same points, three settings, stacked
// les mêmes points, trois réglages, empilés
let loose = mp-path-pts(pts)
let tight = shifted(mp-path-pts(pts, tension: 3), 0pt, -34pt)
let flat = shifted(mp-path-pts(pts, curl: 0), 0pt, -68pt)
mp-fig(
  draw(loose, pen: pencircle(1.4pt), fill: blue),
  draw(tight, pen: pencircle(1.4pt), fill: red),
  draw(flat, pen: pencircle(1.4pt), fill: green),
  ..pts.map(q => mp-dot(q, pen: pencircle(3pt))),
  pad: 4pt)
```)

#api("cubic", "cubic(a, b, c, d)",
  T[One cubic Bézier segment from `a` to `d` with control points `b` and `c`.][Un segment de Bézier cubique de `a` à `d`, avec les points de contrôle `b` et `c`.],
  params: (
    P("a", "point", none, [Start point `(x, y)`.], [Point de départ `(x, y)`.]),
    P("b", "point", none, [First control point.], [Premier point de contrôle.]),
    P("c", "point", none, [Second control point.], [Second point de contrôle.]),
    P("d", "point", none, [End point.], [Point d'arrivée.]),
  ),
  ret: T[an open path of one segment.][un chemin ouvert d'un segment.],
  ex: ```
let (a, b, c, d) = ((0pt, 0pt), (0pt, 40pt), (50pt, 40pt), (50pt, 0pt))
let p = cubic(a, b, c, d)
mp-fig(
  // control polygon  § polygone de contrôle
  mp-skeleton(polyline((a, b, c, d)), stroke: 0.4pt + gray),
  draw(p, pen: pencircle(3pt), fill: rgb("#7a2e0e")),
  ..(a, b, c, d).map(q => mp-dot(q, pen: pencircle(3.5pt), fill: red)),
  pad: 5pt)
```)

#api("straight", "straight(a, b)",
  T[One straight segment, stored as a degenerate cubic so that it combines freely with curves.][Un segment droit, stocké comme une cubique dégénérée pour se combiner librement avec des courbes.],
  params: (
    P("a", "point", none, [Start point.], [Point de départ.]),
    P("b", "point", none, [End point.], [Point d'arrivée.]),
  ),
  ret: T[an open path of one segment.][un chemin ouvert d'un segment.],
  ex: ```
let s = straight((0pt, 0pt), (60pt, 25pt))
mp-fig(
  draw(s, pen: broadnib(8pt, t: 1.5pt, angle: 20deg), fill: rgb("#1a4f8b")),
  // measured length  § longueur mesurée
  mp-label(text(8pt)[length: #arclength(s)], (30pt, -10pt)),
  pad: 5pt)
```)

#api("polyline", "polyline(pts, cycle: false)",
  T[Polygonal path through the points (straight segments).][Chemin polygonal passant par les points (segments droits).],
  params: (
    P("pts", "array of points", none, [The vertices.], [Les sommets.]),
    P("cycle", "bool", "false", [Close the polygon.], [Ferme le polygone.]),
  ),
  ret: T[a path (one segment per side).][un chemin (un segment par côté).],
  ex: ```
// regular pentagram § pentagramme régulier
let pt(i) = (26pt * calc.cos(90deg + i * 144deg),
             26pt * calc.sin(90deg + i * 144deg))
let star = polyline(range(5).map(pt), cycle: true)
mp-fig(
  draw(star, pen: penrazor(3pt, angle: 45deg), fill: rgb("#9a3324")),
  pad: 4pt)
```)

#api("cubics", "cubics(segments, cycle: false, y-down: false)",
  T[Path from a list of explicit cubic segments `((p0, c1, c2, p3), …)`. The end of each segment is expected to be the start of the next one. With `y-down: true` the coordinates follow Typst's convention (y pointing down): the path is flipped and the pen angles are mirrored, which reproduces drawings written for the `nibst` package.][Chemin à partir d'une liste de segments cubiques explicites `((p0, c1, c2, p3), …)`. La fin de chaque segment doit être le début du suivant. Avec `y-down: true`, les coordonnées suivent la convention Typst (y vers le bas) : le chemin est retourné et les angles de plume sont inversés, ce qui reproduit les dessins écrits pour le paquet `nibst`.],
  params: (
    P("segments", "array", none, [Array of 4-point tuples `(p0, c1, c2, p3)`.], [Tableau de quadruplets `(p0, c1, c2, p3)`.]),
    P("cycle", "bool", "false", [Mark the path as closed.], [Marque le chemin comme fermé.]),
    P("y-down", "bool", "false", [Interpret coordinates with y pointing down.], [Interprète les coordonnées avec y vers le bas.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
// an S made of two cubics § un S fait de deux cubiques
let s = cubics((
  ((0pt, 0pt),  (30pt, 0pt),  (40pt, 20pt), (20pt, 24pt)),
  ((20pt, 24pt), (0pt, 28pt), (10pt, 48pt), (40pt, 48pt)),
))
nib-stroke(s, pad: 4pt, fill: rgb("#2b2b2b"),
  pen: nibpen(width: 7pt, thinness: 25%, angle: 40deg))
```)

#api("path-join", "path-join(a, b)",
  T[Concatenates two open paths (the end of `a` is assumed to be the start of `b`; no check is made).][Concatène deux chemins ouverts (la fin de `a` est supposée être le début de `b` ; aucune vérification).],
  params: (
    P("a", "path", none, [First path.], [Premier chemin.]),
    P("b", "path", none, [Second path.], [Second chemin.]),
  ),
  ret: T[an open path.][un chemin ouvert.],
  ex: ```
let a = mp-path("(0,0)..(20,20)")
let b = mp-path("(20,20)..(40,0)..(60,20)")
mp-fig(
  draw(path-join(a, b), pen: pencircle(3pt), fill: rgb("#1a4f8b")),
  pad: 4pt)
```)

#api("path-join-all", "path-join-all(parts, cycle: false)",
  T[Concatenates a whole list of paths, optionally marking the result as closed.][Concatène toute une liste de chemins, avec fermeture optionnelle du résultat.],
  params: (
    P("parts", "array of paths", none, [Paths to chain, in order.], [Chemins à enchaîner, dans l'ordre.]),
    P("cycle", "bool", "false", [Close the result.], [Ferme le résultat.]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
// a rounded "tombstone": two lines + an arc § une « stèle » : deux droites + un arc
let up = straight((0pt, 0pt), (0pt, 30pt))
let arc = mp-path("(0,30){up}..(20,50){right}..{down}(40,30)")
let down = straight((40pt, 30pt), (40pt, 0pt))
let shape = path-join-all((up, arc, down), cycle: true)
mp-fig(draw(shape, pen: pencircle(2.5pt), fill: rgb("#7a2e0e")), pad: 4pt)
```)

#api("path-close", "path-close(p)",
  T[Marks an open path as cyclic: a straight join from the end to the start is understood.][Marque un chemin ouvert comme cyclique : on sous-entend un segment droit de la fin au début.],
  params: ( P("p", "path", none, [Open path.], [Chemin ouvert.]), ),
  ret: T[a closed path.][un chemin fermé.],
  ex: ```
let open = mp-path("(0,0)..(20,40)..(40,0)")
mp-fig(
  // filled thanks to the implicit closing  § remplissage grâce à la fermeture
  mp-fill(path-close(open), fill: rgb("#e8c9b8")),
  draw(open, pen: pencircle(2pt), fill: rgb("#7a2e0e")),
  pad: 4pt)
```)

#api("round-corners", "round-corners(pts, r: 4pt, cycle: false)",
  T[Polygon whose corners are replaced by circular arcs of radius `r` (reduced automatically where the sides are too short).][Polygone dont les coins sont remplacés par des arcs de cercle de rayon `r` (réduit automatiquement quand les côtés sont trop courts).],
  params: (
    P("pts", "array of points", none, [Polygon vertices.], [Sommets du polygone.]),
    P("r", "length or array", "4pt", [Radius, or one radius per vertex.], [Rayon, ou un rayon par sommet.]),
    P("cycle", "bool", "false", [Closed polygon (all corners rounded) or open (end points kept).], [Polygone fermé (tous les coins arrondis) ou ouvert (extrémités conservées).]),
  ),
  ret: T[a path.][un chemin.],
  ex: ```
let pts = ((0pt, 0pt), (70pt, 0pt), (70pt, 36pt), (35pt, 50pt), (0pt, 36pt))
mp-fig(
  mp-skeleton(polyline(pts, cycle: true), stroke: 0.4pt + gray),
  draw(
    round-corners(pts, r: (2pt, 14pt, 6pt, 6pt, 14pt), cycle: true),
    pen: pencircle(2pt), fill: rgb("#1a4f8b")),
  pad: 4pt)
```)

#api("join-smooth", "join-smooth(a, b, tension: 1)",
  T[Joins the end of `a` to the start of `b` with a Hobby curve that leaves `a` and enters `b` along their tangents (no corner at the junction).][Raccorde la fin de `a` au début de `b` par une courbe de Hobby qui quitte `a` et entre dans `b` selon leurs tangentes (pas d'angle à la jonction).],
  params: (
    P("a", "path", none, [Open path to leave.], [Chemin ouvert à quitter.]),
    P("b", "path", none, [Open path to enter.], [Chemin ouvert à rejoindre.]),
    P("tension", "number", "1", [Tension of the connecting curve.], [Tension de la courbe de raccord.]),
  ),
  ret: T[one open path `a` + connection + `b`.][un chemin ouvert `a` + raccord + `b`.],
  ex: ```
let a = mp-path("(0,0){right}..(30,0)")
let b = mp-path("(60,30){down}..(60,10)")
mp-fig(
  draw(join-smooth(a, b), pen: broadnib(6pt, t: 1.4pt, angle: 30deg), fill: rgb("#7a2e0e")),
  draw(a, pen: pencircle(1pt), fill: blue), draw(b, pen: pencircle(1pt), fill: blue),
  pad: 4pt)
```)

#api("close-smooth", "close-smooth(p, tension: 1)",
  T[Closes an open path with a smooth curve from its end back to its start, matching both tangents.][Ferme un chemin ouvert par une courbe lisse de sa fin à son début, en respectant les deux tangentes.],
  params: (
    P("p", "path", none, [Open path.], [Chemin ouvert.]),
    P("tension", "number", "1", [Tension of the closing curve.], [Tension de la courbe de fermeture.]),
  ),
  ret: T[a closed path.][un chemin fermé.],
  ex: ```
let p = mp-path("(0,0){up}..(25,45)..{down}(50,10)")
mp-fig(
  mp-fill(close-smooth(p), fill: rgb("#e8c9b8")),
  draw(close-smooth(p), pen: pencircle(2pt), fill: rgb("#7a2e0e")),
  pad: 4pt)
```)

#api("brace-path", "brace-path(length, amplitude)",
  T[Bare path of a calligraphic brace from `(0,0)` to `(length,0)`, bulging towards y > 0, its tip at height `amplitude`. See `delimiter` to draw it with a swelling pen.][Chemin nu d'une accolade calligraphique de `(0,0)` à `(length,0)`, bombée vers y > 0, sa pointe à la hauteur `amplitude`. Voir `delimiter` pour la tracer avec une plume qui gonfle.],
  params: (
    P("length", "length", none, [Distance between the two ends.], [Distance entre les deux extrémités.]),
    P("amplitude", "length", none, [Height of the tip.], [Hauteur de la pointe.]),
  ),
  ret: T[an open path.][un chemin ouvert.],
  ex: ```
let b = brace-path(80pt, 10pt)
mp-fig(
  draw(b, pen: pencircle(1.6pt), fill: rgb("#9a3324")),
  mp-skeleton(straight((0pt, 0pt), (80pt, 0pt)), stroke: 0.4pt + gray),
  pad: 4pt)
```)

#api("paren-path", "paren-path(length, amplitude, straight: false)",
  T[Bare path of a parenthesis-like arc from `(0,0)` to `(length,0)`, bulging towards y > 0. With `straight: true` the two curved ends are joined by a straight middle (a long bracket-parenthesis).][Chemin nu d'un arc en forme de parenthèse de `(0,0)` à `(length,0)`, bombé vers y > 0. Avec `straight: true`, les deux extrémités courbes sont reliées par un milieu droit (longue parenthèse).],
  params: (
    P("length", "length", none, [Distance between the ends.], [Distance entre les extrémités.]),
    P("amplitude", "length", none, [Bulge height.], [Hauteur du bombé.]),
    P("straight", "bool", "false", [Straight middle part.], [Partie centrale droite.]),
  ),
  ret: T[an open path.][un chemin ouvert.],
  ex: ```
mp-fig(
  draw(paren-path(60pt, 8pt), pen: pencircle(1.6pt), fill: blue),
  draw(shifted(paren-path(60pt, 8pt, straight: true), 0pt, -24pt),
    pen: pencircle(1.6pt), fill: red),
  pad: 4pt)
```)
