local async = require("blink.cmp.lib.async")

local cache

---Include the trigger character when accepting a completion.
---@param context blink.cmp.Context
local function transform(items, context)
	local entries = {}

	for route, desc in pairs(items) do
		table.insert(entries, {
			label = route,
			filterText = route,
			insertText = route,
			kind = require("blink.cmp.types").CompletionItemKind.Text,
			documentation = {
				kind = "markdown",
				value = desc,
			},
		})
	end

	return entries
end

---@type blink.cmp.Source
local M = {}

function M.new(opts)
	local self = setmetatable({}, { __index = M })

	if not cache then
		vim.api.nvim_create_user_command("RailsRoutesSync", function()
			require("blink-cmp-rails-routes.cache").sync()
		end, { desc = "Sync rails routes" })

		cache = require("blink-cmp-rails-routes.cache").read_routes()
	end
	return self
end

---@param context blink.cmp.Context
function M:get_completions(context, callback)
	local task = async.task.empty():map(function()
		callback({
			is_incomplete_forward = true,
			is_incomplete_backward = true,
			items = transform(cache, context),
			context = context,
		})
	end)
	return function()
		task:cancel()
	end
end

return M
