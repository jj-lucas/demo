define [
	'jquery'
	'underscore'
	'backbone'
	'bootstrap'
	'mixins/utils'
], ($, _, Backbone, Bootstrap, Utils) ->
	
	BaseView = Backbone.View.extend

		# cache the container element
		el: '#content'

		# remove view more aggressively than remove()
		# handles backbone/jquery event listeners and Faye subscriptions
		removeViewAndListeners: () ->
			@$el.empty()
			@.stopListening()
			@.undelegateEvents()

			if @socket
				# stop listening on this channel
				# will restart from a different view if relevant
				@socket.removeAllListeners 'brief updates'
				
			return @


		# view helper to check user permission
		hasPermission: (permission) ->
			if (userPermissions.indexOf(permission) > -1)
				return yes
			else
				return no


		# render the view
		render: ->
			helpers =
				hasPermission: @hasPermission

			_.extend helpers, @

			# if this view has a collection, make it available to the template
			if @collection
				_.extend helpers,
					collection: @collection.toJSON()

			# if this view has a model, make it available to the template
			if @model
				_.extend helpers,
					model: @model.toJSON()

			parsedTemplate = _.template(@.template)(helpers)

			$(@el).html parsedTemplate
			@.trigger('rendered')

			return @

	_.extend BaseView.prototype, Utils

	return BaseView