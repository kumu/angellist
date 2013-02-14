###
A Resource is a lightweight description of a remote object, generally
identified by a type, id, and some sort of description such as a
label or name.

Resources should describe the resource as it exists remotely
(eg use MarketTag type even though we prefer Market for element type)
###
class Resource extends Backbone.Model
	defaults: ->
		type: null
		id: null
		name: null


class ResourceCollection extends Backbone.Collection
	model: Resource


namespace 'AngellistExperience', (exports) ->
	exports.Resource = Resource
	exports.ResourceCollection = ResourceCollection