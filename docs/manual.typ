// nibart — reference manual (English / Français)
// Build:  typst compile --root . docs/manual.typ docs/manual-en.pdf
//         typst compile --root . --input lang=fr docs/manual.typ docs/manual-fr.pdf
#import "_h.typ": *
#import "_cover.typ": cover-mosaic

#set document(title: "nibart " + nib.nib-version + " — " + T("manual", "manuel"), author: "nibart")
#set page(paper: "a4", margin: (x: 2.1cm, y: 2.2cm),
  footer: context {
    if counter(page).get().first() > 1 [
      #set text(8pt, fill: luma(120))
      nibart #nib.nib-version · #T("Reference manual", "Manuel de référence") #h(1fr) #counter(page).display()
    ]
  })
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 10.5pt, lang: lang)
#set par(justify: true)
#show raw: it => if ns == "local" and it.text.contains("@preview/") { raw(it.text.replace("@preview/", "@local/"), lang: it.lang, block: it.block) } else { it }
#show raw: set text(font: ("DejaVu Sans Mono",), size: 8.6pt)
#show raw.where(block: true): set par(justify: false)
#show raw.where(block: false): it => box(fill: luma(240), inset: (x: 2pt), outset: (y: 2pt), radius: 1.5pt, it)
#show heading.where(level: 1): it => { pagebreak(weak: true); v(4pt); text(20pt, fill: accent, it); v(4pt); line(length: 100%, stroke: 0.6pt + accent); v(4pt) }
#show heading.where(level: 2): it => { v(10pt); text(13.5pt, fill: accent, it); v(2pt) }
#show heading.where(level: 3): it => { text(11.5pt, fill: accent, it.body); v(-2pt) }
#show link: set text(fill: rgb("#1a4f8b"))

// ───────────────────────────────────────────────────────────── cover
#page(margin: (x: 1.5cm, top: 1.2cm, bottom: 1.2cm))[
#align(center)[
  #scale(65%, reflow: true, nib.nib-stroke(nib.mp-path("(0,0){dir 70}..(30,55)..(62,20)..(95,62)..(130,18)"),
    pen: nib.nibpen((at: 0%, width: 7pt, thinness: 15%), (at: 50%, width: 15pt, thinness: 30%), (at: 100%, width: 4pt, thinness: 15%), angle: 35deg),
    fill: accent))
  #v(-0.1cm)
  #text(34pt, weight: "bold", fill: accent)[nibart]
  #v(-0.15cm)
  #text(12pt)[#T("Calligraphy, knots and ornament — a MetaPost-like pen for Typst", "Calligraphie, nœuds et ornements — une plume « à la MetaPost » pour Typst")]
  #v(0.15cm)
  #text(16pt, weight: "bold")[#T("Reference manual", "Manuel de référence")]
  #h(0.5cm)
  #text(10pt, fill: luma(90))[#T("Version", "Version") #nib.nib-version · Typst ≥ 0.15 · MIT]
  #v(0.1cm)
  #text(9pt, fill: luma(90))[#T("Author", "Auteur") #pkg.authors.first() · #link(pkg.repository, pkg.repository.trim("https://", at: start))]
  #v(0.3cm)
  #cover-mosaic(lang)
]
]
#text(20pt, weight: "bold", fill: accent)[#T("Contents", "Sommaire")]
#v(6pt)
#outline(title: none, indent: 1.2em, depth: 2)

// ───────────────────────────────────────────────────────────── part 1
= #T("Getting started", "Prise en main")


== #T("What nibart does", "Ce que fait nibart")

