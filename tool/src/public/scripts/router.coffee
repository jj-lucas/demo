define [
	'mixins/utils'
	'underscore'
	'backbone'
	'views/public/public'
	'views/briefs/briefs'
	'collections/briefs'
	'models/brief'
	'views/brief/brief'
	'io'
	'views/aggridtest/aggridtest'
], (Utils, _, Backbone, PublicView, BriefsView, BriefsCollection, BriefModel, BriefView, io, AgGridTest) ->
	
	AppRouter = Backbone.Router.extend {

		routes:
			'public' : 'public'
			'' : 'briefs'
			'brief/:id' : 'brief'
			'aggridtest' : 'aggridtest'
			'*actions': 'defaultAction'

		initialize: (options) ->

			# hook up to event aggregator
			@vent = options.vent

			socket = io window.location.origin

			@.on 'route:defaultAction', (actions) ->
				console.log "No route: #{ actions }"

			@.on 'route:public', ->
				# if there's already a view displayed, wipe it
				if @currentView
					@currentView.removeViewAndListeners()

				# initialize an instance of the view that was requested
				@currentView = new PublicView
					socket: socket

				# render it
				@currentView.render()

			@.on 'route:briefs', ->
				# if there's already a view displayed, wipe it
				if @currentView
					@currentView.removeViewAndListeners()

				dfdGetBriefs = @getBriefs()

				# async load briefs
				$.when(dfdGetBriefs).then (data) =>
					# create a collection based on the data retireved
					briefs = new BriefsCollection data

					# initialize an instance of the view that was requested
					@currentView = new BriefsView
						socket: socket
						collection: briefs

					# render it
					@currentView.render()

			@.on 'route:brief', (id) ->
				# if there's already a view displayed, wipe it
				if @currentView
					@currentView.removeViewAndListeners()

				dfdGetBrief = @getBrief(id)

				# async load briefs
				$.when(dfdGetBrief).then (data) =>

					# initialize an instance of the view that was requested
					@currentView = new BriefView
						socket: socket
						model: new BriefModel(data)

					# render it
					@currentView.render()

			@.on 'route:aggridtest', (id) ->
				# if there's already a view displayed, wipe it
				if @currentView
					@currentView.removeViewAndListeners()

				# initialize an instance of the view that was requested
				@currentView = new AgGridTest
					socket: socket

				# render it
				@currentView.render()

			Backbone.history.start()
			
			console.log 'Router initialized'
		

		# retrieve briefs from the DB
		getBriefs: ->
			deferred = $.Deferred()

			# pull briefs from DB
			$.ajax
				url: '/briefs'
				async: false
				type: 'get'
				crossDomain: true
				success: (data, textStatus, xhr) ->
					deferred.resolve data

			deferred


		# retrieve briefs from the DB, by ID
		getBrief: (id) ->
			deferred = $.Deferred()

			# pull briefs from DB
			$.ajax
				url: '/brief/' + id
				async: false
				type: 'get'
				crossDomain: true
				success: (data, textStatus, xhr) ->
					deferred.resolve data

			deferred

	}

	_.extend AppRouter.prototype, Utils


	return AppRouter