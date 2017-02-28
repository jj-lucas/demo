define [
	'views/base'
	'models/brief'
	'text!../../templates/brief/brief.html'
	'text!../../templates/brief/item.html'
	'text!../../templates/brief/boxes/image1col.html'
	'text!../../templates/brief/boxes/image2cols.html'
	'text!../../templates/brief/boxes/image3cols.html'
	'text!../../templates/brief/boxes/spacer30px.html'
	'text!../../templates/brief/boxes/disclaimer.html'
	'text!../../templates/brief/boxes/ampScript3prods.html'
	'text!../../templates/brief/markup/template-fix-header-footer.html'
	'text!../../templates/brief/overlay.html'
	'mixins/settings'
	'mixins/utils'
	'aggridenterprise'
	'jbox'
	'jqueryui'
], (BaseView, BriefModel, ViewTemplate, ItemTemplate, Image1Col, Image2Cols, Image3Cols, Spacer30Px, Disclaimer, AmpScript3Prods, TemplateFixHeader, OverlayTemplate, Settings, Utils, agGridEnterprise) ->

	BriefView = BaseView.extend

		template: ViewTemplate

		model: BriefModel

		# the folder of images will change for every 1000 pics
		# it follows a sequiential order
		# at the first request, we will look through all until we find a match
		startingImageFolder: 11

		events:
			# click on a sidebar button to add a box
			'click .sidebar button.add-box': (e) ->
				$btn = $(e.target)
				type = $btn.data 'box'

				model = new Box
					type: type

				$container = $('.canvas')

				@addBox($container, model)

			# doubleclick a box to open the configurations overlay
			'dblclick .canvas .box': (e) ->

				# get box ID
				boxId = $(e.target).closest('li.box').data 'cid'

				# configure the config overlay and open it
				@openBoxSettingsOverlay boxId
				

			'click .box button.remove': (e) ->
				$btn = $(e.target)
				$box = $btn.closest '.box'
				$box.remove()

				@stashChanges()

			'change .sidebar #market-to-preview': (e) ->

				# get market to switch to
				@currentMarket = $(e.target).val()

				# update the boxes by pulling images from the new folder
				@displayBoxes()

			'change .sidebar #image-folder': (e) ->

				# store the updated value
				@model.set 'imageFolder', $(e.target).val()

				# craft URLs for the new image folder
				@rewriteImages()

			'change .sidebar #assignee': (e) ->

				# store the updated value
				@model.set 'assignee', $(e.target).val()

			'click .sidebar button.parse-email': (e) ->

				@openDeploymentOverlay()

			'click .js-edit-brief': (e) ->
				@modalEdit.find('.js-edit-brief-name').val(@model.get('name'))
				@modalEdit.find('.js-edit-brief-type').val(@model.get('type'))
				@modalEdit.modal 'show'
				@modalEdit.data 'id', @model.get 'id'

			'click #popup-edit .js-edit-brief-confirm': (e) ->
				id = @modalEdit.data 'id'

				name = @modalEdit.find('.js-edit-brief-name').val()
				type = @modalEdit.find('.js-edit-brief-type').val()

				@model.set 'name', name
				@model.set 'type', type

				location.reload()


		# open and setup the box configuration overlay
		openBoxSettingsOverlay: (id) ->

			# retrieve model based on box ID
			model = @boxes.get id
			
			type = model.get('type')

			attributes = _.extend model.toJSON(),
				specs  : @settings.specs[type]
				markets: @settings.markets

			try
				# parse overlay markup based on model
				markup = _.template(OverlayTemplate) attributes
			catch e
				console.log 'Overlay parsing fucked up'
			

			# setup overlay
			@boxSettingsOverlay.setContent(markup)
			@boxSettingsOverlay.cid = id

			# autofill known fields
			$content = @boxSettingsOverlay.content

			# autofill images
			images = @settings.specs[type].image
			
			if images?
				
				for image, f in images
					
					if (model.get(image)?)

						###
						TO-DO
						Improve dat shit
						###
						if model.get(image).isGif isnt 'false' and  model.get(image).isGif isnt false
							isGif = true
						else
							isGif = false
						###
						END TO-DO
						###

						$content.find('input[data-image=' + image + ']').val(model.get(image).fragment)
						$content.find('input[data-gif=' + image + ']').attr('checked', isGif)


			# ..ooOOPEN!
			@boxSettingsOverlay.open()
			# yap, that was a BL2 reference

			# autofill text lines
			@autofillBoxSettingsOverlayField $content, model, type, 'copy'

			# autofill links
			@autofillBoxSettingsOverlayField $content, model, type, 'link'

			# autofill links
			@autofillBoxSettingsOverlayField $content, model, type, 'alttext'

			# autofill generic settings
			genericSettings = @settings.specs[type].generic

			if genericSettings?
				
				for setting, f in genericSettings
					
					if (model.get(setting)?)
						$content.find('input[data-generic=' + setting + ']').val(model.get(setting))


		# open and setup the email deployment overlay
		openDeploymentOverlay: () ->

			# prepare a fake element to hold box until we note the markdown down
			$tempContainer = $('<div><ul></ul></div>')

			# reassemble the brief from the stashed board
			stashedBoard = @model.get 'stashedBoard'
			for box, b in stashedBoard
				model = new Box box
				@addBox($tempContainer, model, yes, 'deployment')

			# prepare a container for the markup of the boxes
			markup = new String()

			that = @

			# AMP Script variables
			ampScriptVars = new Object()

			# iterate through markets
			for market in @settings.markets

				# prepare a container for each
				ampScriptVars[market] = new Object()


			# iterate through pseudo elements
			$tempContainer.find('ul li').each (b, box) ->

				contentId = $(box).data('cid')

				# get the data model behind
				model = that.boxes.get contentId

				# get the specs for this type of box
				specs = that.settings.specs[model.get('type')]

				# iterate through available settings of this type of box
				for key, value of specs

					# ignore the placeholders
					if key isnt 'placeholders'

						# iterate the various labels
						for variable in specs[key]

							# eg. c24_img3
							name = contentId + '_' + variable

							# iterate through markets
							for market in that.settings.markets

								if model.get(variable)? and model.get(variable)[market]? and model.get(variable)[market] isnt ''
									# this value / string is defined
									ampScriptVars[market][name] = model.get(variable)[market]
								else if model.get(variable)? and model.get(variable)[market]? and model.get(variable)[market] is ''
									ampScriptVars[market][name] = ''
								else if model.get(variable)?
									ampScriptVars[market][name] = model.get(variable)
								else
									ampScriptVars[market][name] = ''

				# destroy the preview UI elements
				$(box).find('button').remove()

				# wrap the table to be able to print itself
				markup +=  $(box).html()

			console.log ampScriptVars

			# we're done here, wipe the fake container
			$tempContainer.remove()

			ampScripting = '\nIF @customerCountry != "lalala" '

			for market in @settings.markets
				ampScripting += 'AND @customerCountry != "' + market.toUpperCase() + '" '

			ampScripting += 'THEN @customerCountry = "GB"\n\n'

			# prepare the AMPScript block
			ampScripting += '\nIF 1 == 2 THEN SET @a = 1'

			# iterate through markets
			for market in @settings.markets

				ampScripting += '\nELSEIF @customerCountry == "' + market.toUpperCase() + '" THEN'

				# iterate through vars for this country
				for key, value of ampScriptVars[market]
					ampScripting += '\n\tSET @' + key + ' = "' + @utils.sanitizeString(value) + '"'

			# wrap outro if
			ampScripting += '\nENDIF'

			# setup overlay
			@deploymentOverlay.setContent('<textarea>')

			# autofill known fields
			$content = @deploymentOverlay.content

			parsedContent = TemplateFixHeader.replace(/_CONTENT-GOES-HERE_/g, markup).replace(/_AMP-SCRIPT-FROM-TOOL_/g, ampScripting)
			# .replace(/\s\s+/g, '')

			$content.find('textarea').val parsedContent

			# ..ooOOPEN!
			@deploymentOverlay.open()
			# yap, that was a BL2 reference


		autofillBoxSettingsOverlayField: ($content, model, boxType, fieldType) ->

			fieldsToFill = @settings.specs[boxType][fieldType]

			if fieldsToFill?

				# get grid container
				selector = '#grid-' + fieldType
				$gridContainer = $content.find(selector)
				gridContainer = $gridContainer[0]

				# set grid options
				gridOptions =
					rowData: new Array()
					columnDefs: [
						{
							headerName: 'id'
							field: 'type'
							hide: yes
						}
						{
							headerName: 'field'
							field: 'label'
							minWidth: 100
							suppressMenu: yes
						}
					]

					# fired whenever we change a cell value
					onCellValueChanged: (event) ->
						console.log 'onCellValueChanged'
						renderedNodes = event.api.getRenderedNodes()

						for node, n in renderedNodes
							data = node.data
							
							type = data.type

							delete data.type
							delete data.label

							model.set type, data

					onGridReady: (params) ->
						params.api.sizeColumnsToFit()

					singleClickEdit: no

				# for each field we expect to find
				for field, f in fieldsToFill
					
					row =
						type: field
						label: @settings.specs[boxType].labels[field]

					_.extend row, model.get field

					gridOptions.rowData.push row

				$gridContainer.css('height', (gridOptions.rowData.length + 1) * 25)

				for market, m in @settings.markets
					column =
						headerName: market
						field: market
						editable: yes
						suppressMenu: yes
						enableCellChangeFlash: yes

					gridOptions.columnDefs.push column
					
				# build grid
				grid = new agGridEnterprise.Grid(gridContainer, gridOptions)





			###
			fieldsToFill = @settings.specs[boxType][fieldType]

			if fieldsToFill?

				# for each field we expect to find
				for field, f in fieldsToFill

					# if this property is defined for this box
					if model.get(field)

						holder = model.get field

						if holder?
						
							for market, m in @settings.markets

								# check if any lang is defined
								if (holder[market]?)
									$content.find('input[data-' + fieldType + '=' + field + '][data-market=' + market + ']').val(holder[market])
			###


		parseBoxSettingsOverlay: (overlay) ->
			# parse data in overlay and update model if necessary
			model = @boxes.get overlay.cid

			# cache markup of overlay
			$content = overlay.content

			# extract data from the markup of hte overlay

			# handle images
			imageFields = $content.find('input[type="text"][data-image]')

			for image, i in imageFields
				imageId = $(image).data('image')
				fragment = $(image).val()
				isGif = $content.find('input[data-gif="'+imageId+'"]').is(':checked')

				model.set imageId, @craftURLs(fragment, isGif)

			# handle generic settings
			genericSettings = $content.find('input[type="text"][data-generic]')

			for setting, i in genericSettings
				id = $(setting).data('generic')
				value = $(setting).val()

				model.set id, value

			@stashChanges()

		###

		parseNationalizedField: ($content, model, fieldType) ->

			deferred = $.Deferred()

			holder = new Object()

			fields = $content.find('input[data-' + fieldType + ']')

			for field, l in fields
				$field = $(field)
				fieldId = $field.data(fieldType)
				market = $field.data('market')
				fieldValue = $field.val()

				if model.get(fieldId)?
					holder = model.get(fieldId)
				else
					holder = new Object()

				holder[market] = fieldValue

				model.set fieldId, holder

				deferred.resolve()

			if not fields.length
				deferred.resolve()

			deferred

		###


		rewriteImages: () ->

			# reassemble the brief from the stashed board
			stashedBoard = @model.get 'stashedBoard'

			# console.log @boxes

			$('.canvas ul li').each (b, box) =>
				id = $(box).data 'cid'
				box = @boxes.get id

				# get type of box
				type = box.get 'type'

				# get images, if any
				if @settings.specs[type].hasOwnProperty 'image'
				
					images = @settings.specs[type].image

					for imageId, i in images
						fragment = box.get(imageId).fragment
						isGif = box.get(imageId).isGif

						console.log box.get(imageId)

						box.set imageId, @craftURLs(fragment, isGif)

			@stashChanges()



		craftURLs: (fragment, isGif) ->

			imagePaths =
				fragment: fragment
				isGif: isGif

			if @model.get('imageFolder')
				latestKnownImageFolder =  @model.get 'imageFolder'
			else
				latestKnownImageFolder =  @settings.imageFolder

			if fragment

				# we're gonna iterate market by market
				for market, m in @settings.markets

					# craft URL
					url = @settings.urlPreamble + latestKnownImageFolder + '/' + fragment + '-' + market

					if isGif is true or isGif is 'true'
						url += '.gif'
					else
						url += '.jpg'

					# latestKnownImageFolder is the URL part we need
					imagePaths[market] =  url

			return imagePaths


		checkIfImageExists: (url) ->

			deferred = $.Deferred()

			$.ajax
				url: '/image-scanner/'
				type: 'get'
				crossDomain: true
				async: true
				data:
					url: url

				success: (found) ->
					deferred.resolve found

				statusCode:
					500: (xhr) ->
						console.log xhr

			deferred


		initialize: (options) ->

			# by default we start with the first market among the settings
			@currentMarket = @settings.markets[0]

			@socket = options.socket

			# setup event listeners
			@.listenTo @, 'rendered', @.afterRender

			@boxes = new Boxes()

			@socket.on 'brief updates', (data) =>

				if data._id is @model.get '_id'
					if data.lastUpdatedAt isnt @model.get 'lastUpdatedAt'
						console.log '*** BRIEF UPDATE INCOMING ***'
						location.reload()
		

		afterRender: ->

			# list available languages in sidebar
			for market, m in @settings.markets

				# make option
				$option = $('<option>' + market + '</option>')
				$option.attr 'value', market

				# add it to the select box
				$('.sidebar #market-to-preview').append $option

			# show the brief type in sidebar settings
			$('.sidebar #brief-type').val @model.get('type')

			# show the brief assignee in sidebar settings
			$('.sidebar #assignee').val @model.get('assignee')

			# if this brief has a specific image folder defined
			if @model.get('imageFolder')
				# use that one
				$('.sidebar #image-folder').val @model.get('imageFolder')
			else
				# otherwise pull it from the defaults
				$('.sidebar #image-folder').val @settings.imageFolder

			@modalEdit = $('#popup-edit').modal
				show: no

			# only make boxes sortable / settings changeable if the user has permissions
			if @canEditBriefType @model
					
				# set up drag drop behavior of canvas
				$('.canvas ul').sortable
					stop: =>
						@stashChanges()

				# set up the edit overlay
				that = @
				@boxSettingsOverlay = new jBox 'Modal',
					minWidth: 1000
					minHeight: 300
					maxHeight: 600
					onClose: ->
						# don't parse the whole brief, just parse the overlay itself
						that.parseBoxSettingsOverlay(@)

				@deploymentOverlay = new jBox 'Modal',
					minWidth: 600
					minHeight: 300
					maxHeight: 600

			# display boxes
			@displayBoxes()


		canEditBriefType: (model) ->

			canEdit = no

			switch model.get('type')

				when 'weekly'
					if @hasPermission('canEditWeekly')
						canEdit = yes
						break

				when 'retail'
					if @hasPermission('canEditRetail')
						canEdit = yes
						break

				when 'trigger'
					if @hasPermission('canEditTrigger')
						canEdit = yes
						break

			canEdit
			

		displayBoxes: ->

			$container = $('.canvas')
			$container.find('ul').empty()

			# reassemble the brief from the stashed board
			stashedBoard = @model.get 'stashedBoard'
			for box, b in stashedBoard
				model = new Box box
				@addBox($container, model, yes)


		addBox: ($container, box, silenced = no, renderingMode = 'preview') ->

			# careful with this. It could generate bugs!
			@boxes.add box

			briefType = @model.get('type')

			$container.find('ul').append box.render(@currentMarket, briefType, renderingMode)

			# use silenced when you don't wanna fire a brief edit event
			# eg. when adding boxes to the canvas when loading a brief
			if not silenced
				@stashChanges()


		stashChanges: ->

			boxList = new Boxes()

			$('.canvas ul li').each (b, box) =>
				id = $(box).data 'cid'
				box = @boxes.get id
				boxList.add box

			@boxes = boxList

			@model.set 'stashedBoard', @boxes.toJSON()

			##
			# HOTFIX
			# change event not firing if you change a property of an attribute
			##
			@model.trigger 'change', @model
			@displayBoxes()
			##
	

	Box = Backbone.Model.extend

		modules:
			image1col       : Image1Col
			image2cols      : Image2Cols
			image3cols      : Image3Cols
			spacer30px      : Spacer30Px
			disclaimer      : Disclaimer
			ampScript3prods : AmpScript3Prods

		initialize: (options) ->
			@.on 'change', =>
				$('.canvas ul').find('li[data-cid='+@.cid+']').html @render()


		# view helper to check user permission
		hasPermission: (permission) ->
			if (userPermissions.indexOf(permission) > -1)
				return yes
			else
				return no

		render: (market = @settings.markets[0], briefType, renderingMode) ->
			
			type = @.get('type')

			attributes =  _.extend @.toJSON(),
				specs: @settings.specs[type]
				market: market
				cid: @.cid
				renderingMode: renderingMode
				sanitizeString: @utils.sanitizeString

			# parse the markup of the box
			markup = _.template(@modules[@.get 'type'])(attributes)

			attributes = _.extend @,
				briefType : briefType

			# parse the markup of the container that we use in the brief
			container = _.template(ItemTemplate.replace(/_CONTENT_/g, markup))(attributes)


	Boxes = Backbone.Collection.extend
		model: Box


	_.extend BriefView.prototype, Settings
	_.extend BriefView.prototype, Utils
	_.extend Box.prototype, Settings
	_.extend Box.prototype, Utils

	return BriefView