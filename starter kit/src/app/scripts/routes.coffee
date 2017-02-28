request = require 'request'
util = require 'util'
bodyParser = require 'body-parser'

module.exports = (app, passport, db) ->

	# =====================================
	# HOME PAGE (with login links) ========
	# =====================================
	app.get '/', (req, res) ->
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



# route middleware to make sure a user is logged in
isLoggedIn = (req, res, next) ->
	# if user is authenticated in the session, carry on
	if req.isAuthenticated() || req.host is 'localhost'
		return next()

	# if they aren't give em a 401 unauthorized status code
	res.status(401).send()


# route middleware to make sure a user is authorized to execute given function
hasPermission = (permission) ->
	return hasPermission[permission] or ( hasPermission[permission] = (req, res, next) ->
		if req.user and permission in req.user.permissions
			# authorized, proceed
			next()
		else
			# if they aren't give em a 401 unauthorized status code
			res.status(401).send()
	)