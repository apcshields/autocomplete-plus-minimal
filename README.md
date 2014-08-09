This is a fork of the [autocomplete-plus package](https://github.com/saschagehlich/autocomplete-plus)
for [Atom](http://atom.io/). It has been modified to function as a library for
other autocomplete packages without providing its own default provider.

If you are an Atom package developer looking to develop a specialized
autocomplete package, this fork may be of interest. Otherwise, you probably want
[the original](https://github.com/saschagehlich/autocomplete-plus).

[View the changelog](https://github.com/apcshields/autocomplete-plus/blob/master/CHANGELOG.md)

## Differences from saschagehlich's original

* User-configurable per-provider file blacklisting.
* No generic autocomplete provider. By contrast, installing the
  autocomplete-plus package in Atom, which is required for autocomplete-plus
  plugin/provider development in the original package, automatically turns on a
  generic provider. (The default provider from the original package,
  FuzzyProvider, is still included but only used for testing.)

## Use as a library for autocompletion packages

Use this fork of autocomplete-plus according to the autocomplete-plus tutorial,
"[Registering and creating suggestion providers](https://github.com/saschagehlich/autocomplete-plus/wiki/Tutorial:-Registering-and-creating-a-suggestion-provider)".
The only addition you may wish to make is to provide a configuration key in your
main file like so:

```coffeescript
module.exports =
  configDefaults:
    fileBlacklist: "!*.{md,markdown,pandoc}"
```

In this example, the package will not provide autocompletion in any files except
those whose names end in `.md`, `.markdown`, or `.pandoc`. This will not affect
any other autocompletion providers, nor will the blacklist settings of other
providers affect your package.
