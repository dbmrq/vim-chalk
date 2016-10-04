# chalk.vim

Vim can get confused when handling multiple nested fold markers.

The answer is to include a level (like this: `"{{{1`), but I'm too lazy for that. Enter Chalk. It automatically adds the level to folds you create with `zf` and increments all nested folds for you. There are also specific mappings and commands to increment and decrement markers while keeping them balanced and more. :tada:

![chalk](http://i.imgur.com/8X3Oljm.gif)


### Quick start

1. Install Chalk using your favorite plugin manager or copy each file to its corresponding directory under `~/.vim/`.

2. Add this to your `.vimrc`:

    ```vim
    set foldmethod=marker

    vmap zf <Plug>Chalk          " Create fold at visual selection
    nmap zf <Plug>Chalk          " Create fold at operator movement
    nmap zF <Plug>ChalkRange     " Create fold for specified number of lines

    nmap Zf <Plug>SingleChalk    " Open single fold at current level
                                 " or specified count
    nmap ZF <Plug>SingleChalkUp  " Open single fold at next level
                                 " or specified count

    nmap =z <Plug>ChalkUp        " Increment current fold level
    nmap -z <Plug>ChalkDown      " Decrement current fold level
    vmap =z <Plug>ChalkUp        " Increment levels in selection
    vmap -z <Plug>ChalkDown      " Decrement levels in selection
    ```

    (Chose the mappings you prefer. These are only suggestions.)


## Commands

#### `:ChalkUp` and `:ChalkDown`

Increment or decrement the fold marker levels for the specified range (or the whole file, if no range is given).


## Mappings

#### `<Plug>Chalk`

This works just like Vim's `zf`, creating a new fold at the current selection (in visual mode) or motion (in normal mode). The difference is that it also adds the fold level automatically according to where you're at.

#### `<Plug>ChalkRange`

This works just like Vim's `zF`, creating a fold for the specified number of lines, but with the same perks as above.

#### `<Plug>SingleChalk`

The previous mappings add both the opening and closing fold markers. This one, on the other hand, adds a single opening marker at current line. If a count is specified before the mapping, that count is used as the level number. If no count is specified, this mapping will use the current level.

#### `<Plug>SingleChalkUp`

This mapping works like the previous one, but if no count is specified, it will use a level deeper than the current fold's.

#### `<Plug>ChalkUp` and `<Plug>ChalkDown`

When used in Normal mode, these mappings will increment or decrement the pair of markers (or the single marker, if you're into that sort of thing) at the current level.

When used in Visual mode, they'll increment or decrement every marker in the visual selection. Not that unlike their Normal mode counterparts the Visual mode mappings won't keep the opening and closing markers balanced unless they're both inside the selection.


## See also

You may also be interested in my other plugins:

- [Ditto: highlight overused words](https://github.com/dbmrq/vim-ditto) :speak_no_evil:
- [Dialect: project specific spellfiles](https://github.com/dbmrq/vim-dialect) :speech_balloon:


