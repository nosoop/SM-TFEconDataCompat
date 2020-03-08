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
Likewise, `tf2itemsinfo` being in the filename makes it only act as TF2ItemsInfo.  (TF2IDB
supercedes TF2II in the case that both names are present.)

## Compatibility

The `test_tf2ii_compat` plugin is a test suite to verify that the TF2ItemsInfo natives are
working correctly; both the compatibility shim and the original TF2II plugin should pass all the
tests.  The tests are automatically run once when the plugin is loaded and the schema is
available.

Tested against the following TF2ItemsInfo version(s):
- [1.8.17.7-20131121](https://forums.alliedmods.net/showpost.php?p=1689522&postcount=1)
- [1.9.1](https://forums.alliedmods.net/showpost.php?p=2184857&postcount=1)

Note that for all the compatibility tests to pass for TF2II, that plugin needs to be recompiled
due to certain changes in SourceMod (mainly the change to `TFHoliday` values being pubvars
instead of a normal enum).
