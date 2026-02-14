return {
  filters = { 
    dotfiles = false,
    git_ignored = false,
    git_clean = false,
    custom = { "node_modules" }
  },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    preserve_window_proportions = true,
    -- mappings = {
    --   list = {
    --     { key = "zM", action = "collapse_all" },
    --     { key = "zR", action = "expand_all" },
    --     { key = "zm", action = "collapse" },  -- Collapse current node
    --     { key = "zr", action = "expand" },    -- Expand current node
    --   },
    -- },
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
}
