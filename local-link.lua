local github_url = "https://github.com/mit-pdos/xv6-riscv/blob/riscv/"

function gh2local(el)
	if string.sub(el.target, 1, 49) == github_url then
		el.target = "xv6-riscv-src"..string.sub(el.target,50)
	end
	return el
end

function gh2mvim(el)
	if string.sub(el.target, 1, 49) == github_url then
		local pwd = pandoc.system.get_working_directory()
		local url = string.sub(el.target, 50)
		local fname = url:match("[^#]*")
		local ln = url:match("#L([0-9]+)") or 0
		el.target = "mvim://open?url=file://"..pwd
			.."/xv6-riscv-src"..fname.."&line="..ln
	end
	return el
end

return {
	{ Link = gh2local },
}
