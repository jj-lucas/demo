var gulp = require('gulp');
var stylus = require('gulp-stylus');
var coffee = require('gulp-coffee');
var coffeelint = require('gulp-coffeelint');
var uglify = require('gulp-uglify');
var nano = require('gulp-cssnano');
var gutil = require('gulp-util');
var plumber = require('gulp-plumber');
var changed = require('gulp-changed');
var livereload = require('gulp-livereload');
var gulpif = require('gulp-if');
var argv = require('argv');
var del = require('del');

var production = !!(argv.production); // true if --production flag is used

paths = {
	styles: [
		'./src/public/styles/**/*.styl',
		'!./src/public/styles/modules/*.styl',
		'!./src/public/styles/partials/*.styl'
	],

	scripts: [
		'./src/public/scripts/**/*.coffee',
		'./src/app/scripts/**/*.coffee',
		'!./src/public/vendor/**/*'
	],

	copy: [
		'./src/**/*',
		'!./src/public/styles/**/*',
		'!./src/public/scripts/*',
		'!./src/public/scripts/{collections/**/*,models/**/*,mixins/**/*,views/**/*}',
		'!./src/app/scripts/*'
	]
};

gulp.task('clean', function (cb) {
	del(['build'], cb);
});

gulp.task('styles', function () {
	return gulp.src(paths.styles)
		.pipe(plumber())
		.pipe(stylus())
		.pipe(gulpif(production, nano()))
		.pipe(gulp.dest('./build/public/styles/'))
		.pipe(livereload());
});

gulp.task('scripts', function() {
	return gulp.src(paths.scripts, {base: './src/'})
		.pipe(plumber())
		.pipe(changed('build/', {extension: '.js'}))
		.pipe(coffeelint({
			no_tabs: { level: "ignore" },
			indentation: { value: 1 },
			max_line_length: { level: "ignore" }
		}))
		.pipe(coffeelint.reporter())
		.pipe(coffee())
		.pipe(gulpif(production, uglify({
			mangle: false,
			beautify: false
		})))
		.pipe(gulp.dest('./build/'))
		.pipe(livereload());
});

gulp.task('copy', function() {
	return gulp.src(paths.copy)
		.pipe(gulp.dest('./build/'));
});

gulp.task('watch', function () {
	livereload.listen();
	gulp.watch('./src/public/styles/**/*.styl', ['styles']);
	gulp.watch('./src/public/scripts/**/*.coffee', ['scripts']);
	gulp.watch('./src/public/scripts/templates/**/*.html', ['build']);
	gulp.watch('./src/public/*.html', ['build']);
	gulp.watch('./src/app/scripts/**/*.coffee', ['scripts']);
	gulp.watch('./src/app/views/**/*.ejs', ['build']);
});

gulp.task('build', function () {
	gulp.start('styles', 'scripts', 'copy')
});

gulp.task('default', function(){
	gutil.log(gutil.colors.yellow('\n\nHello stranger, let me be your guide..'));
	gutil.log('No default task, use', gutil.colors.green('gulp <task>'), 'instead');
	gutil.log('Tasks available:');
	gutil.log(gutil.colors.green('gulp clean'), 'to clean the project of previous builds');
	gutil.log(gutil.colors.green('gulp scripts'), 'to build scripts');
	gutil.log(gutil.colors.green('gulp styles'), 'to build styles');
	gutil.log(gutil.colors.green('gulp copy'), 'to build images');
	gutil.log(gutil.colors.green('gulp build'), 'to make a complete build');
	gutil.log(gutil.colors.green('gulp watch'), 'to trigger builds when files are saved');
});