local Path = require("plenary.path")
local M = {}

local function project_name()
	local repo_table = vim.fn.split(vim.fn.system("git rev-parse --show-toplevel"), "/")
	local parsed_repo_name = vim.fn.split(repo_table[#repo_table], "\n")[1]

	return parsed_repo_name
end

local function routes_cache_file()
	local cache_dir = vim.fn.stdpath("cache") .. "/blink-cmp-rails-routes.nvim/" .. project_name()

	if vim.fn.glob(cache_dir) == "" then
		vim.fn.mkdir(cache_dir, "p")
	end

	local cache_file = cache_dir .. "/routes.json"

	return cache_file
end

local function parse_route(route_string)
	local result = {}

	-- Tokenize the line
	local tokens = {}

	for token in route_string:gmatch("%S+") do
		table.insert(tokens, token)
	end

	-- Check if we have exactly 4 tokens (valid route)
	if #tokens == 4 then
		local name, path = tokens[1], tokens[3]
		result[name .. "_path"] = path
	end

	return result
end

function M:sync()
	print("Syncing routes to " .. routes_cache_file())

	vim.fn.jobstart({ "bin/rails", "routes" }, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			local parsed_routes = {}
			for index, route in ipairs(data) do
				if
					index ~= 1
					and route ~= ""
					and not string.match(route, "rails")
					and not string.match(route, "turbo")
					and not string.match(route, "/assets")
				then
					local parsed_route = parse_route(route)
					if not vim.tbl_isempty(parsed_route) then
						parsed_routes = vim.tbl_extend("force", parsed_routes, parsed_route)
					end
				end
			end
			local routes_path = routes_cache_file()
			Path:new(routes_path):write(vim.fn.json_encode(parsed_routes), "w")

			print("Rails routes synced successfully!")
		end,
		on_error = function(_, error)
			print(error)
		end,
	})
end

function M:read_routes()
	local routes_file = routes_cache_file()

	if vim.fn.filereadable(routes_file) == 0 then
		vim.notify("Please sync routes first!", vim.log.levels.WARN)

		return {}
	end

	return vim.fn.json_decode(vim.fn.readfile(routes_file))
end

return M
