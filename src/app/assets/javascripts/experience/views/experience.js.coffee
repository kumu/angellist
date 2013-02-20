class Experience extends Backbone.View
    name: 'Angel List'
    url: 'http://angel.co'
    
    template: JST['experience/templates/experience']

    initialize: ->
        # wait until updates calm down to actually update the map
        @onUpdate = _.debounce(@onUpdate, 1000)

        # add our listeners
        $(window).on('resize', @resize)
        
        Shortcuts.bind('ESCAPE', @switchToForm)

        @model = new AngellistExperience.Model()
            .on('alert', (error) => @switchToForm(error))
            .on('update', @onUpdate)
            .on('more', @switchToForm)
            .on('reset', @onReset)

        @model.roots.on('add', @onSearch)
    
    render: =>
        @$el.html(@template())

        # build the map
        @initializeMap()

        @form = new AngellistExperience.Form({el: @$el.find('.experience-form'), model: @model})
        @form.render()

        @header = new AngellistExperience.Header({el: @$el.find('.experience-header'), model: @model})
        @header.render()

        # show the form first
        @switchToForm()

        @

    ###
    private
    ###
    initializeMap: =>
        $map = @$el.find('.map')
        
        @map = new Map({el: $map, model: @model.mapModel})

        # gives us control of where new elements are placed
        # when expanding the map
        @placement = new LiquidPlacement({map: @map})
        @map.set('placement', @placement)
        
        # add our listeners
        @map.on('change:perspective', @renderPerspectiveMenu)
            .on('hold', @onMapHold)
            .on('load', @onMapLoad)
    
    resize: =>
        @map.resize()

    onSearch: (resource) =>
        @map.showMessage("Exploring #{resource.get('name')}...")

        @switchToMap()

    onUpdate: =>
        # first make the updates
        @updateMap()

        # hide the message once the updates are complete
        @map.hideMessage()

    updateMap: =>
        # add the new entities and maps
        currentAccount.expand(@model.blueprint)

        # update the session
        # TODO: these global current* references are killing me. need a better solution
        workspace = currentAccount.workspaces.at(0)

        window.currentWorkspace = workspace
        session?.currentWorkspace = workspace

        # set the workspace as the new source
        @map.load(new WorkspaceSource(workspace))

    onReset: =>
        # then clear and reinitialize the old map
        @$el.find('.map').empty()
        @initializeMap()

        # first show the form
        @switchToForm()

    switchToForm: (error) =>
        @$el.removeClass('active')
        @form.show(error)

    switchToMap: =>
        @$el.addClass('active')
        @form.hide()
        
        @map.focus()
    
    onMapHold: (event) =>
        component = event.component

        if component && component instanceof Node
            # position the new nodes around this one
            @placement.set('origin', component.position)

            # grab the original resource used to construct this element
            resource = component.entity.blueprint.resource

            # add it to the list
            @model.roots.add(resource)

    onMapLoad: =>
        # hide the modal alert
        # TODO: should this be an automatic behavior for the map?
        @map.hideMessage()

        # reset the placement so new searches are placed properly
        @placement.set('origin', null)

        # 1.5 seconds feels too long
        _.delay((=> @map.zoomFit()), 1200)


namespace 'AngellistExperience', (exports) ->
    exports.Experience = Experience