#T[
`nibart` draws strokes the way Metafont and MetaPost do: you describe a *path* (Hobby's smooth-curve algorithm, directions, tensions, curls…) and a *pen* (circle, ellipse, broad-edged nib, polygon, a pen whose shape changes along the path), and `nibart` computes the exact outline swept by the pen. The result is an ordinary Typst vector shape. On top of this engine, the package offers *knots and interlaced work*, *calligraphic decorations* (braces, pointed-pen strokes, multi-tine nibs) and *path surgery* (cutting, offsetting, placing things along a curve).

The geometry is computed by a small Rust plugin compiled to WebAssembly (`nibart.wasm`) shipped inside the package. No font, no external program, no network.
][
`nibart` trace des traits comme Metafont et MetaPost : vous décrivez un *chemin* (algorithme de Hobby, directions, tensions, « curl »…) et une *plume* (cercle, ellipse, plume plate, polygone, plume dont la forme change le long du chemin), et `nibart` calcule le contour exact balayé par la plume. Le résultat est une forme vectorielle Typst ordinaire. Au-dessus de ce moteur, le paquet propose des *nœuds et entrelacs*, des *décorations calligraphiques* (accolades, traits à la plume pointue, plumes à plusieurs dents) et de la *chirurgie de chemins* (découper, décaler, disposer des objets le long d'une courbe).

La géométrie est calculée par un petit plugin Rust compilé en WebAssembly (`nibart.wasm`), livré dans le paquet. Aucune police, aucun programme externe, aucun réseau.
]

== #T("Installation", "Installation")
```typ
#import "@preview/nibart:0.3.0" as nib
```
#if ns == "local" [
  #T[Local edition: installed with `install.sh` / `install.ps1` under the `@local` namespace (the published package lives under `@preview`).][Édition locale : installée avec `install.sh` / `install.ps1` dans l'espace de noms `@local` (le paquet publié vit sous `@preview`).]
] else [
  #T[Typst Universe: nothing to install. A local edition (zip with `install.sh` / `install.ps1`) installs the same package under the `@local` namespace.][Typst Universe : rien à installer. Une édition locale (zip avec `install.sh` / `install.ps1`) installe le même paquet dans l'espace de noms `@local`.]
]

#T[
Prefer the qualified form `nib.xxx`: the package exports generic names (`draw`, `cubic`, `reverse`, `pressure`, `shifted`…) that would shadow your own definitions with `import "…": *`. You can also import only what you need: `#import "@preview/nibart:0.3.0": mp-path, nib-stroke, broadnib`.
][
Préférez la forme qualifiée `nib.xxx` : le paquet exporte des noms génériques (`draw`, `cubic`, `reverse`, `pressure`, `shifted`…) qui masqueraient vos propres définitions avec `import "…": *`. Vous pouvez aussi n'importer que le nécessaire : `#import "@preview/nibart:0.3.0": mp-path, nib-stroke, broadnib`.
]

== #T("Quick start", "Démarrage rapide")

#T[One path, one pen, one call:][Un chemin, une plume, un appel :]
```typ
#import "@preview/nibart:0.3.0" as nib

#nib.nib-stroke(
  nib.mp-path("(0,0)..(40,30)..(80,0)..(120,30)"),
  pen: nib.broadnib(10pt, t: 2.5pt, angle: 30deg),
)
```
#align(center, nib.nib-stroke(nib.mp-path("(0,0)..(40,30)..(80,0)..(120,30)"), pen: nib.broadnib(10pt, t: 2.5pt, angle: 30deg)))

#T[For more control, build the drawables yourself and put them in a figure:][Pour plus de contrôle, construisez vous-même les objets dessinables et placez-les dans une figure :]
```typ
#nib.mp-fig(
  nib.draw(nib.mp-path("(0,0){up}..(40,40)..(80,0)"),
    pen: nib.pencircle(6pt), fill: rgb("#7a2e0e")),
  nib.mp-dot((40pt, 40pt), pen: nib.pencircle(4pt), fill: red),
  nib.mp-label([top], (40pt, 50pt), align: bottom),
  pad: 4pt,
)
```
#align(center, nib.mp-fig(
  nib.draw(nib.mp-path("(0,0){up}..(40,40)..(80,0)"), pen: nib.pencircle(6pt), fill: accent),
  nib.mp-dot((40pt, 40pt), pen: nib.pencircle(4pt), fill: red),
  nib.mp-label([top], (40pt, 50pt), align: bottom), pad: 4pt))

== #T("Concepts", "Concepts")

