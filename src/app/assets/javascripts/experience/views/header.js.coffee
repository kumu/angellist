class Header extends Backbone.View
    template: JST['experience/templates/header']
    
    events:
        'click .more': 'more'
        'click .reset': 'reset'

    initialize: =>
        @model.on('change:summary', @updateSummary)

    render: =>
        @$el.html(@template())

        @renderPerspectiveMenu()

        @

    ###
    private
    ###
    updateSummary: =>
        $summary = @$el.find('.summary')
        $summary.html(@model.get('summary'))

    more: =>
        @model.trigger('more')

    reset: =>
        @model.reset()

    # this method is called every time the perspective is changed
    renderPerspectiveMenu: =>
        $perspectives = $('.perspectives').empty()

        # build the UI
        # this should be the responsibility of another class
        for perspective in currentAccount.perspectives.models
            $perspectives.append(@renderPerspectiveLink(perspective))
    
    renderPerspectiveLink: (perspective) =>
        $perspective = $('<li />')
            .addClass('perspective')
            .toggleClass('active', perspective is @model.mapModel.get('perspective'))
            .html(perspective.get('name'))
            .on('click', =>
                @model.mapModel.set('perspective', perspective)
                @model.mapModel.refresh() # why not make this automatic on change:perspective?
            )


namespace 'AngellistExperience', (exports) ->
    exports.Header = Header