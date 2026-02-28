# skbd

**Stark Key Bind Daemon for macOS**

## Installation

The recommended way to get `skbd` installed is using [Homebrew](https://brew.sh).

    brew tap starkwm/formulae
    brew install starkwm/formulae/skbd@2

If installed with Homebrew, you can use `brew services` to manage running `skbd@2` in the background.

Alternatively you can build from source, which requires the latest Xcode (and macOS SDK) to be installed.

    git clone git@github.com:starkwm/skbd.git
    cd skbd
    make

If you build from source, you'll need to create a Launch Agent `.plist` file to run `skbd` in the background.

## Configuration

`skbd` can be configured using a single file, or a directory of multiple files. By default files located in `~/.config/skbd` are used. The path can be overridden using the `-c/--config` flag.

You can declare key binds by specifying one or more modifier keys and the key to bind to a command.

    cmd + shift - k: open -a iTerm

The command will be executed using the shell defined by the `$SHELL` environment variable, falling back to `/bin/bash` if not set. Commands can be split over multiple lines by using a `\` at the end of the line.

    ctrl + shift - enter:
        osascript -e 'if application "Ghostty" is running then' \
                  -e '  tell application "System Events"' \
                  -e '    click menu item "New Window" of menu "File" of menu bar 1 of process "Ghostty"' \
                  -e '  end tell' \
                  -e 'else' \
                  -e '  tell application "Ghostty" to activate' \
                  -e 'end if' > /dev/null

### Modifiers

The available modifiers values are:

- <kbd>shift</kbd>
- <kbd>ctrl</kbd>
- <kbd>opt</kbd>/<kbd>alt</kbd>
- <kbd>cmd</kbd>
- <kbd>meh</kbd>
- <kbd>hyper</kbd>
- <kbd>fn</kbd>

The `shift`, `ctrl`, `alt`, and `cmd` modifiers can be prefixed with `l` or `r` to specify the left or right modifier key on the keyboard.

The `meh` modifier key, is a shortcut for using `shift`, `control`, and `alt` all together.

The `hyper` modifier key, is a shortcut for using `shift`, `control`, `alt`, and `command` all together.

The `fn` modifier key, which is the "globe" key.

### Keys

The available key values are:

- <kbd>return</kbd>
- <kbd>tab</kbd>
- <kbd>space</kbd>
- <kbd>backspace</kbd>
- <kbd>escape</kbd>
- <kbd>backtick</kbd>
- <kbd>delete</kbd>
- <kbd>home</kbd>
- <kbd>end</kbd>
- <kbd>pageup</kbd>
- <kbd>pagedown</kbd>
- <kbd>insert</kbd>
- <kbd>left</kbd>
- <kbd>right</kbd>
- <kbd>up</kbd>
- <kbd>down</kbd>
- <kbd>f1</kbd>
- <kbd>f2</kbd>
- <kbd>f3</kbd>
- <kbd>f4</kbd>
- <kbd>f5</kbd>
- <kbd>f6</kbd>
- <kbd>f7</kbd>
- <kbd>f8</kbd>
- <kbd>f9</kbd>
- <kbd>f10</kbd>
- <kbd>f11</kbd>
- <kbd>f12</kbd>
- <kbd>f13</kbd>
- <kbd>f14</kbd>
- <kbd>f15</kbd>
- <kbd>f16</kbd>
- <kbd>f17</kbd>
- <kbd>f18</kbd>
- <kbd>f19</kbd>
- <kbd>f20</kbd>
- <kbd>a</kbd>
- <kbd>b</kbd>
- <kbd>c</kbd>
- <kbd>d</kbd>
- <kbd>e</kbd>
- <kbd>f</kbd>
- <kbd>g</kbd>
- <kbd>h</kbd>
- <kbd>i</kbd>
- <kbd>j</kbd>
- <kbd>k</kbd>
- <kbd>l</kbd>
- <kbd>m</kbd>
- <kbd>n</kbd>
- <kbd>o</kbd>
- <kbd>p</kbd>
- <kbd>q</kbd>
- <kbd>r</kbd>
- <kbd>s</kbd>
- <kbd>t</kbd>
- <kbd>u</kbd>
- <kbd>v</kbd>
- <kbd>w</kbd>
- <kbd>x</kbd>
- <kbd>y</kbd>
- <kbd>z</kbd>
- <kbd>0</kbd>
- <kbd>1</kbd>
- <kbd>2</kbd>
- <kbd>3</kbd>
- <kbd>4</kbd>
- <kbd>5</kbd>
- <kbd>6</kbd>
- <kbd>7</kbd>
- <kbd>8</kbd>
- <kbd>9</kbd>
- <kbd>`</kbd>
- <kbd>-</kbd>
- <kbd>=</kbd>
- <kbd>[</kbd>
- <kbd>]</kbd>
- <kbd>'</kbd>
- <kbd>;</kbd>
- <kbd>\\</kbd>
- <kbd>,</kbd>
- <kbd>.</kbd>
- <kbd>/</kbd>

### Block List

You can specify a list of processes to ignore shortcuts when that process is the front-most process.

    .blocklist [
      "Ghostty"
      "Finder"
    ]

When the specfied process is the current front-most process, any matching shortcuts will not execute the command.

### Comments

Comments can be added to the configuration file with lines starting with `#`.