#T[
- *Axes.* As in MetaPost, *y points up* and angles are counter-clockwise. Inside an `mp-fig` the origin is where you set it (by default the content is fitted to its bounding box).
- *Units.* Anything you pass to a function can be a Typst length or angle (`3mm`; `1em` is refused because it depends on the context) or a plain number (read as pt, or as degrees for an angle). Path strings (`mp-path`) read plain numbers times `unit` (default `1pt`).
- *Paths* are opaque values (a list of Bézier segments). They are created by `mp-path` (MetaPost syntax), `mp-path-pts`, `cubic`, `straight`, `polyline`, `cubics`; combined by `path-join`; transformed by `shifted`, `scaled`, `rotated`…
- *Times.* A path of `n` segments has times from `0` to `n`. Time `2.5` is the middle of the third segment — as with MetaPost's `point 2.5 of p`.
- *Pens* are plain dictionaries: fixed (`penellipse`, `pencircle`, `broadnib`, `penpoly`, `pensquare`, `penrazor`) or variable (`nibpen`).
- *Drawables* — created by `draw`, `stroke-items`, `mp-fill`, `mp-dot`, `mp-label`, `mp-skeleton`, `mp-group`, and by the ornament functions of the second part — are handed to `mp-fig`, which returns an ordinary `box`. `nib-stroke` is the shortcut for one stroke.
- *Shapes, not strokes.* `draw` and friends return *filled* shapes (the region swept by the pen), so `fill` is the colour of the ink.
][
- *Axes.* Comme en MetaPost, *y est orienté vers le haut* et les angles sont anti-horaires. Dans un `mp-fig`, l'origine est celle que vous choisissez (par défaut le contenu est ajusté à sa boîte englobante).
- *Unités.* Tout argument peut être une longueur ou un angle Typst (`3mm` ; `1em` est refusé car il dépend du contexte) ou un nombre simple (lu en pt, ou en degrés pour un angle). Les chaînes de chemin (`mp-path`) lisent les nombres comme des multiples de `unit` (défaut `1pt`).
- *Chemins.* Valeurs opaques (liste de segments de Bézier), créées par `mp-path` (syntaxe MetaPost), `mp-path-pts`, `cubic`, `straight`, `polyline`, `cubics` ; assemblées par `path-join` ; transformées par `shifted`, `scaled`, `rotated`…
- *Temps.* Un chemin de `n` segments a des temps de `0` à `n`. Le temps `2.5` est le milieu du troisième segment — comme `point 2.5 of p` en MetaPost.
- *Plumes.* De simples dictionnaires : fixes (`penellipse`, `pencircle`, `broadnib`, `penpoly`, `pensquare`, `penrazor`) ou variables (`nibpen`).
- *Objets dessinables* — créés par `draw`, `stroke-items`, `mp-fill`, `mp-dot`, `mp-label`, `mp-skeleton`, `mp-group` et par les fonctions d'ornement de la seconde partie — qu'on confie à `mp-fig`, lequel renvoie une `box` ordinaire. `nib-stroke` est le raccourci pour un seul trait.
- *Formes, pas traits.* `draw` et ses semblables renvoient des formes *remplies* (la région balayée par la plume) : `fill` est donc la couleur de l'encre.
]

== #T("How to read this manual", "Comment lire ce manuel")

#T[
The reference below describes every public function in the same way: its *signature* with all the parameters and their defaults; a *table of parameters* (name, type, default, meaning — "required" means no default); what it *returns*; and a detailed *example*, with the code on the left and the live result on the right. Comments in the examples explain each step.

The examples are written in *code mode* and use the names *without* the `nib.` prefix, as if after `#import "@preview/nibart:0.3.0": *`. In your document, either import the names you need or prefix them with `nib.`, and put the code in `#{ … }` or in a function body. The value of the last expression is what appears on the right. An *index of all functions*, with page numbers, closes the manual.
][
La référence ci-dessous décrit chaque fonction publique de la même façon : sa *signature* avec tous les paramètres et leurs valeurs par défaut ; un *tableau des paramètres* (nom, type, défaut, signification — « obligatoire » signifie sans valeur par défaut) ; ce qu'elle *renvoie* ; et un *exemple* détaillé, avec le code à gauche et le résultat réel à droite. Les commentaires des exemples expliquent chaque étape.

Les exemples sont écrits en *mode code* et utilisent les noms *sans* le préfixe `nib.`, comme après `#import "@preview/nibart:0.3.0": *`. Dans votre document, importez les noms nécessaires ou préfixez-les par `nib.`, et placez le code dans `#{ … }` ou dans le corps d'une fonction. La valeur de la dernière expression est ce qui s'affiche à droite. Un *index de toutes les fonctions*, avec numéros de page, clôt le manuel.
]

// ───────────────────────────────────────────────────────────── part 2: reference
= #T("Paths and geometry", "Chemins et géométrie")
#include "ref-paths.typ"
#include "ref-query.typ"
#include "ref-edit.typ"

