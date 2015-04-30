##Test Comment
gulp           = require 'gulp'
gutil          = require 'gulp-util'
livereload     = require 'gulp-livereload'
nodemon        = require 'gulp-nodemon'
plumber        = require 'gulp-plumber'
less           = require 'gulp-less'
postcss        = require 'gulp-postcss'
autoprefixer   = require 'autoprefixer-core'
rimraf         = require 'rimraf'
eslint         = require 'gulp-eslint'
inject         = require 'gulp-inject'
bowerFiles     = require 'main-bower-files'
es             = require 'event-stream'
uglify         = require 'gulp-uglify'
rename         = require 'gulp-rename'
cssmin         = require 'gulp-cssmin'
# sourcemaps   = require 'gulp-sourcemaps'
concat         = require 'gulp-concat'
size           = require 'gulp-filesize'
imagemin       = require 'gulp-imagemin'
pngquant       = require 'imagemin-pngquant'
changed        = require 'gulp-changed'
uncss          = require 'gulp-uncss'
mqpacker       = require 'css-mqpacker'
csswring       = require 'csswring'
gulpif         = require 'gulp-if'
jade           = require 'gulp-jade'
favicons       = require 'gulp-favicons'
argv           = (require 'yargs').argv
GLOBAL.Promise = (require 'es6-promise').Promise # to make gulp-postcss happy

#**** Note must use double brackets to expand variables

#***** Paths *********#
src_path            = 'src'
styles_path         = 'public/styles'
styles_partial_path = "#{src_path}/#{styles_path}/partials"
js_path             = 'public/js'
img_path            = 'public/images'
layouts_path        = 'templates/layouts'
partials_path       = 'templates/partials'
views_path          = 'templates/views'
favicon_path        = "#{src_path}/#{img_path}/favicon/favicon.png"
favicon_html_path   = "#{src_path}/#{partials_path}/head/favicon.html"
vendor_path         = "#{src_path}/vendor"
modules_path        = 'node_modules'
semantic_path       = "#{modules_path}/semantic-ui-css"
dist_path           = 'dist'
html_path           = ["#{src_path}/#{partials_path}/head/*.html", '#{src_path}/#{templates_path}/*.html']

err = (x...) -> gutil.log(x...); gutil.beep(x...)

# Seperate from js so js can still compile
gulp.task 'lint', ->
  gulp.src("#{src_path}/#{js_path}/*.js")
  .pipe(plumber())
  .pipe(eslint())
  .pipe(eslint.format())
  .pipe(eslint.failOnError())


# Html path not working, will put manually
# Don't put in dist, not a creation task and will get overwritten
gulp.task 'favicon', ->
    gulp.src(favicon_path)
        .pipe(favicons({
            files: { iconsPath: 'images/favicon' },
            settings: {
              appName: 'Zuisalive',
              appDescription: 'Visualizing data the easy way',
              background: '#fdac68'
              developer: 'Brent Scheibelhut',
              developerURL: 'https://brentscheibelhut.com',
              version: 0.1,
              url: 'lab.schybo.com/zuisalive',
              vinylMode: true
            }
        }, (code) ->
            console.log(code)
        ))
        .pipe(gulp.dest("#{src_path}/#{img_path}/favicon/"))

imgFiles = null
gulp.task 'img', ->
  imgFiles = gulp.src("#{src_path}/#{img_path}/**/*")
  .pipe(changed(dist_path + '/images'))
  .pipe(gulpif(argv.production, imagemin({
      progressive: true,
      svgoPlugins: [{removeViewBox: false}],
      use: [pngquant()]
  })))
  .pipe(gulp.dest(dist_path + '/images'))
  .pipe(livereload())

