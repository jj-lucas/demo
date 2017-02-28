# JJ Tool Starter Kit
##### MK-I 'The Apparatus'
=================

## Specs
- Gulp buildsys handling file watching and builds
    - Coffescript (linting, production uglification)
    - Stylus (minification)
    - Livereload
- Travis
- Node backend
	- Express server w/ router
	- EJS template rendering (w/ flash messaging)
	- MongoDB database connector
	- Passport authentication (Google OAUTH2, local login)
	- Login / signup pages
	- Authorization middleware
- Backbone client
	- RequireJS module loading
	- Backbone setup
	- Underscore tempalte rendering (w/ permission based rendering)
	- Boilerplates for common tasks


## Google OAUTH2 setup

- Go to http://console.developers.google.com
- Create a new project
- "enable and manage APIs" -> "credentials"
- "OAuth consent screen"
	- Product name shown to users
- "credentials" -> "new credentials" -> "OAuth client ID"
	- "web application"
	- Authorized origins: http://localhost:PORT, http://jjtechtoys.dk:PORT
	- Authorized redirect UTIs: http://localhost:PORT/auth/google/callback, http://jjtechtoys.dk:PORT/auth/google/callback
	- Get the client ID and secret, plug them in the config file
- Back in the overview, navigate to the Google+ API and enable it

## Building the project

To build the project, you have to create a config.coffee file in src/app/scripts. This file needs to remain unversioned. Add it to your gitignore if it wasn't to be already. The file contains credentials for the various systems used. An example can be found here: https://gist.github.com/jj-lucas/7be53e9d89f0605fd010ac4aff6efd30

In the config file, set a random string as the session secret

## Repo changelog

#### 1.0.2
* Added Bootstrap JS capabilities

#### 1.0.1
* Added permission based rendering of Underscore templates

#### 1.0.0
* Initial stable build