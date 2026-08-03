require "nvchad.mappings"

local map = vim.keymap.set

-- Escape in insert mode
-- map('i', 'jk', '<Esc>');
-- map('i', 'kj', '<Esc>');
-- map('i', 'jj', '<Esc>');
-- map('i', 'kk', '<Esc>');

map("n", "<leader>Q", "<cmd>wqa<cr>", { desc = "Save and quit all" })

-- Terminal
map("t", "<esc><esc>", "<c-\\><c-n>")
map('n', '<leader>t', function()
  vim.fn.system('tmux popup -E -w 80% -h 80%')
end, { desc = 'Open tmux popup' })

map('n', '<leader>t', function()
  vim.fn.system('tmux kill-pane -t {bottom}')
  if vim.v.shell_error ~= 0 then
    vim.fn.system('tmux split-window -v -l 20')
  end
end, { desc = 'Toggle tmux terminal' })

-- Tmux
map("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>")
map("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>")
map("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>")
map("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>")
map("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>")

-- telescope
map('n', '<leader>fF', function()
  require('telescope.builtin').find_files({ cwd = '~/' })
end, { desc = 'Find files (system-wide)' })

-- LSP
map("n", "<leader>r", function()
  require("nvchad.lsp.renamer")()
end)
map('n', 'gh', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
map('n', 'gr', function()
  require('telescope.builtin').lsp_references()
end, { desc = 'Show references' })
map('n', '<leader>F', function()
  require('conform').format({ async = true, lsp_fallback = true })
end, { desc = 'Format buffer' })
map('n', '<leader>ca', function()
  vim.lsp.buf.code_action()
end, { desc = 'Code actions (imports, fixes, etc)' })

-- Import organization and fixing
map('n', '<leader>io', function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/codeAction") then
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
      })
      return
    end
  end
  vim.notify("No LSP client supports organize imports", vim.log.levels.WARN)
end, { desc = 'Organize imports' })

map('n', '<leader>ai', function()
  -- Get current line diagnostics
  local line = vim.fn.line('.') - 1
  local col = vim.fn.col('.') - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = line })
  
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/codeAction") then
      vim.lsp.buf.code_action({
        diagnostics = diagnostics,
        filter = function(action)
          return action.kind and action.kind == "quickfix"
        end,
      })
      return
    end
  end
  vim.notify("No LSP client supports code actions", vim.log.levels.WARN)
end, { desc = 'Add missing imports' })

-- Gitsigns (Git integration)
local gitsigns = require('gitsigns')

-- Preview hunk inline (VSCode-style)
map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'Preview hunk (inline)' })

-- Reset hunk inline (VSCode-style)
map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Restore current line' })

-- Toggle inline blame
map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle inline blame' })

-- Oil
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open oil" })

-- TreeSJ
map('n', '<leader>m', function()
  require('treesj').toggle()
end, { desc = 'Toggle split/join block' })
map('n', '<leader>j', function()
  require('treesj').join()
end, { desc = 'Join block' })
map('n', '<leader>s', function()
  require('treesj').split()
end, { desc = 'Split block' })

-- Center on scroll
map('n', '<C-u>', '<C-u> zz')
map('n', '<C-d>', '<C-d> zz')

-- Comment
map("n", "<leader>c", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>c", "gc", { desc = "Toggle comment", remap = true })

-- Harpoon keymaps
local harpoon = require("harpoon")
harpoon:setup()

map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add file to harpoon" })
map("n", "<leader>q", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle harpoon quick menu" })

-- Jump to harpoon files 1-5
for i = 1, 8 do
  map("n", "<leader>" .. i, function()
    harpoon:list():select(i)
  end, { desc = "Harpoon file " .. i })
end

-- Toggle quickfix list
map('n', '<leader>o', function()
  local qf_winid = nil
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      qf_winid = win.winid
      break
    end
  end

  if qf_winid then
    vim.api.nvim_win_close(qf_winid, true)
  else
    vim.cmd('copen')
  end
end, { desc = 'Toggle quickfix list' })

-- Grug-far search and replace
map("n", "<leader>sr", function()
  local ext = vim.fn.expand("%:e")
  require("grug-far").open({
    transient = true,
    prefills = {
      filesFilter = ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and replace" })

map("v", "<leader>sr", function()
  require("grug-far").open({
    transient = true,
    prefills = {
      search = vim.fn.getreg('"'),
    },
  })
end, { desc = "Search and replace (visual)" })
