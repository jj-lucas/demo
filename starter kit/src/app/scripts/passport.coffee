# load all the things we need
LocalStrategy = require('passport-local').Strategy
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
bcrypt = require 'bcrypt-nodejs'

# include configs file
config = require './config.js'

# expose this function to our app using module.exports
module.exports = (passport, db) ->

	# =========================================================================
	# passport session setup ==================================================
	# =========================================================================
	# required for persistent login sessions
	# passport needs ability to serialize and unserialize users out of session

	# used to serialize the user for the session
	passport.serializeUser (user, done) ->
		# serialize info we want to have persisting across requests
		serialized =
			'permissions': user.permissions

		done null, serialized


	# used to deserialize the user
	passport.deserializeUser (user, done) ->

		done null, user


	# =========================================================================
	# GOOGLE ==================================================================
	# =========================================================================


	passport.use new GoogleStrategy

		clientID: config.googleAuth.clientID
		clientSecret: config.googleAuth.clientSecret
		callbackURL: config.googleAuth.callbackURL
		, (token, refreshToken, profile, done) ->
			# make the code asynchronous
			process.nextTick ->
				# find a user whose profile ID matches the one attempting to sign up
				# we are checking to see if the user trying to login already exists

				users = db.collection('users')

				cursor = users.findOne
					google_id: profile.id
				, (err, doc) ->
					if doc isnt null
						# a user already exists for this account
						console.log 'Welcome back, Operator'

						# all is well, user can proceed with the login
						# return done null, user
						return done null, doc

					else
						# the user isnt in our database, create a new user
						newUser =
							google_id: profile.id
							google_token: token
							google_name: profile.displayName
							# pull the first email associate to this Google account
							google_email: profile.emails[0].value
							permissions: ['random']

						# store the new user in the db
						users.insertOne(newUser).then (r) ->
							if r.insertedCount is 1
								console.log "Operator #{ profile.emails[0].value } created"
								return done null, newUser
							else
								console.log 'Something went wrong storing the newly created user'


	# =========================================================================
	# LOCAL SIGNUP ============================================================
	# =========================================================================
	# we are using named strategies since we have one for login and one for signup
	# by default, if there was no name, it would just be called 'local'

	passport.use 'local-signup', new LocalStrategy
		# by default, local strategy uses username and password, we will override with email
		usernameField: 'email'
		passwordField: 'password'

		# allows us to pass back the entire request to the callback
		passReqToCallback: yes
		, (req, email, password, done) ->
			# asynchronous
			process.nextTick ->
				# find a user whose email is the same as the forms email
				# we are checking to see if the user trying to login already exists

				users = db.collection('users')

				cursor = users.findOne
					local_email: email
				, (err, doc) ->
					if doc isnt null
						# an operator already exists for this
						return done null, false, req.flash('signupMessage', 'Sorry kiddo, this email is already taken')
					else
						# this email is not in the DB yet, proceed with the signup
						newUser =
							local_email: email
							local_password: generateHash password
							permissions: ['random']

						# store the new user in the db
						users.insertOne(newUser).then (r) ->
							if r.insertedCount is 1
								console.log "Created a user for #{ email }"
								return done null, newUser, req.flash('signupMessage', 'Created a user for ' + email)
							else
								console.log 'Something went wrong storing the newly created user'


	# =========================================================================
	# LOCAL LOGIN =============================================================
	# =========================================================================
	# we are using named strategies since we have one for login and one for signup
	# by default, if there was no name, it would just be called 'local'

	passport.use 'local-login', new LocalStrategy
		# by default, local strategy uses username and password, we will override with email
		usernameField: 'email'
		passwordField: 'password'

		# allows us to pass back the entire request to the callback
		passReqToCallback: yes

		# callback with email and password from our form
		, (req, email, password, done) ->

			users = db.collection('users')

			cursor = users.findOne
				local_email: email
			, (err, doc) ->
				if doc isnt null
					user = doc

					# user found. Validate her password
					if !validPassword password, user.local_password
						# create the loginMessage and save it to session as flashdata
						return done null, false, req.flash('loginMessage', 'Sorry kiddo, wrong email or password')

					# all is well, user can proceed with the login
					return done null, user, req.flash('loginMessage', "Welcome back, #{ user.local_email }")

				else
					return done null, false, req.flash('loginMessage', 'Sorry kiddo, wrong email or password')

					
	generateHash = (password) ->
		return bcrypt.hashSync password


	validPassword = (password, hashed_password) ->
		return bcrypt.compareSync password, hashed_password