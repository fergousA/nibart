// Cover mosaic of the manual: figures 1–8 of examples/insolite.typ (the neon sign says "nibart" and comes first, alone on its row).
#import "../examples/insolite-figs.typ": figures

#let _fit(w, Wn, fig) = scale(w / Wn * 100%, reflow: true, box(width: Wn, fig))

#let cover-mosaic(lang, gap: 7pt) = {
  let F = figures(lang, neon-sc: 1.0)
  set text(font: "DejaVu Sans", size: 8.6pt, fill: rgb("#2b2118"))
  set align(center)
  let row(..items) = grid(columns: items.pos().map(_ => auto), column-gutter: gap, align: horizon, ..items.pos())
  let _fits = (F.embroidery, F.enso, F.tree, F.sphere, F.guilloche).map(f => _fit(97pt, 253pt, f))
  stack(dir: ttb, spacing: gap,
    scale(88%, reflow: true, F.neon),
    _fit(450pt, 507pt, F.knots),
    _fit(490pt, 507pt, F.score),
    row(.._fits),
  )
}
