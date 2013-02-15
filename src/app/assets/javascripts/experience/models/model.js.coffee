class Model extends Backbone.Model
    defaults: ->
        status: null    # current operation
        summary: null   # full summary of the model

    initialize: =>
        @roots = new AngellistExperience.ResourceCollection()

        @reset()
        @listen()

    reset: =>
        @blueprint = new Blueprint(AngellistExperience.blueprint)
        @builder = new AngellistExperience.Builder(@)

        @roots.reset()

        @initializeContext()

        @trigger('reset', @)

    getSummary: =>
        "Exploring <strong>#{@roots.pluck('name').join(', ')}</strong>"

    ###
    private
    ###
    initializeContext: =>
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


    listen: =>
        @roots.on('add', @fetch)

    fetch: (resource) =>
        # @set('summary', )
        # @set({
        #     status: "Exploring #{root.get(.label}..."
        #     summary: @getSummary()
        # })
    
        console.log("roots are", resource, @roots.models)

        @trigger('search')

        @builder.fetch(resource)
            .done((element) =>
                # @controller.status("Exploring <strong>#{_.pluck(@model.roots, 'name').join(', ')}</strong>")
            
                @explore(resource) # automatically start exploring the initial element
            )
            .fail((message) =>
                @trigger('alert', message)
                # @controller.fatal(message)

                @roots.remove(resource)
            )

    explore: (resource) =>
        log.fatal('exploring', resource)

        @trigger('search')
        
        # modal update
        @set({
            status: "Exploring #{resource.get('name')}..."
            summary: @getSummary()
        })

        # @controller.map.showMessage("Exploring #{element.label}...")

        # expand on the selected element
        @builder.explore(resource)


namespace 'AngellistExperience', (exports) ->
    exports.Model = Model