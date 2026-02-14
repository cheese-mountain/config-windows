return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = {
        ensure_installed = {
          "stylua",
          "prettierd",
          "prettier",
          "php_cs_fixer",
          "dart_format",
          "google-java-format",
          "kotlin-language-server",
          "ktlint",
        },
      },
    },
    "neovim/nvim-lspconfig",
  },
}