return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    -- For logging that is to a file if you wish to trace through requests
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)
    _99.setup({
      -- provider = _99.Providers.ClaudeCodeProvider,  -- default: OpenCodeProvider
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },
      tmp_dir = "./tmp",

      --- Completions: #rules and @files in the prompt buffer
      completion = {
        --- Configure @file completion (all fields optional, sensible defaults)
        files = {
          -- enabled = true,
          -- max_file_size = 102400,     -- bytes, skip files larger than this
          -- max_files = 5000,            -- cap on total discovered files
          -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
        },
        --- What autocomplete engine to use. Defaults to native (built-in) if not specified.
        source = "native", -- "native" (default), "cmp", or "blink"
      },

      --- md_files is a list of files to look for and auto add based on the location
      --- of the originating request.
      md_files = {
        "AGENT.md",
      },
    })
  end,
}
