# obsession.vim

Vim features a `:mksession` command to write a file containing the current
state of Vim: window positions, open folds, stuff like that.  For most of my
existence, I found the interface way too awkward and manual to be useful, but
I've recently discovered that the only thing standing between me and simple,
no-hassle Vim sessions is a few tweaks:

* Instead of making me remember to capture the session immediately before
  exiting Vim, allow me to do it at any time, and automatically re-invoke
  `:mksession` immediately before exit.
* Also invoke `:mksession` whenever the layout changes (in particular, on
  `BufEnter`), so that even if Vim exits abnormally, I'm good to go.
* If I load an existing session, automatically keep it updated as above.
* If I try to create a new session on top of an existing session, don't refuse
  to overwrite it.  Just do what I mean.
* If I pass in a directory rather than a file name, just create a
  `Session.vim` inside of it.
* Don't capture options and maps.  Options are sometimes mutilated and maps
  just interfere with updating plugins.

Use `:Obsess` (with optional file/directory name) to start recording to a
session file and `:Obsess!` to stop and throw it away.  That's it.  Load a
session in the usual manner: `vim -S`, or `:source` it.

There's also an indicator you can put in `'statusline'`, `'tabline'`, or
`'titlestring'`.  See `:help obsession-status`.

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/tpope/vim-obsession.git
    vim -u NONE -c "helptags vim-obsession/doc" -c q

## Self-Promotion

Like obsession.vim?  Follow the repository on
[GitHub](https://github.com/tpope/vim-obsession) and vote for it on
[vim.org](http://www.vim.org/scripts/script.php?script_id=4472).  And if
you're feeling especially charitable, follow [tpope](http://tpo.pe/) on
[Twitter](http://twitter.com/tpope) and
[GitHub](https://github.com/tpope).

## License

Copyright © Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
