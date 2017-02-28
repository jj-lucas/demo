define [
	'jquery'
	'underscore'
	'backbone'
	'bootstrap'
	'mixins/utils'
	'moment'
], ($, _, Backbone, Bootstrap, Utils, moment) ->

	Brief = Backbone.Model.extend {
		
		idAttribute: '_id'

		initialize: ->
			@.on 'change', =>
				@.save()

		save: ->

			# update timestamp
			@.set 'lastUpdatedAt', moment().format('MMMM Do YYYY, h:mm:ss a'),
				# silent won't trigger change event
				silent: yes

			# put updated brief in the DB
			$.ajax
				url: '/brief/' + @.get '_id'
				type: 'put'
				crossDomain: true
				async: true
				data:
					brief:
						@.toJSON()

				statusCode:
					500: (xhr) ->
						console.log xhr

	}

	_.extend Brief.prototype, Utils
	
	return Brief