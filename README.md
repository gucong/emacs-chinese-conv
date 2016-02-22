# chinese-conv
A front end in emacs to convert between simplified and traditional Chinese with opencc or cconv.

Author: Cong Gu

## Install

### Prerequisite

Have either [opencc](https://github.com/BYVoid/OpenCC) or
[cconv](https://github.com/xiaoyjy/cconv) installed in your system.

### Use [MELPA](http://melpa.org/#/getting-started)

> `M-x` `package-install` `RET` `chinese-conv` `RET`

Put the following into init file (e.g. `~/.emacs`)

```lisp
(require 'chinese-conv)
```

### Manual

Put chinese-conv.el into desired location (e.g. `~/.emacs/site-lisp/`)
and put the following into init file (e.g. `~/.emacs`)

```lisp
(add-to-list 'load-path "~/.emacs.d/site-lisp")
(require 'chinese-conv)
```

## Configuration

Chinese-conv comes with support for
[opencc](https://github.com/BYVoid/OpenCC) and
[cconv](https://github.com/xiaoyjy/cconv) as backends.

### Use opencc as backend (Default)

To change opencc program path, set `chinese-conv-opencc-program` (default: "opencc"),
```lisp
(setq chinese-conv-opencc-program "/PATH/TO/BIN/opencc")
```

To change opencc data directory, set `chinese-conv-opencc-data` (default: "/usr/share/opencc/"),
```lisp
(setq chinese-conv-opencc-data "/PATH/TO/DATA/")
```

### Use cconv as backend

Set the backend to cconv,
```lisp
(setq chinese-conv-backend "cconv")
```

To change cconv program path, set `chinese-conv-cconv-program` (default: "cconv"),
```lisp
(setq chinese-conv-cconv-program "/PATH/TO/BIN/cconv")
```

## Usage

### Interactive query

Example:

> `M-x` `chinese-conv` `RET` `后天` `RET` `traditional` `RET`

`后天` is the string to convert.  The interactive command will guess it
from marked region or current word.

`traditional` is the conversion type.  It is read with completion among all the
available types.  Hit `TAB` for a complete list of available types.

The result will be displayed in minibuffer.

### Interactive replace

Example: Mark the region to be converted in the buffer, then

> `M-x` `chinese-conv-replace` `RET` `traditional` `RET`

The marked region will be converted to traditional characters.

### Non-interactive API

```lisp
(chinese-conv "后天" "traditional")
=> "後天"
```

Backend can be explicitly specified,
```lisp
(chinese-conv "后天" "traditional" "opencc")
=> "後天"
```
