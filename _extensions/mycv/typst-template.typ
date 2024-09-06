
// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates


#let cv(
  title: none,
  author: none,
  affiliation: none,
  email: none,
  phone: none,
  website: none,
  github: none,
  doc,
) = {
  set list(marker: text(blue)[○])
  show heading.where(
    level: 1
  ): it => block(width: 100%)[
    #set align(left)
    #set text(
      28pt,
      weight: "semibold"
    )
    #it.body
  ]
  show heading.where(
    level: 2
  ): it => block(width: 100%)[
    #set text(
      blue,
      16pt,
      weight: "regular"
    )
    #grid(
      columns: (0.15fr, 0.85fr),
      box(baseline: 0.4em, line(stroke: 3pt + blue, length: 90%)),
      [#it.body]
    )
  ]
  //header
  grid(
    columns: (1fr, 1fr),
    [
      = #author
      #text(
        weight: "light",
        size: 14pt,
        luma(80),
        style: "oblique"
      )[#title]
    ],
    [
      #set align(right)
      #set text(weight: "light", luma(80), style: "oblique")
      #affiliation \
      //possibly easier to have people include icons in quarto YAML with shortcodes than to hard-code this.
      #phone \
      #link("mailto:" + email)[#email] \
      #link(website)[#website.replace(regex("https?://"), "")] \
      #link("https:\\\github.com\\" + github)[#github] \
      
    ]
  )
  doc
}


