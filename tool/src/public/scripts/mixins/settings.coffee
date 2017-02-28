define ->
	
	Settings =

		markets:
			['dk', 'nl', 'be', 'ie', 'gb', 'fi', 'fr', 'de', 'at', 'ch', 'it', 'no', 'es', 'sv']

		urlPreamble: 'http://image.e.jackjones.com/lib/fe9d13727764027c75/m/'

		imageFolder: 11

		specs:
			image1col:
				placeholders:
					img1: 'http://placehold.it/600x700'
				labels:
					img1: 'Image 1'
					link1: 'Link 1'
					alt1: 'Alt text 1'
				image: ['img1']
				link: ['link1']
				alttext: ['alt1']

			image2cols:
				placeholders:
					img1: 'http://placehold.it/300x455'
					img2: 'http://placehold.it/300x455'
				labels:
					img1: 'Image 1'
					img2: 'Image 2'
					link1: 'Link 1'
					link2: 'Link 2'
					alt1: 'Alt text 1'
					alt2: 'Alt text 2'
				image: ['img1','img2']
				link: ['link1','link2']
				alttext: ['alt1','alt2']

			image3cols:
				placeholders:
					img1: 'http://placehold.it/200x240'
					img2: 'http://placehold.it/200x240'
					img3: 'http://placehold.it/200x240'
				labels:
					img1: 'Image 1'
					img2: 'Image 2'
					img3: 'Image 3'
					link1: 'Link 1'
					link2: 'Link 2'
					link3: 'Link 3'
					alt1: 'Alt text 1'
					alt2: 'Alt text 2'
					alt3: 'Alt text 3'
				image: ['img1','img2','img3']
				link: ['link1','link2','link3']
				alttext: ['alt1','alt2','alt3']

			disclaimer:
				placeholders:
					paragraph: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a semper mauris. Quisque sapien tellus, tristique eu pellentesque eget, ullamcorper ac arcu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'
				labels:
					paragraph: 'Paragraph'
				copy: ['paragraph']

			spacer30px:
				placeholders: null

			ampScript3prods:
				placeholders: null
				labels:
					style1: "Style ID 1"
					style2: "Style ID 2"
					style3: "Style ID 3"
				generic: ['style1', 'style2', 'style3']



	return {
		settings: Settings
	}