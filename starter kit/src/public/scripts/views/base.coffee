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

			if @subscription?
				# unsubscribe from Faye channel
				@subscription.cancel()
				
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

			parsedTemplate = _.template(@.template)(helpers)

			$(@el).html parsedTemplate
			@.trigger('rendered')

			return @

	_.extend BaseView.prototype, Utils

	return BaseView