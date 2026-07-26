return {
  "MagicDuck/grug-far.nvim",
  opts = {
    headerMaxWidth = 80,
    -- callbacks to make grug-far.nvim running async
    resultsPaddingBufferLines = { 1, 1 },
    minSearchInputLengthBeforeSearchStarts = 2,
    transientKeymaps = true,
    keymaps = {
      replace = { n = "<leader>fr" },
      qflist = { n = "<leader>fq" },
      syncLocations = { n = "<leader>fs" },
      close = { n = "<leader>fc" },
      historyOpen = { n = "<leader>fh" },
      historyAdd = { n = "<leader>fa" },
      refresh = { n = "<leader>ff" },
      openLocation = { n = "<CR>" },
      openNextLocation = { n = "<down>" },
      openPreviousLocation = { n = "<up>" },
      gotoLocation = { n = "g<CR>" },
      pickHistoryEntry = { n = "<CR>" },
    },
    windowCreationCommand = "split",
    startInInsertMode = true,
  },
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open({
          transient = true,
        })
      end,
      mode = "n",
      desc = "Search and replace",
    },
    {
      "<leader>sr",
      function()
        require("grug-far").open({
          transient = true,
          prefills = {
            search = vim.fn.getreg('"'),
          },
        })
      end,
      mode = "v",
      desc = "Search and replace (visual selection)",
    },
  },
}

