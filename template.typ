// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}


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


#show: doc => cv(
  title: [Scientific Programmer & Educator],
  author: [Eric R. Scott],
  affiliation: "University of Arizona",
  phone: [+1 025-788-9855],
  email: "ericrscott\@arizona.edu",
  website: "https:\/\/ericrscott.com",
  github: "Aariq",
  doc,
)

//function for formatting entries into columns

#let cvdateentry(..content) = {
  grid(
    columns: (0.15fr, 0.85fr),
    row-gutter: 1.2em,
    ..content
  )
}

#let publications(content, boldname: none) ={
  set par(hanging-indent: 10pt)
  if boldname == none {
    content
  } else {
    show boldname: name => [*#name*]
    content
  }
}


== Education
<education>
#cvdateentry([
2014–2020
],
[
PhD, Tufts University, Medford, MA

- a

- b

- c

])
== Publications
<publications>
#block[
Bruna, E. M., Uriarte, M., Darrigo, M. R., Rubim, P., Jurinitz, C. F., Scott, E. R., Ferreira da Silva, O., & Kress, W. J. (2023). Demography of the understory herb #emph[Heliconia acuminata] (Heliconiaceae) in an experimentally fragmented tropical landscape. Ecology, 104 (12), e4174. #link("https://doi.org/10.1002/ecy.4174")

Richardson, K. M., Jospe, M. R., Saleh, A. A., Clarke, T. N., Bedoya, A. R., Behrens, N., Marano, K., Cigan, L., Liao, Y., Scott, E. R., Guo, J. S., Aguinaga, A., & Schembre, S. M. (2023). Use of Biological Feedback as a Health Behavior Change Technique in Adults: Scoping Review. Journal of Medical Internet Research, 25 (1), e44359. #link("https://doi.org/10.2196/44359")

Jackson, E. D., Casolaro, C., Nebeker, R. S., Scott, E. R., Dukes, J. S., Griffin, T. S., & Orians, C. M. (2023). Current and legacy effects of precipitation treatments on growth and nutrition in contrasting crops. Agriculture, Ecosystems & Environment, 352, 108513. #link("https://doi.org/10.1016/j.agee.2023.108513")

]



