define [
	'views/base'
	'text!../../templates/XXXXX/XXXXX.html'
], (BaseView, ViewTemplate) ->

	ViewName = BaseView.extend {

		template: ViewTemplate
	}
	
	return ViewName