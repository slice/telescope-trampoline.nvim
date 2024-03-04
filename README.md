# telescope-trampoline.nvim

A [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension
to jump between project directories.

> [!IMPORTANT]
> This plugin isn't particularly designed for end user use. You probably want
> to use
> [telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim)
> instead. Caveat emptor.

Trampoline accelerates navigation between project folders and provides mappings
to invoke pickers that work off of the selected entry. For example, this makes
it faster to get to the `find_files` or `live_grep` pickers, but relative to a
specific project.

## Concepts

Trampoline defines the notion of "workspace roots", which contain project
folders as direct descendants. Keep in mind that Trampoline only performs a
shallow traversal of every workspace root&mdash;projects within projects are
unsupported at this time.

The picker presents each project folder from every workspace root as an entry.
Each project is denoted with its originating workspace root. For example, a
project folder at `~/src/prj/arizona` is shown as `prj: arizona`.

## Usage

After installing this plugin,
[load the extension](https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#loading-extensions):

```lua
require'telescope'.load_extension('trampoline')
```

Keep in mind that this is optional if you don't mind tab completions being
lazily loaded.

To configure your workspace roots, pass a table of paths as the
`workspace_roots` extension option when setting up Telescope:

```lua
telescope.setup({
  extensions = {
    trampoline = {
      workspace_roots = { "~/src/prj", "~/src/lib" },
    },
  },
})
```

`~` characters in paths passed as strings are replaced with your home directory
(resolved with [plenary]). You are also able to pass
[plenary path objects](https://github.com/nvim-lua/plenary.nvim/blob/4f71c0c4a196ceb656c824a70792f3df3ce6bb6d/lua/plenary/path.lua)
instead of strings if you'd prefer.

[plenary]: https://github.com/nvim-lua/plenary.nvim

> [!NOTE]
> There are no default workspace roots, so you'll see an empty picker if you
> don't pass in your own.

Now, the picker can be invoked via `:Telescope trampoline`. A mapping is
recommended:

```vim
nnoremap <Leader>lp <Cmd>Telescope trampoline<CR>
```

```lua
vim.keymap.set("n", "<Leader>lp", "<Cmd>Telescope trampoline<CR>")
```

## Mappings

By default, the following mappings are attached to the picker:

| Mode   | Mapping | Action                                                                                                                   |
| ------ | ------- | ------------------------------------------------------------------------------------------------------------------------ |
| insert | `<C-f>` | Runs `find_files` in the project root. Choosing a file will edit it, but will not change the current working directory.  |
| insert | `<C-s>` | Runs `live_grep` in the project root. Ditto.                                                                             |
| insert | `<C-b>` | Runs `file_browser` in the project root. Ditto.                                                                          |
| insert | `<C-d>` | Sets the working directory of the current tab to the project root.                                                       |
| insert | `<C-o>` | Spawns a shell in a new tab with a terminal inside. The tab's working directory will be set to the project root.         |
| insert | `<CR>`  | `:edit`s the directory in the current window. The working directory of the window will be set to the project root.       |
| insert | `<C-x>` | Opens the directory in a new `:split`. The working directory of the newly created split will be set to the project root. |
| insert | `<C-v>` | Opens the directory in a new `:vsplit`. Ditto.                                                                           |
| insert | `<C-t>` | Opens the directory in a new tab. The working directory of the tab will be set to the project root.                      |

[dirvish.vim] is recommended for an ergonomic directory editing experience (when
used in combination with `<CR>`, `<C-x>`, etc.)

[dirvish.vim]: https://github.com/justinmk/vim-dirvish