#include "ref-pens.typ"
#include "ref-draw.typ"

#include "ref-art.typ"

// ───────────────────────────────────────────────────────────── recipes
= #T("Recipes", "Recettes")

== #T("Handwriting-like loop with a broad nib", "Boucle façon écriture à la plume plate")
#ex(```
// one path with imposed directions, drawn with a broad nib
// un chemin à directions imposées, tracé à la plume plate
let p = mp-path("(0,0){dir 60}..(25,55){left}..(10,30){down}..(30,0){right}..(70,25){up}..(85,0)")
nib-stroke(p, pen: broadnib(9pt, t: 1.8pt, angle: 35deg),
  fill: rgb("#2b2b2b"), pad: 4pt)
```)

== #T("A curved arrow", "Une flèche courbe")
#T[Shorten the stem so that it stops at the base of the head, then place the head with `frame-at` and `in-frame`:][Raccourcissez la hampe pour qu'elle s'arrête à la base de la pointe, puis placez la pointe avec `frame-at` et `in-frame` :]
#ex(```
let p = mp-path("(0,0){up}..(50,40)..(100,10)")
// arrowhead pointing along +x, tip at the origin
// pointe de flèche vers +x, sommet à l'origine
let head = polyline(((-12pt, 6pt), (0pt, 0pt), (-12pt, -6pt)),
  cycle: true)
let end = frame-at(p, path-length(p))
mp-fig(
  draw(shorten(p, end: 10pt), pen: pencircle(2pt),
    fill: rgb("#7a2e0e")),
  mp-fill(in-frame(head, end), fill: rgb("#7a2e0e")),
  pad: 4pt)
```)

== #T("A string of beads on a closed curve", "Un collier de perles sur une courbe fermée")
#ex(```
let ring = mp-path("(0,0)..(40,25)..(80,0)..(40,-25)..cycle")
// 24 beads evenly spaced by arc length
// 24 perles régulièrement espacées en abscisse curviligne
let beads = frames-along(ring, count: 24).map(f =>
  mp-dot(f.pos, pen: pencircle(5pt), fill: rgb("#1a4f8b")))
mp-fig(
  draw(ring, pen: pencircle(0.6pt), fill: gray),
  ..beads, pad: 4pt)
```)

== #T("Over/under crossings by hand", "Croisements dessus/dessous à la main")
#T[`knot` does this automatically; here is the principle with `intersection-times` and `gap-at`:][`knot` le fait automatiquement ; voici le principe avec `intersection-times` et `gap-at` :]
#ex(```
let a = mp-path("(0,0)..(40,40)..(80,0)")
let b = mp-path("(0,30)..(40,0)..(80,30)")
let ts = intersection-times(a, b).map(x => x.at(0))
mp-fig(
  draw(b, pen: pencircle(6pt), fill: blue),
  ..gap-at(a, ts, 6pt).map(q =>
    draw(q, pen: pencircle(6pt), fill: red)),
  pad: 4pt)
