# TF2 Econ Data Compatibility Shim for TF2ItemsInfo and TF2IDB

> **Note:** This is very much a pre-alpha project &mdash; it's missing implementations for a lot
> of natives, and not all implemented natives are bug-for-bug compatible with the original yet.
> 
> If you really need this done, ~~pay me~~ send in pull requests &mdash; I've ported all of my
> own private plugins to use Econ Data directly, so I'm only doing this when I feel like it,
> and mainly released this to have a partially-complete base to work off of.

Provides native functions for [TF2ItemsInfo][]- and/or [TF2 Item DB][]-dependent plugins to get
their data from [TF2 Econ Data][].

Hopefully the last time one of these will be necessary.

[TF2ItemsInfo]: https://forums.alliedmods.net/showthread.php?t=182918
[TF2 Item DB]: https://forums.alliedmods.net/showthread.php?t=255885
[TF2 Econ Data]: https://forums.alliedmods.net/showthread.php?t=315011

## Usage

Install the plugin.  By default, the compatibility shim will register itself as both TF2IDB and
TF2ItemsInfo.  If you want it to only act as TF2IDB, have `tf2idb` somewhere in the file name.
Likewise, `tf2itemsinfo` being in the filename makes it only act as TF2ItemsInfo.
