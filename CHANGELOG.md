# Changelog

## 0.3.0 — renamed **nibart** (was `nib`)
- Package, crate and plugin renamed: `@preview/nibart`, `nibart.wasm`. The API of 0.2 is unchanged (`nib-version`, `nib-stroke`, … keep their names); `lib.typ` now re-exports `core.typ` (engine) and `art.typ` (new layer).
- New knots: `knot(...)` — automatic crossings (between strands and inside one strand), alternating over/under (graph 2-colouring), styles `"gap"` and `"weave"` (Celtic interlace), per-strand colours/widths, `flips`, `rule`, `draft` numbering; `crossings`, `self-intersections`.
- New calligraphy: `copperplate` (pointed pen: hairline up, shade down, tapered ends), `prongs` (multi-tine nib), `delimiter` (brace, curved and straight parentheses between two points) with `brace-path` / `paren-path`.
- New path surgery: `offset` (parallel curves, exact via Béziers), `shorten`, `split-at`, `remove-intervals`, `gap-at`, `weld`, `fit-between`, `join-smooth`, `close-smooth`, `round-corners`, `frame-at`, `in-frame`, `frames-along`.
- New plugin operations: `self_intersections`, `offset`.
- New example `examples/nibart.typ` (FR/EN), new tests `tests/t_art.typ`.
- **Manual rewritten as a complete reference** (EN + FR, ~47 pages): every public function (all 69) has its signature, a table of parameters (type, default, meaning), the return value and a detailed live example with the code beside the result; contents, recipes, notes, and an index of functions with page numbers. Source in `docs/` (`manual.typ`, `ref-*.typ`, `_h.typ`).
- **Illustrated gallery** (EN + FR, `docs/gallery-en.pdf`, `docs/gallery-fr.pdf`, 20 pages): every example not shown in the manual, one plate per page with preview, description, the package functions it uses (read from its source) and the build command. Source `docs/gallery.typ`; previews rendered by `scripts/build-gallery.sh` into `docs/gallery/`; `make gallery`. Replaces the old `examples/apercus/` thumbnails.
- Manual cover: figures 1–8 of the *insolite* example (neon sign first, now reading “nibart”). Figures 1–8 moved to `examples/insolite-figs.typ` (shared by `insolite.typ` and `docs/_cover.typ`). Embroidery flower now has 8 petals. The gallery no longer has an overview page.
- **Two editions** built by `scripts/package.py`: *Universe* (`dist/nibart-0.3.0-universe.zip`, lean, `@preview`) and *local* (`dist/nibart-0.3.0-local.zip`, full, `@local`, with `install.sh` / `install.ps1`; its manuals show `@local` in the code samples, `--input ns=local`). README conditional blocks `<!--universe-->` / `<!--local-->`.
- Author and repository set in `typst.toml` (FERGOUS Abdelhak, @fergousA), `LICENSE`, READMEs, manual cover and credits, gallery cover.
- Examples `demo`, `calligraphie`, `galerie`, `exotique`, `boites` are now bilingual (`--input lang=fr|en`, French by default), like `insolite`, `nibart` and `podium`; titles say *nibart*.
- Fix: the podium entry below said Arabic mirrors the layout; it does not (2nd place stays on the left in every language).

## 0.2.0
- New: `nibpen` with stops along arc length (`at: 0%` or a length), `follow` (angle relative to the tangent).
- New: `dashes` (irregular, seeded), `pressure`, `overlap: "layered"`, `outline:`, `debug: true`.
- New: length-based path constructors `cubic`, `straight`, `polyline`, `cubics` (with `y-down: true`), `path-join-all`.
- New: `stroke-items` / `nib-stroke` (all of the above in one call); `draw(..., outline:)`.
- New plugin operations: `refine`, `profile`, `pieces`, `nib_stroke_many`.
- New example `examples/insolite.typ` (11 unexpected uses: score, knots with computed over/under, neon, embroidery, fractal tree, dry-brush enso, engraved sphere, guilloché, map, relief, sketch).
- New examples: `examples/chat.typ` (flat "Hello Summer" beach-cat illustration with pen-drawn lettering), `examples/ile.typ` (island figure) and `examples/ile-chat.typ` (same island with a cat on the towel).
- New example `examples/podium.typ`: order of operations on a podium (hand-lettered signs, numerals, laurels, stars); `--input lang=fr|en|ar` (Arabic captions keep the same layout; use an Arabic font such as ArabTeX Naskh via `--font-path`).
- Docs: bilingual manual (EN/FR), English README + French README, third-party notices.
- Manifest: valid categories, license, `compiler = "0.15.0"`, trimmed `exclude`.

## 0.1.0
- First version: MetaPost path language with Hobby's algorithm (validated against `mpost`), elliptical, polygonal and
  variable pens, exact envelopes, path operations (point, direction, arclength, arctime, subpath, intersections,
  transforms), `mp-fig` figures and labels.
