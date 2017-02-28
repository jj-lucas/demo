request = require 'request'
util = require 'util'
bodyParser = require 'body-parser'
ObjectId = require('mongodb').ObjectID

module.exports = (app, passport, db, io) ->

	# =====================================
	# HOME PAGE (with login links) ========
	# =====================================
	app.get '/', isLoggedIn, (req, res) ->
		res.render 'index.ejs',
			message: req.flash('loginMessage')
			user: req.user


	app.get '/private', isLoggedIn, hasPermission('random'), (req, res) ->
		res.send '** private content **'


	# =====================================
	# LOGIN ===============================
	# =====================================
	# show the login form
	app.route '/login'

		.get (req, res) ->
			# render the page and pass in any flash data if it exists
			res.render 'login.ejs', message: req.flash('loginMessage')

		.post passport.authenticate('local-login',
			successRedirect: '/' # redirect to the homepage after successful login
			failureRedirect: '/login' # redirect back to the signup page if there is an error
			failureFlash: true # allow flash messages
		)


	# =====================================
	# SIGNUP ==============================
	# =====================================
	# show the signup form
	app.route '/signup'

		.get (req, res) ->
			# render the page and pass in any flash data if it exists
			res.render 'signup.ejs', message: req.flash('signupMessage')

		# process the signup form
		.post passport.authenticate('local-signup',
			successRedirect: '/', # redirect to the secure profile section
			failureRedirect: '/signup', # redirect back to the signup page if there is an error
			failureFlash: true # allow flash messages
		)


	# =====================================
	# LOGOUT ==============================
	# =====================================
	app.get '/logout', (req, res) ->
		req.logout()

		res.redirect '/login'

	# =====================================
	# GOOGLE ROUTES =======================
	# =====================================
	# send to google to do the authentication
	# profile gets us their basic information including their name
	# email gets their emails
	app.get '/auth/google', passport.authenticate('google',
		scope: ['profile', 'email']
	)


	# the callback after google has authenticated the user
	app.get '/auth/google/callback',
		passport.authenticate('google',
			successRedirect: '/',
			failureRedirect: '/'
		)

	# =====================================
	# DATA ================================
	# =====================================
	# app routes
	app.route '/briefs'

		.get hasPermission('canViewBriefs'), (req, res) ->
			briefs = db.collection('briefs')

			briefs.find({'deleted': no}).toArray (err, docs) ->
				if err is null
					res.send docs
				else
					res.status(500).send 'Error retrieving briefs'

	app.route '/brief'

		.post hasPermission('canCreateBriefs'), (req, res) ->
			# get briefs collection
			briefs = db.collection('briefs')

			docToAdd = req.body

			docToAdd.deleted = false

			# we don't want to overwrite the ID, wipe it
			delete docToAdd['_id']

			# insert new brief
			briefs.insertOne docToAdd, (err, result) ->
				if err is null
					res.sendStatus 200
				else
					res.status(500).send 'Error creating brief'


	app.route '/brief/:id'

		.get (req, res) ->
			# as of now I don't care if unauthorized users can pull the brief
			# they won't be able to see it in the UI, nor edit it

			briefs = db.collection('briefs')

			# insert new brief
			briefs.findOne
				_id: ObjectId(req.params.id)
			, (err, result) ->
				if err is null
					# respond with the brief
					res.status(200).send result

				else
					res.status(500).send 'Error creating brief'

		# PUT to update a specific brief
		.put bodyParser.json(), hasPermission('canEditBriefs'), (req, res) ->

			# get briefs collection
			briefs = db.collection('briefs')

			# get brief as we want to store it
			brief = req.body.brief

			# keep a reference to the ID of this brief
			_id = brief['_id']

			# we don't want to overwrite the ID, wipe it
			delete brief['_id']

			# force an empty stashed board if no parameter is passed
			if not brief.hasOwnProperty 'stashedBoard'
				brief.stashedBoard = new Array()

			# we want to forcefully set this to "not deleted"
			brief.deleted = no

			briefs.update(
				{ _id: ObjectId(_id) },
				{$set: brief},
				(err, result) ->
					if err
						throw err

					io.sockets.emit 'brief updates',
						_id: _id
						lastUpdatedAt: brief.lastUpdatedAt
						
					console.log 'emitting news'

					res.status(200).send result
			)

		.delete bodyParser.json(), hasPermission('canDeleteBriefs'), (req, res) ->

			# as of now, we just want to set a "deleted" flag
			# until people is proved not to fuck up an delete by accident

			# get briefs collection
			briefs = db.collection 'briefs'

			_id = req.params.id

			# get brief to delete
			briefs.findOne
				_id: ObjectId(_id)
			, (err, brief) ->
				if err is null

					brief.deleted = yes

					# respond with the brief
					briefs.update(
						{ _id: ObjectId(_id) },
						{ $set: brief },
						(err, result) ->
							if err
								throw err

							io.sockets.emit 'brief updates',
								_id: _id
								lastUpdatedAt: brief.lastUpdatedAt
								
							console.log 'emitting news'

							res.status(200).send result
					)

				else
					res.status(500).send 'Error creating brief'


	app.route '/image-scanner/'

		.get (req, res) ->

			console.log req.query.url

			request req.query.url, (error, response, body) ->
				if (!error and response.statusCode == 200)
					res.status(200).send yes
				else
					res.status(200).send no


# route middleware to make sure a user is logged in
isLoggedIn = (req, res, next) ->
	# if user is authenticated in the session, carry on
	if req.isAuthenticated() or req.hostname is 'localhost'
		return next()

	# if they aren't, redirect to the login page
	res.redirect '/login'


# route middleware to make sure a user is authorized to execute given function
hasPermission = (permission) ->
	return hasPermission[permission] or ( hasPermission[permission] = (req, res, next) ->
		if (req.user and (permission in req.user.permissions)) or req.hostname is 'localhost'
			# authorized, proceed
			next()
		else
			# if they aren't give em a 401 unauthorized status code
			res.status(401).send()
	)