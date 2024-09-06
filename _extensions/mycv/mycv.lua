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
end