require "../spec-helper"
{$, EditorView, WorkspaceView} = require 'atom'
AutocompleteView = require '../../lib/autocomplete-view'
Autocomplete = require '../../lib/autocomplete'
FuzzyProvider = require '../../lib/fuzzy-provider'

describe "Autocomplete", ->
  [activationPromise, autocomplete, editorView, editor, completionDelay] = []

  describe "Issue 56", ->
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

      waitsForPromise -> atom.workspace.open("issues/50.js").then (e) ->
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

    it "it refocuses the editor after pressing enter", ->
      runs ->
        editorView.attachToDom()
        expect(editorView.find(".autocomplete-plus")).not.toExist()

        # Trigger an autocompletion
        editor.moveCursorToBottom()
        editor.insertText "r"

        advanceClock completionDelay

        expect(editorView.find(".autocomplete-plus")).toExist()

        editor.insertText "\n"

        expect(editorView.find(".autocomplete-plus")).not.toExist()

        expect(editorView.hasFocus()).toEqual true
