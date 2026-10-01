#import "_h.typ": *

= #T("Knots, ornaments and decorations", "Nœuds, ornements et décorations")

#T[
This layer (`art.typ`, re-exported by the package) turns the geometry engine into ready-made ornaments. The ideas follow the LaTeX packages `spath3`, `knots` and `calligraphy`; the implementation is independent. Like everything else, these functions return arrays of drawables (spread them into `mp-fig` with `..`).
][
Cette couche (`art.typ`, réexportée par le paquet) transforme le moteur géométrique en ornements prêts à l'emploi. Les idées suivent les paquets LaTeX `spath3`, `knots` et `calligraphy` ; l'implémentation est indépendante. Comme le reste, ces fonctions renvoient des tableaux d'objets dessinables (à étaler dans `mp-fig` avec `..`).
]

== #T("Knots and links", "Nœuds et entrelacs")

#api("knot", "knot(strands, style: \"gap\", rule: \"alternate\", width: 4pt, fill: black, outline: none, outline-fill: black, gap: auto, flips: (), draft: false, draft-size: 7pt)",
  T[Interlaced strands: knots, links, braids, Celtic work. Pass one path or an array of paths (open or closed). Every crossing — between strands or inside one strand — is detected automatically and numbered in order of first encounter. `style: "gap"` interrupts the under-strand (classic knot diagram); `style: "weave"` draws each strand as a ribbon with an outline and redraws the over-strand on top at each crossing (Celtic interlace; needs `outline`).][Entrelacs : nœuds, liens, tresses, motifs celtiques. Donnez un chemin ou un tableau de chemins (ouverts ou fermés). Chaque croisement — entre brins ou à l'intérieur d'un brin — est détecté automatiquement et numéroté dans l'ordre de première rencontre. `style: "gap"` interrompt le brin du dessous (diagramme de nœud classique) ; `style: "weave"` dessine chaque brin comme un ruban avec un contour et redessine le brin du dessus à chaque croisement (entrelacs celtique ; exige `outline`).],
  params: (
    P("strands", "path or array of paths", none, [The strands.], [Les brins.]),
    P("style", "string", "\"gap\"", [`"gap"` or `"weave"` (without `outline`, `"weave"` falls back to `"gap"`).], [`"gap"` ou `"weave"` (sans `outline`, `"weave"` retombe sur `"gap"`).]),
    P("rule", "string", "\"alternate\"", [`"alternate"`: alternating diagram (over, under, over… along every strand). `"first"`: the strand of lower index passes over (within one strand, the later passage).], [`"alternate"` : diagramme alterné (dessus, dessous, dessus… le long de chaque brin). `"first"` : le brin d'indice le plus bas passe dessus (dans un même brin, le dernier passage).]),
    P("width", "length or array", "4pt", [Width of the strands (one value, or one per strand).], [Largeur des brins (une valeur, ou une par brin).]),
    P("fill", "color or array", "black", [Colour of the strands (one value, or one per strand).], [Couleur des brins (une valeur, ou une par brin).]),
    P("outline", "length or none", "none", [Width of the outline on each side of a ribbon.], [Largeur du contour de chaque côté d'un ruban.]),
    P("outline-fill", "color or array", "black", [Colour of the outline.], [Couleur du contour.]),
    P("gap", "length or auto", "auto", [Clearance on each side of a gap, `"gap"` style (`auto` = 0.6 × width).], [Dégagement de chaque côté d'un trou, style `"gap"` (`auto` = 0,6 × largeur).]),
    P("flips", "array of integers", "()", [Numbers of the crossings to invert.], [Numéros des croisements à inverser.]),
    P("draft", "bool", "false", [Show the strand skeletons and the crossing numbers (to pick `flips`).], [Affiche les squelettes et les numéros de croisement (pour choisir `flips`).]),
    P("draft-size", "length", "7pt", [Size of the numbers in draft mode.], [Taille des numéros en mode brouillon.]),
  ),
  ret: T[an array of drawables.][un tableau d'objets dessinables.],
  ex: ```
// a trefoil: 24 points of a parametric curve
// un trèfle : 24 points d'une courbe paramétrique
let pt(i) = {
  let t = i * 15deg
  (9pt * (calc.sin(t) + 2 * calc.sin(2 * t)),
   9pt * (calc.cos(t) - 2 * calc.cos(2 * t)))
}
let tre = mp-path-pts(range(24).map(pt), cycle: true)
// a link of two circles
// un lien de deux cercles
let c1 = mp-path("(0,0)..(20,20)..(40,0)..(20,-20)..cycle")
let c2 = shifted(c1, 24pt, 0pt)
let blue = rgb("#1a4f8b")
grid(columns: 2, gutter: 10pt,
  mp-fig(..knot(tre, width: 3pt), pad: 3pt),
  mp-fig(..knot(tre, style: "weave", width: 5pt, fill: blue,
    outline: 1pt), pad: 3pt),
  mp-fig(..knot((c1, c2), width: 4pt, fill: (red, blue)),
    pad: 3pt),
  mp-fig(..knot((c1, c2), style: "weave", width: 5pt,
    fill: (red, blue), outline: 1pt, flips: (1,)), pad: 3pt))
```)

#api("crossings", "crossings(strands)",
  T[The raw data behind `knot`: every crossing of a set of strands, including self-intersections of each strand.][Les données brutes derrière `knot` : tous les croisements d'un ensemble de brins, y compris les auto-intersections de chaque brin.],
  params: ( P("strands", "path or array of paths", none, [The strands.], [Les brins.]), ),
  ret: T[an array of `(a: (strand, t), b: (strand, t))`: strand index and time of the two passages.][un tableau de `(a: (brin, t), b: (brin, t))` : indice du brin et temps des deux passages.],
  ex: ```
let c1 = mp-path("(0,0)..(20,20)..(40,0)..(20,-20)..cycle")
let c2 = shifted(c1, 24pt, 0pt)
let cs = crossings((c1, c2))
mp-fig(
  draw(c1, pen: pencircle(1pt), fill: red),
  draw(c2, pen: pencircle(1pt), fill: blue),
  // the point where the first strand passes through each crossing
  // le point où le premier brin traverse chaque croisement
  ..cs.map(c => mp-dot(point-of(c1, c.a.at(1)),
    pen: pencircle(6pt), fill: black)),
  mp-label(text(8pt)[#cs.len() crossings], (20pt, 28pt)),
  pad: 12pt)
```)

== #T("Calligraphic decorations", "Décorations calligraphiques")

#api("copperplate", "copperplate(p, light: 0.4pt, heavy: 2.4pt, slant: 90deg, sharpness: 1.0, taper: \"both\", taper-length: 6pt, step: 1.5pt, fill: black, outline: none)",
  T[Stroke with a *pointed pen* (copperplate, roundhand): a hairline on the upstrokes, a shade on the downstrokes. The width follows the direction of the path relative to the shading axis `slant`. Returns an array of drawables.][Trait à la *plume pointue* (copperplate, ronde) : un délié dans les montées, un plein dans les descentes. La largeur suit la direction du chemin par rapport à l'axe d'ombre `slant`. Renvoie un tableau d'objets dessinables.],
  params: (
    P("p", "path", none, [Path of the stroke.], [Chemin du trait.]),
    P("light", "length", "0.4pt", [Hairline width.], [Largeur du délié.]),
    P("heavy", "length", "2.4pt", [Width of the shade.], [Largeur du plein.]),
    P("slant", "angle", "90deg", [Direction of the shading axis (`90deg` = vertical; smaller = italic).], [Direction de l'axe d'ombre (`90deg` = vertical ; moins = italique).]),
    P("sharpness", "number", "1.0", [`> 1` confines the shade to strokes closer to the axis.], [`> 1` limite le plein aux traits plus proches de l'axe.]),
    P("taper", "string or none", "\"both\"", [Hairline entry/exit: `none`, `"start"`, `"end"`, `"both"`.], [Attaque/sortie en délié : `none`, `"start"`, `"end"`, `"both"`.]),
    P("taper-length", "length", "6pt", [Length of the tapered ends.], [Longueur des extrémités effilées.]),
    P("step", "length", "1.5pt", [Sampling distance (smaller = smoother, slower).], [Pas d'échantillonnage (plus petit = plus lisse, plus lent).]),
    P("fill", "color", "black", [Ink colour.], [Couleur de l'encre.]),
    P("outline", "stroke or none", "none", [Typst stroke around the shape.], [Trait Typst autour de la forme.]),
  ),
  ret: T[an array of drawables.][un tableau d'objets dessinables.],
  ex: ```
let p = mp-path("(0,0)..(10,22){up}..(24,40)..(30,20)..(18,0)..(14,14)..(30,26)..(52,8)..(66,26)")
let ink = rgb("#1d2a44")
stack(dir: ttb, spacing: 6pt,
  mp-fig(..copperplate(p, light: 0.5pt, heavy: 3pt,
    slant: 70deg, sharpness: 1.4, fill: ink), pad: 3pt),
  // no taper, heavier shade
  // sans effilage, plein plus lourd
  mp-fig(..copperplate(p, light: 0.5pt, heavy: 4.5pt,
    taper: none, fill: ink), pad: 3pt))
```)

#api("prongs", "prongs(p, offsets, width: 0.6pt, fill: black, tol: 0.02pt)",
  T[A multi-tine nib (split nib, engraver's pen): one thin line per offset, parallel to the path.][Une plume à plusieurs dents (plume fendue, burin) : une ligne fine par décalage, parallèle au chemin.],
  params: (
    P("p", "path", none, [Path.], [Chemin.]),
    P("offsets", "array of lengths", none, [Offsets of the tines (positive = left of the direction of travel).], [Décalages des dents (positif = à gauche du sens de parcours).]),
    P("width", "length", "0.6pt", [Width of each line.], [Largeur de chaque ligne.]),
    P("fill", "color", "black", [Colour.], [Couleur.]),
    P("tol", "length", "0.02pt", [Accuracy of the offset curves.], [Précision des courbes décalées.]),
  ),
  ret: T[an array of drawables.][un tableau d'objets dessinables.],
  ex: ```
let p = mp-path("(0,0){up}..(30,36)..(60,0)..(90,36)")
mp-fig(
  ..prongs(p, (-4pt, 0pt, 4pt), width: 0.8pt,
    fill: rgb("#1a4f8b")),
  ..prongs(shifted(p, 0pt, -50pt),
    range(-3, 4).map(i => i * 2pt), width: 0.4pt),
  pad: 6pt)
```)

#api("delimiter", "delimiter(a, b, kind: \"brace\", amplitude: 6pt, flip: false, light: 0.4pt, heavy: 1.8pt, fill: black)",
  T[A calligraphic brace or parenthesis between two points, bulging to the left of `a → b`; the pen swells where the curve turns. For the bare paths, see `brace-path` and `paren-path`.][Une accolade ou une parenthèse calligraphique entre deux points, bombée à gauche de `a → b` ; la plume gonfle là où la courbe tourne. Pour les chemins nus, voir `brace-path` et `paren-path`.],
  params: (
    P("a", "point", none, [Start point.], [Point de départ.]),
    P("b", "point", none, [End point.], [Point d'arrivée.]),
    P("kind", "string", "\"brace\"", [`"brace"`, `"paren"` (curved) or `"paren-straight"` (straight middle).], [`"brace"`, `"paren"` (courbe) ou `"paren-straight"` (milieu droit).]),
    P("amplitude", "length", "6pt", [How far the delimiter bulges.], [Importance du bombé.]),
    P("flip", "bool", "false", [Bulge to the right of `a → b` instead.], [Bombe à droite de `a → b` à la place.]),
    P("light", "length", "0.4pt", [Pen width at the ends.], [Largeur de plume aux extrémités.]),
    P("heavy", "length", "1.8pt", [Pen width where the curve swells.], [Largeur de plume là où la courbe gonfle.]),
    P("fill", "color", "black", [Ink colour.], [Couleur de l'encre.]),
  ),
  ret: T[an array of drawables.][un tableau d'objets dessinables.],
  ex: ```
mp-fig(
  ..delimiter((0pt, 0pt), (70pt, 0pt), amplitude: 7pt,
    heavy: 2.4pt, fill: rgb("#9a3324")),
  ..delimiter((0pt, -12pt), (0pt, -52pt), kind: "paren",
    amplitude: 5pt, heavy: 2.4pt),
  ..delimiter((70pt, -52pt), (70pt, -12pt),
    kind: "paren-straight", amplitude: 5pt, heavy: 2.4pt),
  // flip: the brace bulges downwards
  // flip : l'accolade bombe vers le bas
  ..delimiter((0pt, -60pt), (70pt, -60pt), flip: true,
    amplitude: 7pt, heavy: 2pt, fill: blue),
  mp-label(text(14pt)[$a+b$], (35pt, -32pt)),
  pad: 4pt)
```)

== #T("Version", "Version")

#api("nib-version", "nib-version",
  T[The package version, as a string. Useful in headers and bug reports.][La version du paquet, sous forme de chaîne. Utile dans les en-têtes et les rapports de bogue.],
  ret: T[a string, e.g. `"0.3.0"`.][une chaîne, par exemple `"0.3.0"`.],
  ex: ```
[nibart version: #nib-version]
```)
