#import "_h.typ": *

= #T("Pens", "Plumes")

#T[
A *pen* is a plain dictionary describing the shape that is dragged along a path. Fixed pens (`penellipse`, `pencircle`, `broadnib`, `penpoly`, `pensquare`, `penrazor`) have a constant shape and work with `draw` and `stroke-items`; `nibpen` builds a calligraphic pen that can vary along the path and unlocks `dash`, `pressure` and `follow` in `stroke-items`.
][
Une *plume* est un simple dictionnaire décrivant la forme qu'on fait glisser le long d'un chemin. Les plumes fixes (`penellipse`, `pencircle`, `broadnib`, `penpoly`, `pensquare`, `penrazor`) ont une forme constante et fonctionnent avec `draw` et `stroke-items` ; `nibpen` construit une plume calligraphique qui peut varier le long du chemin et donne accès à `dash`, `pressure` et `follow` dans `stroke-items`.
]

== #T("Fixed pens", "Plumes fixes")

#api("penellipse", "penellipse(w, h, angle: 0deg)",
  T[Elliptical pen, like MetaPost's `pencircle xscaled w yscaled h rotated angle`. The stroke is thickest where the path is perpendicular to the long axis.][Plume elliptique, comme `pencircle xscaled w yscaled h rotated angle` de MetaPost. Le trait est le plus épais là où le chemin est perpendiculaire au grand axe.],
  params: (
    P("w", "length", none, [Full width, along the axis rotated by `angle`.], [Largeur totale, selon l'axe tourné de `angle`.]),
    P("h", "length", none, [Full height, perpendicular to that axis.], [Hauteur totale, perpendiculaire à cet axe.]),
    P("angle", "angle", "0deg", [Orientation of the `w` axis (counter-clockwise).], [Orientation de l'axe `w` (anti-horaire).]),
  ),
  ret: T[a pen.][une plume.],
  ex: ```
let p = mp-path("(0,0){up}..(15,28)..(30,0)..(45,28)")
let pens = (
  penellipse(10pt, 3pt),
  penellipse(10pt, 3pt, angle: 45deg),
  penellipse(3pt, 10pt),
)
grid(columns: 3, gutter: 6pt,
  ..pens.map(pn => nib-stroke(p, pen: pn, pad: 4pt)))
```)

#api("pencircle", "pencircle(d)",
  T[Circular pen of diameter `d`: a stroke of constant width `d`.][Plume circulaire de diamètre `d` : un trait de largeur constante `d`.],
  params: ( P("d", "length", none, [Diameter.], [Diamètre.]), ),
  ret: T[a pen.][une plume.],
  ex: ```
let p = mp-path("(0,0)..(30,30)..(60,0)")
stack(dir: ltr, spacing: 8pt,
  ..(1pt, 3pt, 6pt, 10pt).map(d =>
    nib-stroke(p, pen: pencircle(d), pad: 2pt)))
```)

#api("broadnib", "broadnib(w, t: auto, angle: 30deg)",
  T[Broad-edged calligraphic pen: a flattened ellipse. Thick strokes perpendicular to the nib, hairlines parallel to it.][Plume plate de calligraphe : une ellipse aplatie. Traits épais perpendiculaires à la plume, déliés parallèles à elle.],
  params: (
    P("w", "length", none, [Width of the nib.], [Largeur de la plume.]),
    P("t", "length or auto", "auto", [Thickness of the nib (`auto` = `w / 5`).], [Épaisseur de la plume (`auto` = `w / 5`).]),
    P("angle", "angle", "30deg", [Slant of the nib, counter-clockwise from horizontal.], [Inclinaison de la plume, anti-horaire depuis l'horizontale.]),
  ),
  ret: T[a pen.][une plume.],
  ex: ```
// the letter "n" with three nib angles
// la lettre « n » avec trois angles de plume
let n = mp-path("(0,0){up}..(0,24)..(2,16){up}..(14,26){right}..(24,14){down}..(24,0)")
stack(dir: ltr, spacing: 10pt,
  ..(0deg, 30deg, 60deg).map(a =>
    nib-stroke(n, pen: broadnib(6pt, angle: a), pad: 3pt)))
```)

#api("penpoly", "penpoly(pts)",
  T[Convex polygonal pen. The points are given around the origin; the stroke is the exact union of the polygon dragged along the path.][Plume polygonale convexe. Les points sont donnés autour de l'origine ; le trait est l'union exacte du polygone déplacé le long du chemin.],
  params: ( P("pts", "array of points", none, [Vertices of a convex polygon (lengths).], [Sommets d'un polygone convexe (longueurs).]), ),
  ret: T[a pen.][une plume.],
  ex: ```
let p = mp-path("(0,0)..(25,30)..(50,0)..(75,30)")
let tri = penpoly(((-6pt, -4pt), (6pt, -4pt), (0pt, 7pt)))
nib-stroke(p, pen: tri, pad: 4pt)
```)

#api("pensquare", "pensquare(s, angle: 0deg)",
  T[Square pen of side `s`, rotated by `angle`.][Plume carrée de côté `s`, tournée de `angle`.],
  params: (
    P("s", "length", none, [Side of the square.], [Côté du carré.]),
    P("angle", "angle", "0deg", [Rotation (counter-clockwise).], [Rotation (anti-horaire).]),
  ),
  ret: T[a pen.][une plume.],
  ex: ```
let p = mp-path("(0,0)..(25,30)..(50,0)..(75,30)")
stack(dir: ltr, spacing: 8pt,
  ..(0deg, 20deg, 45deg).map(a =>
    nib-stroke(p, pen: pensquare(5pt, angle: a), pad: 3pt)))
```)

#api("penrazor", "penrazor(len, angle: 0deg)",
  T[Razor pen: a straight segment of length `len` at `angle`. Gives sharp, flat strokes whose width is zero when the path follows the razor.][Plume rasoir : un segment de longueur `len` à l'angle `angle`. Donne des traits francs et plats dont la largeur est nulle quand le chemin suit le rasoir.],
  params: (
    P("len", "length", none, [Length of the segment.], [Longueur du segment.]),
    P("angle", "angle", "0deg", [Direction of the segment.], [Direction du segment.]),
  ),
  ret: T[a pen.][une plume.],
  ex: ```
let p = mp-path("(0,0)..(25,30)..(50,0)..(75,30)")
stack(dir: ltr, spacing: 8pt,
  ..(0deg, 45deg, 90deg).map(a =>
    nib-stroke(p, pen: penrazor(10pt, angle: a), pad: 3pt)))
```)

== #T("The calligraphic pen and its options", "La plume calligraphique et ses options")

#api("nibpen", "nibpen(..stops, width: 1pt, thinness: 25%, minor-width: none, angle: 30deg, follow: false)",
  T[A broad-edged pen that may *change along the path*. Without stops its parameters are constant. A *stop* is a dictionary `(at:, width:, thinness:, minor-width:, angle:)`; `at` is a ratio of the arc length (`50%`) or an absolute arc length (`2cm`). Keys missing from a stop take the defaults given to `nibpen`. Parameters are interpolated linearly between stops. With `follow: true` the angle is measured from the tangent of the path, so the nib turns with the stroke.][Plume plate qui peut *varier le long du chemin*. Sans arrêt, ses paramètres sont constants. Un *arrêt* est un dictionnaire `(at:, width:, thinness:, minor-width:, angle:)` ; `at` est une proportion de la longueur d'arc (`50%`) ou une longueur d'arc absolue (`2cm`). Les clés absentes d'un arrêt prennent les valeurs données à `nibpen`. Les paramètres sont interpolés linéairement entre les arrêts. Avec `follow: true`, l'angle est mesuré depuis la tangente du chemin : la plume tourne avec le trait.],
  params: (
    P("..stops", "dictionaries", "()", [Optional stops `(at:, width:, thinness:, minor-width:, angle:)`.], [Arrêts optionnels `(at:, width:, thinness:, minor-width:, angle:)`.]),
    P("width", "length", "1pt", [Default major axis (full width of the nib).], [Grand axe par défaut (largeur totale de la plume).]),
    P("thinness", "ratio", "25%", [Minor axis as a share of `width`.], [Petit axe en proportion de `width`.]),
    P("minor-width", "length or none", "none", [Minor axis as an absolute length (overrides `thinness`).], [Petit axe en longueur absolue (remplace `thinness`).]),
    P("angle", "angle", "30deg", [Default nib angle.], [Angle de plume par défaut.]),
    P("follow", "bool", "false", [Angle relative to the tangent instead of fixed.], [Angle relatif à la tangente au lieu d'être fixe.]),
  ),
  ret: T[a variable pen (use it with `stroke-items` / `nib-stroke`, not `draw`).][une plume variable (à utiliser avec `stroke-items` / `nib-stroke`, pas `draw`).],
  ex: ```
let p = mp-path("(0,0){up}..(25,45)..(60,10)..(95,50)")
let ink = rgb("#7a2e0e")
// 1. constant · 2. three stops · 3. follow the path
// 1. constante · 2. trois arrêts · 3. suit le chemin
let a = nibpen(width: 8pt, thinness: 20%, angle: 40deg)
let b = nibpen(
  (at: 0%, width: 3pt), (at: 50%, width: 14pt, thinness: 40%),
  (at: 100%, width: 3pt), angle: 40deg)
let c = nibpen(width: 9pt, thinness: 20%, angle: 90deg, follow: true)
stack(dir: ttb, spacing: 6pt,
  ..(a, b, c).map(pn => nib-stroke(p, pen: pn, fill: ink)))
```)

#api("dashes", "dashes(..lengths, offset: 0pt, jitter: 0pt, seed: 0)",
  T[Dash pattern for `stroke-items(dash: …)`: alternating dash and gap lengths along the path. `jitter` varies every length randomly (deterministically, from `seed`), which gives a hand-drawn look.][Motif de pointillés pour `stroke-items(dash: …)` : longueurs alternées de trait et de vide le long du chemin. `jitter` fait varier chaque longueur au hasard (de façon déterministe, à partir de `seed`), ce qui donne un aspect dessiné à la main.],
  params: (
    P("..lengths", "lengths", none, [Dash, gap, dash, gap… (repeated cyclically).], [Trait, vide, trait, vide… (répétés cycliquement).]),
    P("offset", "length", "0pt", [Where the pattern starts.], [Début du motif.]),
    P("jitter", "length", "0pt", [Random variation ±`jitter` of every length.], [Variation aléatoire ±`jitter` de chaque longueur.]),
    P("seed", "integer", "0", [Seed of the random sequence.], [Graine de la suite aléatoire.]),
  ),
  ret: T[a dash specification.][une spécification de pointillés.],
  ex: ```
let p = mp-path("(0,0)..(40,30)..(80,0)..(120,30)")
let pen = nibpen(width: 8pt, thinness: 30%, angle: 30deg)
stack(dir: ttb, spacing: 4pt,
  nib-stroke(p, pen: pen, dash: dashes(10pt, 5pt)),
  nib-stroke(p, pen: pen, dash: dashes(10pt, 5pt, offset: 5pt)),
  nib-stroke(p, pen: pen,
    dash: dashes(10pt, 4pt, jitter: 3pt, seed: 7)))
```)

#api("pressure", "pressure(minimum-width: 0.2pt, period: 2pt, seed: 0)",
  T[Simulates a pen being lifted: wherever the minor axis of the pen is below `minimum-width`, the stroke breaks up with a probability that grows as the pen gets thinner (one random draw per `period` of arc length). Use it with a pen that thins out.][Simule une plume qui se soulève : là où le petit axe de la plume passe sous `minimum-width`, le trait se fragmente avec une probabilité croissante quand la plume s'amincit (un tirage par `period` de longueur d'arc). À utiliser avec une plume qui s'amincit.],
  params: (
    P("minimum-width", "length", "0.2pt", [Minor axis below which the stroke starts to break up.], [Petit axe en dessous duquel le trait commence à se fragmenter.]),
    P("period", "length", "2pt", [Length of each random draw.], [Longueur de chaque tirage.]),
    P("seed", "integer", "0", [Seed of the random sequence.], [Graine de la suite aléatoire.]),
  ),
  ret: T[a pressure specification.][une spécification de pression.],
  ex: ```
let p = mp-path("(0,0){up}..(35,50)..(70,0)..(105,50)")
// the pen thins from 40% to 2% of its width
// la plume s'amincit de 40 % à 2 % de sa largeur
let pen = nibpen((at: 0%, width: 10pt, thinness: 40%),
  (at: 100%, width: 10pt, thinness: 2%), angle: 20deg)
nib-stroke(p, pen: pen,
  pressure: pressure(minimum-width: 1.2pt, period: 1.5pt, seed: 3))
```)
