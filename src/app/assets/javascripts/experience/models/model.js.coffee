class Model extends Backbone.Model
    defaults: ->
        status: null    # current operation
        summary: null   # full summary of the model

    initialize: =>
        @roots = new AngellistExperience.ResourceCollection()
        @roots.on('add', @fetch)

        @reset()

    reset: =>
        @blueprint = new Blueprint(AngellistExperience.blueprint)
        @builder = new AngellistExperience.Builder(@)

        @roots.reset()

        @initializeContext()

        @trigger('reset', @)

    ###
    private
    ###
    initializeContext: =>
        Context.build(@blueprint)

        @mapModel = new MapModel({
            mode: 'experience'
            theme: StyleGuide.base(@blueprint.theme)
            perspective: currentAccount.perspectives.at(0)
        })

    fetch: (resource) =>
        @builder.fetch(resource)
            .done((element) =>
                # got the details, now explore the connections
                @explore(resource)
            )
            .fail((message) =>
                @trigger('alert', message)
                @roots.remove(resource)
            )

    # explore the connections of the given resource
    explore: (resource) =>
        @builder.explore(resource)


namespace 'AngellistExperience', (exports) ->
    exports.Model = Model