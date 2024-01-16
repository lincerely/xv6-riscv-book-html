function pdf2svg(el)
	if string.sub(el.src, -4) == ".pdf" then
		el.src = string.sub(el.src, 1, -5)..".svg"
	end
	return el
end

return {
	{Image = pdf2svg },
}
