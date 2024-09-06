function Div(el)
  if el.classes:includes('cv-date-entry') then
    local blocks = pandoc.List({
      pandoc.RawBlock('typst', '#cvdateentry([')
    })
    blocks:insert(el.attributes['daterange'])
    blocks:insert(pandoc.RawBlock('typst', '],\n'))
    blocks:insert(pandoc.RawBlock('typst', '['))
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock('typst', '])'))
    return blocks
  end
  
  if el.classes:includes('publications') then
    local blocks = pandoc.List({
      pandoc.RawBlock('typst', '#pubentry(')
    })
    if el.attributes['boldauth'] then
      blocks:insert(pandoc.RawBlock('typst', 'boldauth: "' .. el.attributes['boldauth'] ..'"'))
    end
    blocks:insert(pandoc.RawBlock('typst', ')['))
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock('typst', ']'))
    return blocks
  end
end
      