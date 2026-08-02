local log_path = vim.fn.stdpath("state") .. "/live_messages.log"
local original_notify = vim.notify

-- check C:\Users\kaspe\AppData\Local\nvim-data
vim.notify = function(msg, level, opts)
  -- 1. Call the original notify function so the message still appears on screen
  original_notify(msg, level, opts)

  -- 2. Append the message immediately to disk
  local f = io.open(log_path, "a")
  if f then
    local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
    -- Normalize table messages into strings if needed
    local formatted_msg = type(msg) == "table" and table.concat(msg, "\n") or tostring(msg)
    f:write(string.format("%s %s\n", timestamp, formatted_msg))
    f:close()
  end
end
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"
require "configs.diagnostics"

vim.schedule(function()
  require "mappings"
end)
