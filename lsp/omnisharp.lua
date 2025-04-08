local utils = require("utils.common")

-- Append configuration-dependent command arguments
local function flatten(tbl)
	local ret = {}
	for k, v in pairs(tbl) do
		if type(v) == 'table' then
			for _, pair in ipairs(flatten(v)) do
				ret[#ret + 1] = k .. ':' .. pair
			end
		else
			ret[#ret + 1] = k .. '=' .. vim.inspect(v)
		end
	end
	return ret
end

local settings = {
	FormattingOptions = {
		-- Enables support for reading code style, naming convention and analyzer
		-- settings from .editorconfig.
		EnableEditorConfigSupport = true,
		-- Specifies whether 'using' directives should be grouped and sorted during
		-- document formatting.
		OrganizeImports = nil,
	},
	MsBuild = {
		-- If true, MSBuild project system will only load projects for files that
		-- were opened in the editor. This setting is useful for big C# codebases
		-- and allows for faster initialization of code navigation features only
		-- for projects that are relevant to code that is being edited. With this
		-- setting enabled OmniSharp may load fewer projects and may thus display
		-- incomplete reference lists for symbols.
		LoadProjectsOnDemand = nil,
	},
	RoslynExtensionsOptions = {
		-- Enables support for roslyn analyzers, code fixes and rulesets.
		EnableAnalyzersSupport = nil,
		-- Enables support for showing unimported types and unimported extension
		-- methods in completion lists. When committed, the appropriate using
		-- directive will be added at the top of the current file. This option can
		-- have a negative impact on initial completion responsiveness,
		-- particularly for the first few completion sessions after opening a
		-- solution.
		EnableImportCompletion = nil,
		-- Only run analyzers against open files when 'enableRoslynAnalyzers' is
		-- true
		AnalyzeOpenDocumentsOnly = nil,
	},
	Sdk = {
		-- Specifies whether to include preview versions of the .NET SDK when
		-- determining which version to use for project loading.
		IncludePrereleases = true,
	},
}

local args = {}

table.insert(args, '-z') -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
vim.list_extend(args, { '--hostPID', tostring(vim.fn.getpid()) })
table.insert(args, 'DotNet:enablePackageRestore=false')
vim.list_extend(args, { '--encoding', 'utf-8' })
table.insert(args, '--languageserver')

vim.list_extend(args, flatten(settings))

return {
	name = "omnisharp",
	cmd = { "omnisharp.exe", unpack(args) },
	filetypes = { "cs", "vb" },
	root_dir = function(buf, init)
		local dir = utils.find_root(buf, {
			"%.sln$",
			"^.git$",
			"^omnisharp.json$",
			"^function.json$",
		})

		-- only use csproj marker if no other markers exist
		if not dir then
			dir = utils.find_root(buf, { "%.csproj$" })
		end

		init(dir)
	end,
}
