# Colemak + Russian Colemak keyboard layouts

Colemak layout with some changes/additions and Russian layout combined with Colemak.

## Build

`rake`

## Install

`sudo chown -R root:wheel 'Cölemak.bundle' && sudo mv Cölemak.bundle '/Library/Keyboard Layouts'`

## Use same keyboard layout during login screen

```shell
sudo cp {~,}/Library/Preferences/com.apple.HIToolbox.plist && sudo chown root:wheel /Library/Preferences/com.apple.HIToolbox.plist
```
