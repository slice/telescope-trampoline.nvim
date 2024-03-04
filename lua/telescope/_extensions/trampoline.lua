local telescope = require('telescope')
local builtin = require('telescope.builtin')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local pickers = require('telescope.pickers')
local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local scan = require('plenary.scandir')
local Path = require('plenary.path')

local M = {}

function M.discover_workpace_roots()
  local home = Path:new(Path.path.home) -- :thinking:
  return {home / 'src' / 'prj', home / 'src' / 'lib'}
end

function M.project_finder(opts)
  local workspace_roots = opts.workspace_roots or M.discover_workpace_roots()

  local discovered_project_roots = {}
  for _, workspace_root in ipairs(workspace_roots) do
    discovered_project_paths = scan.scan_dir(workspace_root.filename, {
      hidden = false,
      add_dirs = true,
      respect_gitignore = false,
      depth = 1,
      silent = true
    })

    for _, discovered_project_path in ipairs(discovered_project_paths) do
      table.insert(discovered_project_roots, { root = Path:new(discovered_project_path) })
    end
  end

  return finders.new_table {
    results = discovered_project_roots,
    entry_maker = function(root)
      -- TODO: don't use an internal method if we don't have to?
      local components = root.root:_split()
      local name = components[#components]
      local workspace_root_name = components[#components - 1]

      return {
        value = root.root.filename,
        display = workspace_root_name .. ': ' .. name,
        ordinal = root.root.filename,
        filename = root.root.filename
      }
    end
  }
end

function M.get_selected_path(prompt_bufnr)
  return action_state.get_selected_entry(prompt_bufnr).value
end

M.actions = {}

function M.action(action, keepinsert)
  keepinsert = (keepinsert == nil and true) or keepinsert
  return function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local project_root = M.get_selected_path(prompt_bufnr)
    action(project_root)
  end
end

function M.project(opts)
  pickers.new({}, {
    prompt_title = 'Trampoline',
    finder = M.project_finder(opts),
    sorter = sorters.get_fuzzy_file(),
    attach_mappings = function(prompt_bufnr, map)
      -- TODO: normal mode mappings
      map('i', '<c-f>', M.action(function(project_root)
        builtin.find_files({ cwd = project_root })
      end))
      map('i', '<c-s>', M.action(function(project_root)
        builtin.live_grep({ cwd = project_root })
      end))
      map('i', '<c-b>', M.action(function(project_root)
        builtin.file_browser({ cwd = project_root })
      end))
      map('i', '<c-d>', M.action(function(project_root)
        vim.cmd('tcd ' .. project_root)
        vim.schedule(function() vim.api.nvim_echo({{project_root}}, false, {}) end)
      end, false))
      map('i', '<c-o>', M.action(function(project_root)
        local shell = vim.env.SHELL
        vim.cmd('tabnew | terminal sh -c "cd ' .. project_root .. '; ' .. shell .. '"')
        vim.schedule(function() vim.cmd('startinsert') end)
      end, false))

      action_set.select:replace(function(_, type)
        local project_root = M.get_selected_path(prompt_bufnr)
        actions.close(prompt_bufnr)

        local edit_cmd_lookup = {
          default = 'edit',
          horizontal = 'split',
          vertical = 'vsplit',
          tab = 'tabe'
        }

        local cd_cmd_lookup = {
          default = 'lcd',
          horizontal = 'lcd',
          vertical = 'lcd',
          tab = 'tcd'
        }

        -- Don't use the actions.file_{edit,split,vsplit,tab} actions since
        -- they employ some special buffer lookup behavior that we don't want.
        local edit_cmd = edit_cmd_lookup[type]
        vim.cmd(edit_cmd .. ' ' .. project_root)

        local cd_cmd = cd_cmd_lookup[type]
        vim.cmd(cd_cmd .. ' ' .. project_root)
      end)

      return true
    end
  }):find()
end

return telescope.register_extension{
  setup = function() end,
  exports = { trampoline = M.project },
}
