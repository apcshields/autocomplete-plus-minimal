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

Mostly, you can use this fork of autocomplete-plus according to the autocomplete-plus tutorial,
"[Registering and creating suggestion providers](https://github.com/saschagehlich/autocomplete-plus/wiki/Tutorial:-Registering-and-creating-a-suggestion-provider)".
However, you will also need to install `autocomplete-plus-minimal` in your `node_modules`
directory and, in the main file of your package, instead of
```coffeescript
activate: ->
  atom.packages.activatePackage("autocomplete-plus")
    .then (pkg) =>
      @autocomplete = pkg.mainModule
      @registerProviders()
```
you should use
```coffeescript
Autocomplete = require 'autocomplete-plus-minimal'
...
activate: ->
  @autocomplete = Autocomplete
  @autocomplete.activate()

  @registerProviders()
```
That's it!

### Custom file blacklisting
By using `autocomplete-plus-minimal` instead of registering with the
`autocomplete-plus` package, you'll automatically use a different autocomplete
file blacklist for your package. If you would like to provide default values for
your package's blacklist, provide a configuration key in your main file like so:

```coffeescript
module.exports =
  configDefaults:
    fileBlacklist: "!*.{md,markdown,pandoc}"
```

In this example, the package will not provide autocompletion in any files except
those whose names end in `.md`, `.markdown`, or `.pandoc`. Remember, this will
not affect any other autocompletion providers, nor will the blacklist settings
of other providers affect your package.
