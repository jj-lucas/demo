define [
	'jquery'
	'underscore'
	'backbone'
	'bootstrap'
	'mixins/utils'
	'models/brief'
], ($, _, Backbone, Bootstrap, Utils, brief) ->

	Briefs = Backbone.Collection.extend {
		
		model: brief

		# sorting strategy based on models 'position' attribute
		comparator: (a) ->
			return a.get 'name'
	}

	_.extend Briefs.prototype, Utils
	
	return Briefs