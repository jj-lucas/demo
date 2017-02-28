define [
	'views/base'
	'text!../../templates/briefs/briefs.html'
	'bootstrap'
	'collections/briefs'
], (BaseView, ViewTemplate, bootstrap, BriefsCollection) ->

	Briefs = BaseView.extend {

		template: ViewTemplate

		events:
			'click .navbar .nav-pills li': (e) ->
				$pill = $(e.target).parent()
				$pill.toggleClass 'active'
				# handle hiding / unhiding of briefs
				@filterBriefs()

			'keyup .navbar .js-search-box': (e) ->
				$searchbox = $(e.target)
				@searchBriefs $searchbox.val().toLowerCase()

			'click .js-new-brief': (e) ->
				@modalNew.modal 'show'

			'click .js-edit-brief': (e) ->
				id = $(e.target).closest('tr').data 'id'
				model = @collection.get id
				@modalEdit.find('.js-edit-brief-name').val model.get('name')
				@modalEdit.find('.js-edit-brief-type').val model.get('type')
				@modalEdit.modal 'show'
				@modalEdit.data 'id', id

			'click .js-delete-brief': (e) ->
				id = $(e.target).closest('tr').data 'id'
				model = @collection.get id
				@modalDelete.modal 'show'
				@modalDelete.data 'id', id

			'click .js-clone-brief': (e) ->
				id = $(e.target).closest('tr').data 'id'
				model = @collection.get id

				clone = model.toJSON()

				clone.name += ' copy'

				$.ajax
					url: '/brief'
					async: false
					type: 'post'
					crossDomain: true
					data: clone

					success: (data, textStatus, xhr)->
						# refresh list
						location.reload()

			'click #popup-new .js-new-brief-confirm': (e) ->
				name = @modalNew.find('.js-new-brief-name').val()
				type = @modalNew.find('.js-new-brief-type').val()

				$.ajax
					url: '/brief'
					async: false
					type: 'post'
					crossDomain: true
					data:
						name: name
						type: type

					success: (data, textStatus, xhr)->
						# refresh list
						location.reload()

			'click #popup-edit .js-edit-brief-confirm': (e) ->
				id = @modalEdit.data 'id'

				name = @modalEdit.find('.js-edit-brief-name').val()
				type = @modalEdit.find('.js-edit-brief-type').val()

				model = @collection.get id

				model.set 'name', name
				model.set 'type', type

				$.ajax
					url: '/brief/' + id
					async: false
					type: 'put'
					crossDomain: true
					data:
						brief:
							model.toJSON()

					success: (data, textStatus, xhr) ->
						# refresh list
						location.reload()

			'click #popup-delete .js-delete-brief-confirm': (e) ->
				id = @modalDelete.data 'id'

				$.ajax
					url: '/brief/' + id
					async: false
					type: 'delete'
					crossDomain: true

					success: (data, textStatus, xhr) ->
						# refresh list
						location.reload()


		initialize: (options) ->
			# setup event listeners
			@.listenTo @, 'rendered', @.afterRender


		searchBriefs: (searchPhrase) ->
			# iterate through briefs
			$('#briefs .brief').each (b, brief) ->
				# look for the searchphrase among the brief names
				if $(brief).data('name').toLowerCase().indexOf(searchPhrase) isnt -1
					# unhide positive matches
					$(brief).removeClass('noresult')
				else
					# hide negative matches
					$(brief).addClass('noresult')


		filterBriefs: ->
			$('.nav-pills li').each (l, li) ->
				if $(li).hasClass 'active'
					$("#briefs").addClass $(li).data('type')
				else
					$("#briefs").removeClass $(li).data('type')


		afterRender: ->
			@filterBriefs()

			@modalNew = $('#popup-new').modal
				show: no

			@modalEdit = $('#popup-edit').modal
				show: no

			@modalDelete = $('#popup-delete').modal
				show: no

			@modalNew.on 'hidden.bs.modal', (e) =>
				# make sure name field stays empty
				@modalNew.find('.js-new-brief-name').val ''

	}
	
	return Briefs