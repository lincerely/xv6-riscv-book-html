local line_refs = {}
local function unpackCodeBlock(el)
	table.insert(el.classes, "C")

	local blocks = {}
	local ln = nil
	if el.attributes then
		ln = el.attributes.startFrom
	end
	local code = ""
	local isfirst = true
	local indention = math.huge
	for line in string.gmatch(el.text, "[^\n]*") do

		-- any line with code, other than the first line,
		-- compare with minimum indention
		if (not isfirst) and string.len(line) > 0 then
			local l = string.len(string.match(line, "^ *"))
			indention = math.min(l, indention)
		end
		isfirst = false

		local tex = string.match(line, "%(%*@(.*)@%*%)")
		line = string.gsub(line, "%(%*@(.*)@%*%)", "")
		if tex then
			for k, il in pairs(pandoc.utils.blocks_to_inlines(pandoc.read(tex, "latex").blocks)) do
				if (il.attr and il.attr.identifier and il.attr.identifier ~= "") then
					-- is link target
					if ln then
						line_refs[il.attr.identifier] = ln;
					end
					table.insert(blocks, il);
				else
					-- add any inline codes to current line
					local firstword = true
					il:walk({Str = function(el) 
						if firstword then
							line=line..el.text
							firstword = false
						else
							line=line.." "..el.text
						end
					end})
				end
			end
		end
		if ln then
			ln=ln+1
		end
		code = code.."\n"..line
	end

	-- fix indention for the first line
	if indention < math.huge then
		el.text = string.rep(" ", indention)..string.sub(code, 2)
	end

	table.insert(blocks, el)
	return blocks
end

local function updateLink(el)
	ref = el.attributes.reference
	if line_refs[ref] then
		--print("Link: "..ref)
		el.content = pandoc.Str(line_refs[ref])
	end
	return el
end

return {{CodeBlock = unpackCodeBlock},
		{Link = updateLink}}
