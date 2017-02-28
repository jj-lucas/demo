require.config
	baseUrl: '../scripts/'
	waitSeconds: 10
	paths:
		jquery: '//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min'
		underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min'
		backbone: '//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.2.1/backbone-min'
		text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text.min'
		bootstrap: '//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min'
	shim:
		bootstrap:
			deps: ['jquery']

require ['views/app'], (App) ->
	window.App = new App()