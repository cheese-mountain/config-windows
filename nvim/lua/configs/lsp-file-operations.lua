-- Handle file operations with automatic import path updates
local M = {}

local function uri_to_path(uri)
  return vim.uri_to_fname(uri)
end

local function path_to_uri(path)
  return vim.fn.fnamemodify(path, ":p")
end

-- Setup workspace file operation handlers
function M.setup()
  local client = vim.lsp.get_active_clients()[1]
  if not client then
    return
  end

  -- Handle file renames/moves
  vim.lsp.handlers["workspace/willRenameFiles"] = function(err, result, ctx, config)
    if err then
      vim.notify("Error in willRenameFiles: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end

    -- Process each file operation
    if result and result.documentChanges then
      for _, change in ipairs(result.documentChanges) do
        if change.kind == "rename" or change.kind == "move" then
          local old_path = uri_to_path(change.oldUri)
          local new_path = uri_to_path(change.newUri)
          
          -- Log the operation
          vim.notify(
            "Will rename: " .. vim.fn.fnamemodify(old_path, ":t") .. " -> " .. vim.fn.fnamemodify(new_path, ":t"),
            vim.log.levels.INFO
          )
        end
      end

      -- Apply all edits to update import paths
      vim.lsp.util.apply_workspace_edit(result)
    end
  end

  -- Handle didRenameFiles - after files are actually moved
  vim.lsp.handlers["workspace/didRenameFiles"] = function(err, result, ctx, config)
    if err then
      vim.notify("Error in didRenameFiles: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end

    -- Apply workspace edits after the file is moved
    if result then
      vim.lsp.util.apply_workspace_edit(result)
    end
  end
end

-- Setup keybinding for renaming files with import updates
function M.setup_file_rename()
  local map = vim.keymap.set

  map("n", "<leader>rf", function()
    local current_file = vim.fn.expand("%:p")
    local new_name = vim.fn.input("New file path: ", current_file)

    if new_name == "" or new_name == current_file then
      return
    end

    -- Request file rename from LSP
    local params = {
      oldUri = vim.uri_from_fname(current_file),
      newUri = vim.uri_from_fname(new_name),
    }

    -- Send willRenameFiles request to get edits for import updates
    vim.lsp.buf_request(0, "workspace/willRenameFiles", { changes = { params } }, function(err, result)
      if err then
        vim.notify("LSP file rename failed: " .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end

      -- Execute the actual file move
      vim.fn.system { "mv", current_file, new_name }

      if vim.v.shell_error == 0 then
        -- Apply import path updates
        if result and result.documentChanges then
          vim.lsp.util.apply_workspace_edit(result)
        end

        vim.notify("File moved and imports updated!", vim.log.levels.INFO)

        -- Switch to the new file
        vim.cmd("edit " .. new_name)
      else
        vim.notify("Failed to move file", vim.log.levels.ERROR)
      end
    end)
  end, { desc = "Rename file and update imports" })
end

return M
