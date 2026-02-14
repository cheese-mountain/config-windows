return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    use_default_keymaps = true,
  },
  config = function(_, opts)
    require('treesj').setup(opts)
  end,
}
