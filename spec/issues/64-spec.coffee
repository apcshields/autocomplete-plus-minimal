require "../spec-helper"
{$, EditorView, WorkspaceView} = require 'atom'
AutocompleteView = require '../../lib/autocomplete-view'
Autocomplete = require '../../lib/autocomplete'
FuzzyProvider = require '../../lib/fuzzy-provider'

describe "Autocomplete", ->
  [activationPromise, autocomplete, editorView, editor, completionDelay] = []

  describe "Issue 64", ->
    beforeEach ->
      runs ->
        # Set to live completion
        atom.config.set "autocomplete-plus.enableAutoActivation", true

        # Set the completion delay
        completionDelay = 100
        atom.config.set "autocomplete-plus.autoActivationDelay", completionDelay
        completionDelay += 100 # Rendering delay
        atom.workspaceView = new WorkspaceView()
        atom.workspace = atom.workspaceView.model

      waitsForPromise -> atom.workspace.open("issues/64.css").then (e) ->
        editor = e
        atom.workspaceView.simulateDomAttachment()

      # Activate the package
      waitsForPromise -> atom.packages.activatePackage("autocomplete-plus").then (a) -> autocomplete = a

      runs ->
        editorView = atom.workspaceView.getActiveView()
        autocomplete = new AutocompleteView editorView, { name: 'autocomplete-plus' }

        # Register a FuzzyProvider for editorView with autocompleteView.
        # This used to happen automatically in AutocompleteView->initialize.
        fuzzyProvider = new FuzzyProvider(editorView, { name: "autocomplete-plus" })
        autocomplete.registerProvider fuzzyProvider

    it "it adds words hyphens to the wordlist", ->
      runs ->
        editorView.attachToDom()
        editor.insertText c for c in "bla"

        advanceClock completionDelay

        expect(editorView.find(".autocomplete-plus")).toExist()

        expect(autocomplete.list.find("li:eq(0)")).toHaveText "bla-foo--bar"
