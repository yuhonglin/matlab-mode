# matlab-mode

An emacs matlab mode based on the [classic one](http://matlab-emacs.sourceforge.net/).

## Warning
First use or open ```.m``` file can be slow because it needs to open a background matlab process.

## Highlights

1. A company-mode backend
![company-file](./image/file.png)
![company-shell](./image/shell.png)

2. A flycheck backend
![demo](./image/flycheck-demo.png)

3. Easy to view document of word at cursor (default keybinding: <kbd>Ctrl-c</kbd> + <kbd>h</kbd>).


4. ```TODO``` Jump to definition (default keybinding: <kbd>Ctrl-c</kbd> + <kbd>s</kbd>).
Currently, this only helps open the souce file (can not go to the definition of the function).
If it does not work, it may be becasue you have not added the file's folder into matlab workspace.

## Install

1. Install dependencies like ```s.el```, ```flycheck``` and ```company-mode```.
2. Copy the code to somewhere
3. Add the following to the initialization file

```elisp
(setq matlab-shell-command "/path/to/matlab/binary")
(add-to-list 'load-path "/path/to/matlab-mode/")
(require 'matlab-mode)
(matlab-mode-common-setup)
```

## Copyright

```matlab.el``` is mostly copied from the ["classic" matlab mode](http://matlab-emacs.sourceforge.net/).

## TODO

1. debug?
