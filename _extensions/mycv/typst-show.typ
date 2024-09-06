#show: doc => cv(
$if(jobtitle)$
  title: [$jobtitle$],
$endif$
$if(name)$
  author: [$name$],
$endif$
$if(affiliation)$
  affiliation: "$affiliation$",
$endif$
$if(phone)$
  phone: [$phone$],
$endif$
$if(email)$
  email: "$email$",
$endif$
$if(url)$
  website: "$url$",
$endif$
$if(github)$
  github: "$github$",
$endif$
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