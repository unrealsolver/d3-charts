var gulp       = require('gulp');
var gutil      = require('gulp-util');
var connect    = require('gulp-connect');
var gulpif     = require('gulp-if');
var coffee     = require('gulp-coffee');
var concat     = require('gulp-concat');
var jade       = require('gulp-jade');
var less       = require('gulp-less');
var rename     = require('gulp-rename')
var browserify = require('gulp-browserify')

gulp.task('appJS', function() {
  // concatenate compiled .coffee files and js files
  // into build/app.js
  gulp.src('./app/app.coffee', {read: false})
    //.pipe(gulpif(/[.]coffee$/, coffee({bare: true}).on('error', gutil.log)))
    //.pipe(concat('app.js'))
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(rename('app.js'))
    .pipe(gulp.dest('./build'))
});

gulp.task('appCSS', function() {
  // concatenate compiled Less and CSS
  // into build/app.css
  gulp
    .src([
      './app/**/*.less',
      './app/**/*.css'
    ])
    .pipe(
      gulpif(/[.]less$/,
        less({
          paths: [
            './bower_components/bootstrap/less'
          ]
        })
        .on('error', gutil.log))
    )
    .pipe(
      concat('app.css')
    )
    .pipe(
      gulp.dest('./build')
    )
});

gulp.task('libJS', function() {
  // concatenate vendor JS into build/lib.js
  gulp.src([
    './bower_components/lodash/dist/lodash.js',
    './bower_components/jquery/dist/jquery.js',
    './bower_components/lodashdist/lodash.min.js',
    './bower_components/d3/d3.min.js',
    ]).pipe(concat('lib.js'))
      .pipe(gulp.dest('./build'));
});

gulp.task('libCSS',
  function() {
  // concatenate vendor css into build/lib.css
  gulp.src(['!./bower_components/**/*.min.css',
      './bower_components/**/*.css'])
      .pipe(concat('lib.css'))
      .pipe(gulp.dest('./build'));
});

gulp.task('index', function() {
  gulp.src(['./app/index.jade', './app/index.html'])
    .pipe(gulpif(/[.]jade$/, jade().on('error', gutil.log)))
    .pipe(gulp.dest('./build'));
});

gulp.task('watch',function() {

  // reload connect server on built file change
  gulp.watch([
      'build/**/*.html',        
      'build/**/*.js',
      'build/**/*.css'        
  ], function(event) {
      return gulp.src(event.path)
          .pipe(connect.reload());
  });

  // watch files to build
  gulp.watch(['./app/**/*.coffee'], ['appJS']);
  gulp.watch(['./app/**/*.less', './app/**/*.css'], ['appCSS']);
  gulp.watch(['./app/index.jade', './app/index.html'], ['index']);
});

gulp.task('connect', connect.server({
  root: ['build'],
  port: 9001,
  livereload: true
}));

gulp.task('default', ['connect', 'appJS', 'appCSS', 'index', 'libJS', 'libCSS', 'watch']);
