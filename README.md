# ZenTabs atom package

Keep your opened tabs below a maximum limit, closing the oldest one first.

Inspired by travmik's SublimeText [ZenTabs](https://github.com/travmik/ZenTabs) package.

See it in action with a 5 tabs limit:

![screencast](http://i.imgur.com/nxx4E1y.gif)

## Pin tabs

You can right click tabs to pin/unpin them. It basically works as a whitelist.

![pinned-screecast](http://i.imgur.com/2n0VJHH.gif)

## Options
* `maximumOpenedTabs:5`: the maximum amount of tabs that will be kep open
* `manualMode:false`: disable autmatic tab closing but still allow you to cleanup tabs through the key bindings
* `showPinnedIcon:true`: Show a lock icon next to pinned tabs title

## Key bindings

`zentabs:cleanup`, default `ctrl-Z`: triggers a tab cleanup
