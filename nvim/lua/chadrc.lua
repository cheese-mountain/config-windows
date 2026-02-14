---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.term = {
  float = {
    col = 0.15, row = 0.2,
    width = 0.7, height = 0.6
  }
}

-- -- M.nvdash = { load_on_startup = true }
M.ui = {
  tabufline = {
    enabled = false
  },
  statusline = {
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "search_count", "cwd", "cursor" },
    modules = {
      search_count = function()
        return ""
        -- if vim.v.hlsearch == 0 then
        --   return ""
        -- end
        --
        -- local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
        -- if not ok or result.total == 0 then
        --   return ""
        -- end
        -- return string.format(" [%d/%d] ", result.current, result.total)
      end,
    }
  }
}

-- M.blankline = { enabled = false }

return M
