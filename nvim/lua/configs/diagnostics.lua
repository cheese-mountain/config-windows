-- Configure diagnostic virtual text to have a max width
vim.diagnostic.config({
  float = {
    width = 80,
    wrap = true,
    source = "always",
    border = "rounded",
    header = "",
    prefix = "",
  },
  virtual_text = {
    source = "if_many",
    prefix = "●",
    spacing = 4,
    -- Truncate long error messages to prevent them from overflowing
    format = function(diagnostic)
      local max_width = 50
      if string.len(diagnostic.message) > max_width then
        return string.sub(diagnostic.message, 1, max_width) .. "..."
      end
      return diagnostic.message
    end,
  }
})

return {}