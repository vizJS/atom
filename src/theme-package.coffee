Q = require 'q'
Package = require './package'

module.exports =
class ThemePackage extends Package
  getType: -> 'theme'

  getStyleSheetPriority: -> 1

  enable: ->
    atom.config.unshiftAtKeyPath('core.themes', @name)

  disable: ->
    atom.config.removeAtKeyPath('core.themes', @name)

  load: ->
    @measure 'loadTime', =>
      try
        @metadata ?= Package.loadMetadata(@path)
      catch error
        console.warn "Failed to load theme named '#{@name}'", error.stack ? error
    this

  watchThemeConfig: ->
    @configDisposable = atom.config.onDidChange @name, =>
      atom.themes.reloadStylesheets()

  activate: ->
    return @activationDeferred.promise if @activationDeferred?

    @activationDeferred = Q.defer()
    @measure 'activateTime', =>
      @activateNow()
      @reloadStylesheets()
      @watchThemeConfig()

    @activationDeferred.promise

  deactivate: ->
    @configDisposable?.dispose()
    super
