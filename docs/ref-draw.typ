#import "_h.typ": *

= #T("Drawing", "Dessiner")

#T[
Drawing functions return *drawables*: opaque objects that you pass to `mp-fig`, which lays them out in a y-up coordinate system and returns an ordinary Typst `box`. `nib-stroke` is the shortcut for one calligraphic stroke in its own box.
][
Les fonctions de dessin renvoient des *objets dessinables* : des objets opaques qu'on confie à `mp-fig`, qui les dispose dans un repère y-haut et renvoie une `box` Typst ordinaire. `nib-stroke` est le raccourci pour un seul trait calligraphique dans sa propre boîte.
]

== #T("Strokes", "Traits")

#api("draw", "draw(p, pen: none, pens: none, fill: black, tol: 0.01pt, fit: true, exact: false, outline: none)",
  T[Draws path `p` with a pen, like MetaPost's `pickup pen; draw p`. The result is the exact *filled shape* swept by the pen. Pass either a fixed pen (`pen`) or, for a variable pen at the lowest level, `pens`: one `(w, h, angle)` per path node. For `nibpen`, dashes, pressure… use `stroke-items`.][Trace le chemin `p` avec une plume, comme `pickup pen; draw p` de MetaPost. Le résultat est la *forme remplie* exacte balayée par la plume. Donnez soit une plume fixe (`pen`), soit, pour une plume variable de bas niveau, `pens` : un triplet `(w, h, angle)` par nœud du chemin. Pour `nibpen`, pointillés, pression… utilisez `stroke-items`.],
  params: (
    P("p", "path", none, [Path to draw.], [Chemin à tracer.]),
    P("pen", "pen", "none", [Fixed pen (`penellipse`, `pencircle`, `broadnib`, `penpoly`, `pensquare`, `penrazor`).], [Plume fixe (`penellipse`, `pencircle`, `broadnib`, `penpoly`, `pensquare`, `penrazor`).]),
    P("pens", "array or function", "none", [Variable pen: one `(w, h, angle)` per node (`segments + 1`, or `segments` on a closed path), or a function of the node index.], [Plume variable : un `(w, h, angle)` par nœud (`segments + 1`, ou `segments` sur un chemin fermé), ou une fonction de l'indice du nœud.]),
    P("fill", "color", "black", [Fill of the shape.], [Remplissage de la forme.]),
    P("tol", "length", "0.01pt", [Geometric tolerance of the envelope.], [Tolérance géométrique de l'enveloppe.]),
    P("fit", "bool", "true", [Fit Bézier curves to the outline of variable/polygonal pens (fewer nodes).], [Ajuste des courbes de Bézier au contour des plumes variables/polygonales (moins de nœuds).]),
    P("exact", "bool", "false", [Force the sweep by union of convex hulls instead of the exact envelope.], [Force le balayage par union d'enveloppes convexes au lieu de l'enveloppe exacte.]),
    P("outline", "stroke or none", "none", [Typst stroke drawn around the shape.], [Trait Typst dessiné autour de la forme.]),
  ),
  ret: T[a drawable.][un objet dessinable.],
  ex: ```
let p = mp-path("(0,0){up}..(30,36)..(60,0)..(90,36)")
mp-fig(
  // fixed pen with a Typst outline
  // plume fixe avec un contour Typst
  draw(p, pen: broadnib(8pt, t: 2pt, angle: 35deg),
    fill: rgb("#e8c9b8"), outline: 0.6pt + rgb("#7a2e0e")),
  // variable pen: one (w, h, angle) per node (4 nodes)
  // plume variable : un (w, h, angle) par nœud (4 nœuds)
  draw(shifted(p, 0pt, -50pt),
    pens: i => (4pt + i * 3pt, 2pt, 20deg * i),
    fill: rgb("#1a4f8b")),
  pad: 4pt)
```)

#api("stroke-items", "stroke-items(p, pen: none, pens: none, fill: black, dash: none, pressure: none, follow: auto, refine: auto, overlap: \"union\", layer: 4pt, outline: none, tol: 0.01pt, exact: false, fit: true, debug: false)",
  T[The all-in-one calligraphic stroke. Returns an *array* of drawables (spread it into `mp-fig` with `..`). Accepts every kind of pen; `nibpen`-specific features need an elliptical pen: dashes, pressure, `overlap: "layered"` and `debug`.][Le trait calligraphique tout-en-un. Renvoie un *tableau* d'objets dessinables (à étaler dans `mp-fig` avec `..`). Accepte tous les types de plume ; les fonctions propres à `nibpen` exigent une plume elliptique : pointillés, pression, `overlap: "layered"` et `debug`.],
  params: (
    P("p", "path", none, [Path to draw.], [Chemin à tracer.]),
    P("pen", "pen", "none", [Any pen, including `nibpen(…)`.], [Toute plume, y compris `nibpen(…)`.]),
    P("pens", "array or function", "none", [Legacy per-node pens (as in `draw`); cannot be combined with dash, pressure, layered or debug.], [Plumes par nœud (comme dans `draw`) ; incompatible avec dash, pressure, layered et debug.]),
    P("fill", "color", "black", [Fill of the shapes (translucent colours work with `layered`).], [Remplissage des formes (les couleurs translucides fonctionnent avec `layered`).]),
    P("dash", "dashes", "none", [Dash pattern from `dashes(…)`.], [Motif de pointillés issu de `dashes(…)`.]),
    P("pressure", "pressure", "none", [Pen-lifting from `pressure(…)`.], [Soulèvement de plume issu de `pressure(…)`.]),
    P("follow", "bool or auto", "auto", [Overrides `nibpen(follow:)`.], [Remplace `nibpen(follow:)`.]),
    P("refine", "integer or auto", "auto", [Subdivision of each segment for varying pens (`auto` = 4 when the pen varies, else 1).], [Subdivision de chaque segment pour les plumes variables (`auto` = 4 si la plume varie, sinon 1).]),
    P("overlap", "string", "\"union\"", [`"union"`: one merged shape; `"layered"`: pieces of length `layer` stacked as separate shapes.], [`"union"` : une seule forme fusionnée ; `"layered"` : morceaux de longueur `layer` empilés comme formes séparées.]),
    P("layer", "length", "4pt", [Length of a piece in `layered` mode.], [Longueur d'un morceau en mode `layered`.]),
    P("outline", "stroke or none", "none", [Typst stroke around the shapes.], [Trait Typst autour des formes.]),
    P("tol, exact, fit", "—", "0.01pt, false, true", [As in `draw`.], [Comme dans `draw`.]),
    P("debug", "bool", "false", [Also draw the skeleton (red) and some pen positions (cyan).], [Dessine aussi le squelette (rouge) et quelques positions de la plume (cyan).]),
  ),
  ret: T[an array of drawables.][un tableau d'objets dessinables.],
  ex: ```
let p = mp-path("(0,0)..(35,40)..(70,0)..(105,40)")
let ink = rgb("#7a2e0e")
let pen = nibpen(width: 12pt, thinness: 25%, angle: 30deg)
stack(dir: ttb, spacing: 8pt,
  // layered, translucent, with outline
  // empilé, translucide, avec contour
  mp-fig(..stroke-items(p, pen: pen, overlap: "layered",
    layer: 5pt, fill: ink.transparentize(65%),
    outline: 0.3pt + ink), pad: 4pt),
  // construction view
  // vue de construction
  mp-fig(..stroke-items(p, pen: pen, debug: true,
    fill: ink.transparentize(70%)), pad: 4pt))
```)

#api("nib-stroke", "nib-stroke(p, pad: 1pt, ..args)",
  T[Like `stroke-items`, but returns a ready-to-use box (an `mp-fig` fitted to the stroke plus `pad`). Every other argument is passed on to `stroke-items`.][Comme `stroke-items`, mais renvoie directement une boîte prête à l'emploi (un `mp-fig` ajusté au trait plus `pad`). Tous les autres arguments sont transmis à `stroke-items`.],
  params: (
    P("p", "path", none, [Path to draw.], [Chemin à tracer.]),
    P("pad", "length", "1pt", [Margin around the stroke.], [Marge autour du trait.]),
    P("..args", "—", none, [Any argument of `stroke-items` (`pen`, `fill`, `dash`, …).], [Tout argument de `stroke-items` (`pen`, `fill`, `dash`, …).]),
  ),
  ret: T[a box (baseline on the `y = 0` line when the stroke crosses it).][une boîte (ligne de base sur `y = 0` quand le trait la traverse).],
  ex: ```
let p = mp-path("(0,0){dir 60}..(25,55){left}..(10,30){down}..(30,0){right}..(70,25){up}..(85,0)")
nib-stroke(p, pad: 4pt, fill: rgb("#2b2b2b"),
  pen: broadnib(9pt, t: 1.8pt, angle: 35deg))
```)

== #T("Fills, dots, labels", "Remplissages, points, étiquettes")

#api("mp-fill", "mp-fill(p, fill: black)",
  T[Fills the area enclosed by a closed path (`fill p`).][Remplit l'aire délimitée par un chemin fermé (`fill p`).],
  params: (
    P("p", "path", none, [Closed path (an open path is closed by a straight line).], [Chemin fermé (un chemin ouvert est fermé par une droite).]),
    P("fill", "color", "black", [Fill colour.], [Couleur de remplissage.]),
  ),
  ret: T[a drawable.][un objet dessinable.],
  ex: ```
let blob = mp-path("(0,0)..(30,10)..(40,40)..(10,35)..cycle")
mp-fig(
  mp-fill(blob, fill: rgb("#e8c9b8")),
  mp-skeleton(blob, stroke: 0.8pt + rgb("#7a2e0e")),
  pad: 4pt)
```)

#api("mp-dot", "mp-dot(pos, pen: pencircle(2pt), fill: black)",
  T[A dot: the pen shape drawn at one position (`drawdot`).][Un point : la forme de la plume dessinée en une position (`drawdot`).],
  params: (
    P("pos", "point", none, [Position `(x, y)`.], [Position `(x, y)`.]),
    P("pen", "pen", "pencircle(2pt)", [Pen whose shape is the dot (a round, elliptical, square… dot).], [Plume dont la forme est le point (rond, elliptique, carré…).]),
    P("fill", "color", "black", [Colour.], [Couleur.]),
  ),
  ret: T[a drawable.][un objet dessinable.],
  ex: ```
mp-fig(
  mp-dot((0pt, 0pt), pen: pencircle(8pt), fill: red),
  mp-dot((20pt, 0pt), pen: pensquare(7pt, angle: 20deg), fill: blue),
  mp-dot((40pt, 0pt), pen: penellipse(12pt, 5pt, angle: 30deg)),
  mp-dot((60pt, 0pt), pen: penpoly(((-5pt, -4pt), (5pt, -4pt), (0pt, 6pt))), fill: green),
  pad: 4pt)
```)

#api("mp-label", "mp-label(body, pos, align: center + horizon)",
  T[A Typst content placed at a position, aligned like MetaPost's `label.top`/`.lft`… `align` says which point of the content sits at `pos`. Labels do not count in the automatic bounding box of `mp-fig` (use `pad`).][Un contenu Typst placé en une position, aligné comme `label.top`/`.lft`… de MetaPost. `align` indique quel point du contenu est posé en `pos`. Les étiquettes ne comptent pas dans la boîte englobante automatique de `mp-fig` (utilisez `pad`).],
  params: (
    P("body", "content", none, [Any content: text, maths, an image…], [Tout contenu : texte, maths, image…]),
    P("pos", "point", none, [Position `(x, y)`.], [Position `(x, y)`.]),
    P("align", "alignment", "center + horizon", [Anchor of the content: `top`, `bottom`, `left`, `right`, `center`, `horizon` and their combinations.], [Ancrage du contenu : `top`, `bottom`, `left`, `right`, `center`, `horizon` et leurs combinaisons.]),
  ),
  ret: T[a drawable.][un objet dessinable.],
  ex: ```
// each dot is the anchor `pos`; the label hangs from it
// chaque point est l'ancre `pos` ; l'étiquette s'y accroche
let anchors = (top, bottom, left, right)
mp-fig(
  ..anchors.enumerate().map(((i, a)) => {
    let o = (i * 34pt, 0pt)
    mp-group(
      mp-dot(o, pen: pencircle(3pt), fill: red),
      mp-label(text(7pt, repr(a)), o, align: a))
  }),
  mp-label(text(11pt)[$sum x_i$], (50pt, 28pt)),
  width: 140pt, height: 46pt, origin: (20pt, 16pt))
```)

#api("mp-skeleton", "mp-skeleton(p, stroke: 0.4pt + red)",
  T[Draws the bare skeleton of a path with a Typst `stroke` (handy to check a path before choosing a pen).][Dessine le squelette nu d'un chemin avec un `stroke` Typst (pratique pour vérifier un chemin avant de choisir une plume).],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("stroke", "stroke", "0.4pt + red", [Any Typst stroke (dashed, coloured…).], [Tout trait Typst (pointillé, coloré…).]),
  ),
  ret: T[a drawable.][un objet dessinable.],
  ex: ```
let p = mp-path("(0,0){up}..(30,36)..(60,0)")
mp-fig(
  mp-skeleton(p, stroke: 0.6pt + blue),
  mp-skeleton(shifted(p, 0pt, -12pt),
    stroke: (paint: red, thickness: 1pt, dash: "dashed")),
  pad: 4pt)
```)

#api("mp-group", "mp-group(..items)",
  T[Groups several drawables into one (so a function can return a single object). `mp-fig` also accepts arrays of drawables directly, so grouping is optional.][Regroupe plusieurs objets dessinables en un seul (pour qu'une fonction renvoie un objet unique). `mp-fig` accepte aussi directement des tableaux d'objets, le regroupement est donc facultatif.],
  params: ( P("..items", "drawables", none, [Objects to group (arrays are flattened).], [Objets à regrouper (les tableaux sont aplatis).]), ),
  ret: T[a drawable.][un objet dessinable.],
  ex: ```
// a reusable "flower": one object made of several
// une « fleur » réutilisable : un objet fait de plusieurs
let petal = mp-path("(0,0)..(10,5)..(20,0)..(10,-5)..cycle")
let flower(c, dx) = mp-group(
  ..range(6).map(i => mp-fill(
    shifted(rotated(petal, i * 60deg), dx, 0pt),
    fill: c.transparentize(30%))),
  mp-dot((dx, 0pt), pen: pencircle(5pt), fill: yellow))
mp-fig(flower(red, 0pt), flower(blue, 28pt), pad: 2pt)
```)

== #T("Figures", "Figures")

#api("mp-fig", "mp-fig(..items, width: auto, height: auto, origin: (0pt, 0pt), pad: 1pt, baseline: auto, grid: none, frame: none, clip: false)",
  T[Collects drawables in a y-up coordinate system (like `beginfig … endfig`) and returns a `box`. With `auto` sizes the box is fitted to the content plus `pad`; with explicit sizes `origin` is the position of the origin counted from the bottom-left corner. The box can be used inline in running text: its baseline is the line `y = 0` unless `baseline` is given.][Rassemble des objets dessinables dans un repère y-haut (comme `beginfig … endfig`) et renvoie une `box`. Avec des tailles `auto`, la boîte s'ajuste au contenu plus `pad` ; avec des tailles explicites, `origin` est la position de l'origine comptée depuis le coin bas-gauche. La boîte peut s'insérer dans le texte courant : sa ligne de base est la droite `y = 0` sauf si `baseline` est donné.],
  params: (
    P("..items", "drawables", none, [Objects to draw, in order (later ones on top). Arrays are flattened: `..stroke-items(…)` or `stroke-items(…)` both work.], [Objets à dessiner, dans l'ordre (les derniers dessus). Les tableaux sont aplatis : `..stroke-items(…)` ou `stroke-items(…)` conviennent.]),
    P("width", "length or auto", "auto", [Width of the box (`auto` = fit the content).], [Largeur de la boîte (`auto` = ajustée au contenu).]),
    P("height", "length or auto", "auto", [Height of the box.], [Hauteur de la boîte.]),
    P("origin", "point", "(0pt, 0pt)", [Position of the origin from the bottom-left corner (explicit sizes only).], [Position de l'origine depuis le coin bas-gauche (tailles explicites seulement).]),
    P("pad", "length", "1pt", [Margin added around the content when a size is `auto`.], [Marge ajoutée autour du contenu quand une taille est `auto`.]),
    P("baseline", "length or auto", "auto", [Baseline offset from the bottom of the box.], [Décalage de la ligne de base depuis le bas de la boîte.]),
    P("grid", "length or none", "none", [Draws a light grid with this spacing (for design work).], [Trace une grille légère de cet espacement (pour la mise au point).]),
    P("frame", "stroke or none", "none", [Border stroke around the box.], [Trait de bordure autour de la boîte.]),
    P("clip", "bool", "false", [Clip drawing that leaves the box.], [Coupe ce qui dépasse de la boîte.]),
  ),
  ret: T[a `box`.][une `box`.],
  ex: ```
let p = mp-path("(0,0){up}..(30,36)..(60,0)")
// explicit size, origin in the middle, grid, frame
// taille explicite, origine au milieu, grille, cadre
mp-fig(
  draw(p, pen: pencircle(5pt), fill: rgb("#7a2e0e")),
  mp-dot((0pt, 0pt), pen: pencircle(3pt), fill: red),
  width: 110pt, height: 70pt, origin: (30pt, 15pt),
  grid: 10pt, frame: 0.5pt + gray, clip: true)
```)
