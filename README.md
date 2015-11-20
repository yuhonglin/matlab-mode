# matlab-mode

An emacs matlab mode based on the [classic one](http://matlab-emacs.sourceforge.net/).

## Highlights

1. A company-mode backend
![company-file](./image/file.png)
![company-shell](./image/shell.png)

2. A flycheck backend
![demo](./image/flycheck-demo.png)

3. Easy to view document of word at cursor (default keybining: <kbd>Ctrl-c</kbd> + <kbd>h</kbd>).

The above functionalities need running ```matlab-shell``` command first.


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

> Do not forget to run matlab-shell if you want to use autocompletion and syntax checking.

## Copyright

```matlab.el``` is mostly copied from the ["classic" matlab mode](http://matlab-emacs.sourceforge.net/).

## TODO

1. debug?
