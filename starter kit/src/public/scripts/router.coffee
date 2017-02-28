define [
	'mixins/utils'
	'underscore'
	'backbone'
	'views/public/public'
], (Utils, _, Backbone, PublicView) ->
	
	AppRouter = Backbone.Router.extend {

		routes:
			'public' : 'public'
			'*actions': 'public'

		initialize: (options) ->

			# hook up to event aggregator
			@vent = options.vent

			@.on 'route:defaultAction', (actions) ->
				console.log "No route: #{ actions }"

			@.on 'route:public', ->
				# if there's already a view displayed, wipe it
				if @currentView
					@currentView.removeViewAndListeners()

				# initialize an instance of the view that was requested
				@currentView = new PublicView
					eventAggregator: @eventAggregator

				# render it
				@currentView.render()

			Backbone.history.start()
			
			console.log 'Router initialized'
	}

	_.extend AppRouter.prototype, Utils


	return AppRouter