local function starts_with(str, start)
	return str:sub(1, #start) == start
end

local function inlineString(inlines)
	local str = ""
	for k, v in ipairs(inlines) do
		if v.t == "Str" then
			str = str .. v.text
		elseif v.t == "Space" or v.t == "SoftBreak" then
			str = str .. ' '
		else
			io.stderr:write("undefined inline type: " .. v.t .. "\n")
		end
	end
	return str
end

-- span [ str [ index name ], link, link, ... ]
local indexes = {}

function createIndex(el)
	if not el.content[1]["text"] then return el end
	if not starts_with(el.content[1].text, "%%index") then return el end

	local indexType = el.content[1].text
	table.remove(el.content, 1)
	table.remove(el.content, 1)
	local str = inlineString(el.content)
	local idstr = str:gsub(" ", "_")

	if not indexes[idstr] then
		if indexType == "%%indexcode" then
			indexes[idstr] = { pandoc.Code(str) }
		else
			indexes[idstr] = { pandoc.Str(str) }
		end
	end
	local linkCount = #indexes[idstr]
	local target = idstr.."_"..tostring(linkCount)
	local link = pandoc.Link(tostring(linkCount), "#"..target)
	table.insert(indexes[idstr], link)

	if indexType == "%%indextext" then
		return pandoc.Emph(pandoc.Span(el.content, { id = target }))
	elseif indexType == "%%indextextx" then
		return pandoc.Span(el.content, { id = target })
	elseif indexType == "%%indexcode" then
		return pandoc.Code(str, { id = target })
	end
end

local function sortIndexes(idx1, idx2)
	return idx1[1].text < idx2[1].text
end

function insertIndex(doc)
	local header = pandoc.Header(1, pandoc.Str("Index"), {id = "index" })
	table.insert(doc.blocks, header)
	local list = {}
	for k,v in pairs(indexes) do
		table.insert(list, v)
	end
	table.sort(list, sortIndexes)
	table.insert(doc.blocks, pandoc.BulletList(list))
	return doc
end

return {
	{Emph=createIndex},
	{Pandoc=insertIndex}
}