```)

== #T("Migrating a drawing written for nibst", "Reprendre un dessin écrit pour nibst")
#T[
Give the cubic segments to `cubics(…, y-down: true)` (`nibst` uses y-down coordinates) and translate the options: `width`/`thinness`/`angle`/`follow` → `nibpen`, `dash` → `dashes`, `pressure` → `pressure`, `layered` → `overlap: "layered"`, `debug` → `debug: true`.
][
Donnez les segments cubiques à `cubics(…, y-down: true)` (`nibst` utilise des coordonnées y vers le bas) et traduisez les options : `width`/`thinness`/`angle`/`follow` → `nibpen`, `dash` → `dashes`, `pressure` → `pressure`, `layered` → `overlap: "layered"`, `debug` → `debug: true`.
]

// ───────────────────────────────────────────────────────────── notes
= #T("Notes and limits", "Notes et limites")
#T[
- *Hobby's algorithm* is validated against `mpost` on 17 test specifications (same control points within 1e-2 pt in the worst case, about 6e-5 otherwise); path operations match as well. The check script is in the repository (`tests/cmp_hobby.py`, requires MetaPost).
- Stroke shapes agree with brute-force stamping of the pen within 0.25 pt (tested at 576 ppi).
- Not implemented: `atleast`, `&` (path concatenation syntax — use `path-join`), `buildcycle`, and `...` (it behaves as `..`).
- `draw` returns *filled* shapes, not strokes; `mp-label` content is not part of the automatic bounding box.
- The plugin is a local WebAssembly file: it works with the Typst CLI, the web app and packages from Typst Universe, but not in environments that forbid WebAssembly plugins.
- *Performance.* A few hundred nodes are instantaneous; variable pens, dashes, pressure and `copperplate` cost more (subdivision by `refine`, one boolean union per piece). `knot` on a large area, or more than about a thousand curves in one document, can be slow and memory-hungry: lower `refine`, raise `tol`, enlarge `step`, or split the document.
- Errors start with `nib:` or `nibart:`; the most frequent: `pens` with the wrong number of entries, a length expected but a string or `em` given, a non-elliptical pen together with `dash`/`pressure`, `shorten` removing more than the whole path.
][
- *L'algorithme de Hobby* est validé contre `mpost` sur 17 spécifications (mêmes points de contrôle à 1e-2 pt près au pire, environ 6e-5 sinon) ; les opérations sur chemins concordent aussi. Le script de contrôle est dans le dépôt (`tests/cmp_hobby.py`, nécessite MetaPost).
- Les formes de trait concordent avec l'estampage brut de la plume à 0,25 pt près (testé à 576 ppi).
- Non implémentés : `atleast`, `&` (concaténation : utilisez `path-join`), `buildcycle`, et `...` (se comporte comme `..`).
- `draw` renvoie des formes *remplies*, pas des traits ; le contenu de `mp-label` n'entre pas dans la boîte englobante automatique.
- Le plugin est un fichier WebAssembly local : il fonctionne avec le CLI Typst, l'application web et les paquets de Typst Universe, mais pas dans un environnement qui interdit les plugins WebAssembly.
- *Performances.* Quelques centaines de nœuds sont instantanés ; les plumes variables, pointillés, pression et `copperplate` coûtent davantage (subdivision `refine`, une union booléenne par morceau). `knot` sur une grande surface, ou plus d'un millier de courbes dans un document, peut être lent et gourmand en mémoire : réduisez `refine`, augmentez `tol`, agrandissez `step`, ou découpez le document.
- Les erreurs commencent par `nib:` ou `nibart:` ; les plus fréquentes : `pens` avec un mauvais nombre d'entrées, une longueur attendue mais une chaîne ou des `em` donnés, une plume non elliptique avec `dash`/`pressure`, `shorten` qui retire plus que tout le chemin.
]

= #T("Credits and licence", "Crédits et licence")
#T[
MIT licence (see `LICENSE`). Third-party crates and acknowledgements: `THIRD-PARTY-NOTICES.md`. The path language and Hobby's algorithm come from Metafont/MetaPost (D. Knuth, J. D. Hobby); the calligraphic options are re-implemented from the behaviour described by the `nibst` package (B. Auguie) without reusing its code; the knot and ornament ideas follow the LaTeX packages `spath3`, `knots` and `calligraphy` (A. Stacey), also without sharing code.
][
Licence MIT (voir `LICENSE`). Crates tierces et remerciements : `THIRD-PARTY-NOTICES.md`. Le langage de chemins et l'algorithme de Hobby viennent de Metafont/MetaPost (D. Knuth, J. D. Hobby) ; les options calligraphiques sont réimplémentées d'après le comportement décrit par le paquet `nibst` (B. Auguie) sans reprendre son code ; les idées de nœuds et d'ornements suivent les paquets LaTeX `spath3`, `knots` et `calligraphy` (A. Stacey), également sans code commun.
]

#v(4pt)
#T[*Author:* #pkg.authors.first() — *repository:* #link(pkg.repository).][*Auteur :* #pkg.authors.first() — *dépôt :* #link(pkg.repository).]

// ───────────────────────────────────────────────────────────── index
= #T("Index of functions", "Index des fonctions")
#context {
  let es = query(<api-entry>).sorted(key: e => e.value)
  set text(size: 9pt)
  columns(2, gutter: 16pt, for e in es {
    block(spacing: 3.5pt, link(e.location(), [#raw(e.value) #box(width: 1fr, repeat[#h(2pt).#h(2pt)]) #counter(page).at(e.location()).first()]))
  })
}