# Cannot run more than one uncss at once, but then if I wait till 'css' done for 'cssVendor' index task fails
# Issue: https://github.com/giakki/uncss/issues/136
cssFiles = null
gulp.task 'css', ->
  cssFiles = gulp.src("#{src_path}/#{styles_path}/styles.less")
  .pipe(changed(dist_path + '/styles'))
  .pipe(size())
  .pipe(plumber())
  .pipe(less(
    paths: [styles_partial_path]
  ))
  .on('error', err)
  # .pipe(uncss({
  #   html: html_path
  # }))
  # .pipe(sourcemaps.init())
  .pipe(postcss([
    autoprefixer((browsers: ['last 2 versions', 'ie 8', 'ie 9'])),
    mqpacker,
    csswring
  ]))
  # .pipe(sourcemaps.write())
  .pipe(rename({suffix: '.min'}))
  .pipe(gulp.dest(dist_path + '/styles'))
  .pipe(size())
  .pipe(livereload())

jsFiles = null
gulp.task 'js', ->
  jsFiles = gulp.src("#{src_path}/#{js_path}/*.js")
  .pipe(changed(dist_path + '/js'))
  .pipe(concat('site.js'))
  .pipe(size())
  .pipe(uglify())
  .pipe(rename({suffix: '.min'}))
  .pipe(gulp.dest(dist_path + '/js'))
  .pipe(size())
  .pipe(livereload())

cssVendorFiles = null
gulp.task 'cssVendor', ->
  cssVendorFiles = gulp.src(bowerFiles('**/*.css'), {base: './src/vendor'})
  .pipe(changed(dist_path + '/vendor'))
  .pipe(concat('vendor.css'))
  .pipe(uncss({
    html: html_path
  }))
  .pipe(gulpif(argv.production, cssmin({ keepSpecialComments: 0})))
  .pipe(gulpif(argv.production, rename({suffix: '.min'})))
  .pipe(gulp.dest(dist_path + '/vendor'))
  .pipe(size())

# KIT: See if they allow choice of .min files eventually

jsVendorFiles = null
gulp.task 'jsVendor', ->
  jsVendorFiles = gulp.src(bowerFiles('**/*.js'), {base: './src/vendor'})
  .pipe(changed(dist_path + '/vendor'))
  .pipe(concat('vendor.js'))
  .pipe(gulpif(argv.production, uglify()))
  .pipe(gulpif(argv.production, rename({suffix: '.min'})))
  .pipe(gulp.dest(dist_path + '/vendor'))
  .pipe(size())

gulp.task 'index', ->
  target = gulp.src("#{src_path}/#{layouts_path}/index.jade")
  # headPartialSources = gulp.src(["#{src_path}/#{partials_path}/head/*.html"])

  target
  .pipe(plumber())
  .pipe(jade())
  .pipe(inject(es.merge(
    cssVendorFiles,
    jsVendorFiles
  ), {name: 'bower', ignorePath: 'dist'}))
  .pipe(inject(es.merge(
    cssFiles,
    jsFiles
  ), {ignorePath: 'dist'}))
  # .pipe(inject(headPartialSources, {
  #   starttag: '<!-- inject:head:{{ext}} -->',
  #   transform: (filePath, file) -> file.contents.toString('utf8')
  # }))
  .pipe(gulp.dest(dist_path))
  .pipe(livereload())

gulp.task 'clean', ->
  rimraf.sync(dist_path)

gulp.task 'copy', ->
  gulp.src("#{src_path}/public/fonts/*").pipe(gulp.dest(dist_path + '/fonts'))

gulp.task 'build', ['clean', 'copy', 'css', 'img', 'js', 'cssVendor', 'jsVendor', 'index']

server_main = "./server.coffee"
gulp.task 'server', ->
  nodemon
    script: server_main
    watch: [server_main]
    env:
      PORT: process.env.PORT or 3000

gulp.task 'default', ['clean', 'copy', 'css', 'img', 'js', 'cssVendor', 'jsVendor', 'index', 'server', 'watch']

gulp.task 'watch', ->
  livereload.listen()
  gulp.watch(["#{dist_path}/**/*"]).on('change', livereload.changed)
  gulp.watch ["#{src_path}/#{styles_path}/**/*.less"], ['css']
  gulp.watch ["#{src_path}/#{js_path}/**/*.js"], ['js', 'lint']
  gulp.watch ["#{src_path}/#{img_path}/**/*"], ['img']
  gulp.watch ["#{src_path}/templates/**/*"], ['css', 'js', 'cssVendor', 'jsVendor', 'index']
