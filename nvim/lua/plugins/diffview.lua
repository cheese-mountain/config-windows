return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {},
  keys = {
    {
      "<leader>gd",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Toggle diffview",
    },
    {
      "<leader>gh",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "Repo history (Diffview)",
    },
    {
      "<leader>gf",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "File history (Diffview)",
    },
  },
}
