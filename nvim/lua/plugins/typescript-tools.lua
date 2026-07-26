return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lspconfig", "plenary.nvim" },
  config = function()
    require("typescript-tools").setup {
      settings = {
        tsserver_plugins = {
          -- "typescript-plugin-css-modules",
        },
        tsserver_file_preferences = {
          quotePreference = "single",
          importModuleSpecifierPreference = "relative",
          importModuleSpecifierEnding = "auto",
        },
        tsserver_format_options = {
          indentSize = 2,
          convertTabsToSpaces = true,
          newLine = "lf",
        },
      },
      handlers = {
        ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
          require("vim.lsp.diagnostic").on_publish_diagnostics(err, result, ctx, config)
          if result and result.diagnostics then
            local diagnostics = result.diagnostics
            for _, diagnostic in ipairs(diagnostics) do
              if diagnostic.source == "eslint" and string.match(diagnostic.message, "import") then
                -- Let ESLint handle import diagnostics
              end
            end
          end
        end,
      },
    }
  end,
}
