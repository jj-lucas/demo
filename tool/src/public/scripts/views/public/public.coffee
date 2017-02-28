define [
	'views/base'
	'text!../../templates/public/public.html'
], (BaseView, ViewTemplate) ->

	Public = BaseView.extend {

		template: ViewTemplate

		events:
			'click button': (e) ->
				btn = $(e.target)

				$.ajax
					url: '/private'
					async: true
					type: 'get'

					success: (data, textStatus, xhr) ->
						console.log data

		initialize: (options) ->

			# setup event listeners
			@.listenTo @, 'rendered', @.afterRender


		afterRender: () ->

			console.log 'Rendered'
	}
	
	return Public