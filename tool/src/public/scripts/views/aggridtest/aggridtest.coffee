define [
	'views/base'
	'text!../../templates/aggridtest/aggridtest.html'
	'aggridenterprise'
], (BaseView, ViewTemplate, agGridEnterprise) ->

	ViewName = BaseView.extend {

		template: ViewTemplate

		initialize: (options) ->

			# setup event listeners
			@.listenTo @, 'rendered', @.afterRender

		afterRender: ->

			gridContainer = $('#table')[0]

			gridOptions =
				rowData: new Array()
				columnDefs: [
					{
						headerName: 'Name'
						field: 'name'
						editable: true
					}
					{
						headerName: 'Type'
						field: 'type'
						headerClass: 'banana'
						editable: true
					}
				]

				onCellValueChanged: (event) ->
					console.log 'onCellValueChanged'
					console.log event

			d = 0
			while d < 5
				gridOptions.rowData.push
					id: d
					name: d
					type: 'a'
				d++

			grid = new agGridEnterprise.Grid(gridContainer, gridOptions)

			console.log gridOptions.api.getRenderedNodes()
	}
	
	return ViewName