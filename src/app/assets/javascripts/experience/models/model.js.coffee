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
        # should add setCurrent* helpers for this instead
        window.currentAccount = new Account({virtual: true})
        window.currentMembership = new Membership({role: 'observer'})
        window.able = new Able(currentMembership)

        # do we really need to fake this structure or is there another layer
        # we should be working within that sits on top of the account/workspace structure
        Attributes.account = window.currentAccount
        Attributes.reset({fields: Attributes.core})
        Attributes.fields.each((field) -> field.save()) # force virtual id to be assigned

        currentAccount.load(@blueprint)

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