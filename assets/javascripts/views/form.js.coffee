class Form extends Backbone.View
	className: 'experience-form'
	template: JST['assets/javascripts/templates/form']
	
	events:
		'submit form': 'onSubmit'
		'click .match': 'exploreMatch'
		'click .reset': 'reset'
	
	initialize: =>
		@matches = new Backbone.Collection()
		
		# @model.on('reset', @reset)
	
	show: =>
		@reset()
		@$el.fadeIn()

	hide: =>
		@$el.fadeOut()

	render: =>
		@$el.html(@template())
		
		@$error = @$el.find('.error')
		@$input = @$el.find('input')
		@$matches = @$el.find('.matches')
		
		@
	
	reset: =>
		# cleanup state
		@$el.removeClass('pending matched')
		@$error.empty()
		@$matches.empty()
		
		# reset input and refocus
		@$input.val('').focus()
	
	###
	private
	###
	onSubmit: (event) =>
		@$el.addClass('pending')
		
		query = $.trim(@$input.val())
		
		$.getJSON("https://api.angel.co/1/search?query=#{encodeURIComponent(query)}&callback=?")
			.done((results) => @processSearchResults(query, results))
			.fail(=> @$el.trigger('show', 'Search failed. Please try again.'))
			.always(=> @$el.removeClass('pending'))
		
		false
	
	processSearchResults: (query, results) =>
		if results.length == 0
			@error('No matches found. Try again!')
		else
			@$el.addClass('matched')
			# should load immediately on direct match to name (or slug?)
			
			# &amp; only one giving us a problem for now
			decode = (string) -> string.replace(/&amp;/g, '&')
			
			# only show the top three matches
			for match in results[0..2]
				context = {name: decode(match.name), image: match.pic}
				
				if context.image
					context.image = "https://angel.co#{context.image}" if context.image?[0] == "/" # relative image path
				else
					context.image = if match.type == 'User' then 'https://angel.co/images/nopic.png' else ''
				
				$match = $(JST['assets/javascripts/templates/match'](context))
					.appendTo(@$matches)
					.data('match', match)
	
	exploreMatch: (event) =>
		data = $(event.currentTarget).data('match')
		resource = new AngellistExperience.Resource(data)

		log.fatal('exploring', resource)

		@model.roots.add(resource)
		
		false
	
	error: (message) =>
		@$error.html(message).show()


namespace 'AngellistExperience', (exports) ->
	exports.Form = Form