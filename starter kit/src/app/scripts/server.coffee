# set up
# get all the tools we need
express = require 'express'
passport = require 'passport'
flash = require 'connect-flash'
morgan = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'express-session'
http = require 'http'
mongoClient = require('mongodb').MongoClient
promise = require 'promise'

# include configs file
config = require './config.js'

# handler for database connection
connectToDb = ->
	promise = new promise (resolve, reject) ->
		mongoClient.connect config.mongodb.url, (err, db) ->
			if err is null
				# all good!
				console.log 'Connected to the Mongo server'

				# make sure to close the connection before quitting the application
				process.on 'SIGINT', ->
					console.log 'Closing DB connection'
					db.close()
					process.exit 0

				# resolve promise passing the db object
				resolve db
			else
				reject err
				console.log 'Failed connection to the DB'

	# return the promise to handle the control flow
	promise


##############
## SHOWTIME ##
##############

connectToDb().then (db) ->

	# pass passport and db for configuration
	require('./passport')(passport, db)

	# setup Express server
	app = express()

	# create an HTTP server used by Faye
	server = http.createServer app

	port = process.env.PORT || 1339

	# log every request error to the console
	app.use morgan(
		'dev',
		skip: (req, res) ->
			res.statusCode < 400
	)

	# read cookies (needed for auth)
	app.use cookieParser()

	# get information from html forms
	# app.use bodyParser()

	# set the max request size to a limit we won't hit
	app.use bodyParser.json({limit: '50mb'})
	app.use bodyParser.urlencoded({limit: '50mb', extended: true})

	app.set 'view engine', 'ejs'
	app.set 'views', __dirname + '/../views'

	# setup static folder for asset retreival within views
	app.use express.static '../../public'

	# required for passport
	app.use session
		secret: config.sessionSecret
		saveUninitialized: true
		resave: true

	app.use passport.initialize()

	# persistent login sessions
	app.use passport.session()

	# use connect-flash for flash messages stored in session
	app.use flash()

	# load our routes and pass in our app and fully configured passport and database
	require('./routes.js') app, passport, db

	# launch
	server.listen port, ->
		console.log 'The magic happens on port ' + port