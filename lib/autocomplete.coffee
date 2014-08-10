_ = require "underscore-plus"
AutocompleteView = require "./autocomplete-view"
Provider = require "./provider"
Suggestion = require "./suggestion"
path = require "path"
fs = require "fs"

module.exports =
  autocompleteViews: []
  editorSubscription: null

  # Public: Creates AutocompleteView instances for all active and future editors
  activate: ->
    @setupPackageSpace()

    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached and not editor.mini
        autocompleteView = new AutocompleteView(editor, @package)
        editor.on "editor:will-be-removed", =>
          autocompleteView.remove() unless autocompleteView.hasParent()
          autocompleteView.dispose()
          _.remove(@autocompleteViews, autocompleteView)
        @autocompleteViews.push(autocompleteView)

  # Public: Cleans everything up, removes all AutocompleteView instances
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []

  # Public: Finds the autocomplete view for the given EditorView
  # and registers the given provider
  #
  # provider - The new {Provider}
  # editorView - The {EditorView} we should register the provider with
  registerProviderForEditorView: (provider, editorView) ->
    autocompleteView = _.findWhere @autocompleteViews, editorView: editorView
    unless autocompleteView?
      throw new Error("Could not register provider", provider.constructor.name)

    autocompleteView.registerProvider provider

  # Public: Finds the autocomplete view for the given EditorView
  # and unregisters the given provider
  #
  # provider - The {Provider} to unregister
  unregisterProvider: (provider) ->
    view.unregisterProvider for view in @autocompleteViews

  # Private: Sets up anything that would have been taken care of if this were a
  # top-level package.
  setupPackageSpace: ->
    @getCallingPackage()
    @loadStylesheets()

  # Private: Get and load the stylesheets in the `stylesheets` directory.
  loadStylesheets: ->
    stylesheetDir = path.join(path.dirname(path.dirname(module.filename)), 'stylesheets')
    stylesheets = _.filter fs.readdirSync(stylesheetDir), (file) ->
      extension = path.extname(file)

      extension is 'css' or 'less'

    atom.themes.requireStylesheet(path.join(stylesheetDir, stylesheet)) for stylesheet in stylesheets

  # Private: Finds the name of the package loaded by package.js.
  #
  # Returns {String} which is the name of the package loaded by package.js.
  getCallingPackage: ->
    if not @package
      # Find the appropriate package.
      _package = module

      while (parentFilename = path.basename(_package.parent.filename)) isnt 'package.js' and parentFilename isnt 'spec-suite.coffee'
        _package = _package.parent

      # Go up the directory hierarchy looking for package.json.
      # See https://github.com/vesln/package/blob/master/lib/package.js
      location = path.dirname _package.filename
      found = null

      until found
        if fs.existsSync(location + '/package.json')
          found = location + '/package.json'
        else if location isnt '/'
          location = path.dirname location
        else
          throw new Error "Couldn't find package.json for #{_package.filename}"

      # Read package.json.
      @package = JSON.parse fs.readFileSync(found, 'utf8')

    return @package


  Provider: Provider
  Suggestion: Suggestion
