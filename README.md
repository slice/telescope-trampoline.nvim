# telescope-trampoline.nvim

A [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension
to jump between project directories. You probably want to use
[telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim)
instead.

Trampoline makes it easier to jump between project folders and quickly edit
files from them. It also provides a handy keybind to spawn a terminal in a new
tab with the working directory set to the project root.

## Usage

After installing this plugin through your plugin manager (or lack thereof), load
the extension:

```lua
require'telescope'.load_extension('trampoline')
```

Then, add a mapping to invoke the extension:

```vim
nnoremap <leader>lp <cmd>lua require'telescope'.extensions.trampoline.trampoline.project{}<CR>
```

Trampoline has the notion of "workspace roots". Directly within these roots lie
project folders. Project folders of arbitrary depth are not supported; it is
assumed that you have a flat listing of folders under each root. Currently, the
workspace roots are hardcoded to be `~/src/prj` and `~/src/lib`. You are
encouraged to change them in
[`lua/telescope/_extensions/trampoline.lua`](./lua/telescope/_extensions/trampoline.lua).

Invoking the extension presents a picker of project folders, discovered by
listing the folders from each workspace root. The folder names are prefixed with
the originating workspace root. For example, a project folder at
`~/src/prj/arizona` is shown as `prj: arizona`. This is helpful should your
workspace roots each contain projects of different categories.

The following mappings are present:

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

I personally recommend using [dirvish.vim] for a more pleasant directory editing
experience.

[dirvish.vim]: https://github.com/justinmk/vim-dirvish
