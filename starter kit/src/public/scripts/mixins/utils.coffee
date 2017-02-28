define ->
	
	Utils =

		logColors:
			go: '#008000'
			nogo: '#800000'

		ping: () ->
			alert 'Ping!'
			return

		# fancy version name
		animateCaption: (name, container, freq) ->

			nameCharsSequence = new Array
			displayedCharsSequence = new Array
			displayedString = new String

			a = 0
			al = name.length

			while a < al
				nameCharsSequence.push name.charCodeAt a
				a++

			captionTimer = setInterval(( ->
				step()
			), freq)
			
			step = ->
				if displayedString.length < name.length					# add char
					randomASCII = Math.floor(Math.random() * 90) + 33

					displayedCharsSequence.push randomASCII

				displayedString = new String
				
				b = 0
				bl = displayedCharsSequence.length

				while b < bl
					if displayedCharsSequence[b] > nameCharsSequence[b]
						displayedCharsSequence[b]--

					else if displayedCharsSequence[b] < nameCharsSequence[b]
						displayedCharsSequence[b]++

					charToAdd = String.fromCharCode(displayedCharsSequence[b])

					# replace special chars into entities
					charToAdd = charToAdd.replace(RegExp('[\u00A0-\u9999<>\&]', 'gim'), (r) ->
						'&#' + r.charCodeAt 0 + ';'
					)

					displayedString += charToAdd

					b++

				container.html displayedString

				if displayedString is name
					window.clearInterval captionTimer

			return

		go: (go, stuff) ->

			# calculate elapsed time since t0
			# t = new Date
			# diff = (t - bank.t0) / 1000
			#log = diff.toFixed(1) + ' - ' + stuff

			log = stuff

			# make it like in dze movies
			if go
				#$.get 'http://jjtechtoys.dk:3000/go/' + log, (data) ->
				#	console.log '%c'+data, 'color: '+ Utils.logColors.go
				console.log '%c'+log, 'color: '+ Utils.logColors.go

			else
				#$.get 'http://jjtechtoys.dk:3000/nogo/' + log, (data) ->
				#	console.log '%c'+data, 'color: '+ Utils.logColors.nogo
				console.log '%c'+log, 'color: '+ Utils.logColors.nogo
				#	Utils.abort data
				Utils.abort log

			return

		abort: (lastLog) ->

			$abort = $('#abort')

			# ya, someone played too much Borderlands
			$abort.show()

			# log lastLog error to DB
			# TO-DO

			console.log 'ABORT! ABORT! ABORT!'

			pulsateAbort = ->
				$abort
					.animate { opacity: 1}, 200
					###
					.animate { opacity: 0.8 }, 1000 , ->
						pulsateAbort()
					###

			pulsateAbort()

			return

	return {
		utils: Utils
	}