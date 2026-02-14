-- Configure diagnostic virtual text to have a max width
vim.diagnostic.config({
  float = {
    width = 80,
    wrap = true,
    source = "always"
  },
  virtual_text = {
    source = "if_many",
    prefix = "●",
  }
})

return {}