require.config
	baseUrl: '../scripts/'
	waitSeconds: 10
	paths:
		jquery: '//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min'
		jqueryui: '//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min'
		underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min'
		backbone: '//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.2.1/backbone-min'
		text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text.min'
		bootstrap: '//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min'
		io: '//cdnjs.cloudflare.com/ajax/libs/socket.io/1.4.5/socket.io.min'
		moment: '//cdnjs.cloudflare.com/ajax/libs/moment.js/2.13.0/moment.min'
		jbox: '//cdnjs.cloudflare.com/ajax/libs/jBox/0.3.2/jBox.min'
		aggridenterprise: '../libs/ag-grid-enterprise/dist/ag-grid-enterprise.min'
	shim:
		bootstrap:
			deps: ['jquery']
		jbox:
			deps: ['jquery']

require ['views/app'], (App) ->
	window.App = new App()