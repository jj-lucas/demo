define [
	'mixins/utils'
	'backbone'
	'router'
], (Utils, Backbone, Router) ->

	AppView = Backbone.View.extend

		el: '#translations-bank'

		# set up an event aggregator for publishing / subscribing to notifications
		eventAggregator: _.extend {}, Backbone.Events
		# you are now thinking about alligators

		initialize: ->

			# animate version name
			@utils.animateCaption 'MK-0 \'Version name\'', $('.versionName').first(), 20

			# set up a global interceptor for failed Ajax calls
			$(document).ajaxError (event, jqXHR) ->

				# check the HTTP status code
				switch jqXHR.status

					# 401 Unauthorized
					when 401
						# sorry kiddo, no can't do!
						window.location = '/login'
						break

					when 500
						console.log '%c'+jqXHR.responseText, 'color: #800000'

			# set up the router
			router = new Router
				eventAggregator: @eventAggregator

	_.extend AppView.prototype, Utils

	return AppView