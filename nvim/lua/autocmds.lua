require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- Show Nvdash on start
autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd "Nvdash"
    end
  end,
})

autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if bufs and #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})

-- Autosave
autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! wa",
})

-- Load java lsp
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    callback = function(_)
        require'lsp.jdtls_setup'.setup()
    end
})
