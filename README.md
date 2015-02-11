# ZenTabs atom package

Keep your opened tabs below a maximum limit, closing the oldest one first.

Inspired by travmik's SublimeText [ZenTabs](https://github.com/travmik/ZenTabs) package.

See it in action with a 5 tabs limit:

![screencast](http://i.imgur.com/nxx4E1y.gif)

## Pin tabs

You can right click tabs to pin/unpin them. It basically works as a whitelist.

![pinned-screecast](http://i.imgur.com/2n0VJHH.gif)

## Options
* `maximumOpenedTabs:5`: the maximum amount of tabs that will be keep open
* `manualMode:false`: disable automatic tab closing but still allow you to cleanup tabs through the key bindings
* `showPinnedIcon:true`: Show a lock icon next to pinned tabs title
* `neverCloseUnsaved:false`: If set to true, unsaved files won't be closed
* `neverCloseNew:false`: If set to true, files with a `new` git status won't be closed
* `neverCloseDirty:false`: If set to true, files with a `modified` git status won't be closed

## Key bindings

`zentabs:cleanup`, default `alt-shift-t`: triggers a tab cleanup
