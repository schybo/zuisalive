##Test Comment
gulp           = require 'gulp'
gutil          = require 'gulp-util'
livereload     = require 'gulp-livereload'
nodemon        = require 'gulp-nodemon'
plumber        = require 'gulp-plumber'
gwebpack       = require 'gulp-webpack'
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
mqpacker       = require 'css-mqpacker'
csswring       = require 'csswring'
argv           = (require 'yargs').argv
gulpif         = require 'gulp-if'
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
vendor_path         = "#{src_path}/vendor"
modules_path        = 'node_modules'
semantic_path       = "#{modules_path}/semantic-ui-css"
dist_path           = 'dist'

err = (x...) -> gutil.log(x...); gutil.beep(x...)

webpack = (name, ext, watch) ->
  options =
#    bail: true
    watch: watch
    cache: true
    devtool: "source-map"
    output:
      filename: "#{name}.js"
      sourceMapFilename: "[file].map"
    resolve:
      extensions: ["", ".webpack.js", ".web.js", ".js", ".jsx", ".coffee", ".cjsx"]
      modulesDirectories: [vendor_path, modules_path]
    module:
      loaders: [
        {
          test: /\.coffee$/
          loader: "coffee-loader"
        }
        {
          test: [/\.js$/, /\.jsx$/]
          exclude: [new RegExp(modules_path), new RegExp(vendor_path)]
          loader: "babel-loader"
        }
        {
          test: /\.cjsx$/
          loader: "transform?coffee-reactify"
        }
      ]

  gulp.src("#{src_path}/**/#{name}.#{ext}")
  .pipe(gwebpack(options))
  .pipe(gulp.dest(dist_path))


js = (watch) -> webpack('client', 'cjsx', watch)

gulp.task 'jsClient', ->
  js(false)

gulp.task 'jsClient-dev', ->
  js(true)


# Seperate from js so js can still compile
gulp.task 'lint', ->
  gulp.src("#{src_path}/#{js_path}/*.js")
  .pipe(plumber())
  .pipe(eslint())
  .pipe(eslint.format())
  .pipe(eslint.failOnError())

imgFiles = null
gulp.task 'img', ->
  imgFiles = gulp.src("#{src_path}/#{img_path}/**/*")
  .pipe(changed(dist_path + '/images'))
  .pipe(imagemin({
      progressive: true,
      svgoPlugins: [{removeViewBox: false}],
      use: [pngquant()]
  }))
  .pipe(gulp.dest(dist_path + '/images'));

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

jsFiles = null
gulp.task 'js', ->
  jsFiles = gulp.src("#{src_path}/#{js_path}/*.js")
  .pipe(concat('site.js'))
  .pipe(size())
  .pipe(uglify())
  .pipe(rename({suffix: '.min'}))
  .pipe(gulp.dest(dist_path + '/js'))
  .pipe(size())

cssVendorFiles = null
gulp.task 'cssVendor', ->
  cssVendorFiles = gulp.src(bowerFiles('**/*.css'), {base: './src/vendor'})
  .pipe(concat('vendor.css'))
  .pipe(gulpif(argv.production, cssmin()))
  .pipe(gulpif(argv.production, rename({suffix: '.min'})))
  .pipe(gulp.dest(dist_path + '/vendor/'))
  .pipe(size())

# KIT: See if they allow choice of .min files eventually

jsVendorFiles = null
gulp.task 'jsVendor', ->
  jsVendorFiles = gulp.src(bowerFiles('**/*.js'), {base: './src/vendor'})
  .pipe(concat('vendor.js'))
  .pipe(gulpif(argv.production, uglify()))
  .pipe(gulpif(argv.production, rename({suffix: '.min'})))
  .pipe(gulp.dest(dist_path + '/vendor/'))
  .pipe(size())

gulp.task 'index', ->
  target = gulp.src("#{src_path}/#{layouts_path}/index.html")
  partialSources = gulp.src(["#{src_path}/#{partials_path}/head/*.html"])

  target
  .pipe(inject(es.merge(
    cssVendorFiles,
    jsVendorFiles
  ), {name: 'bower', ignorePath: 'dist'}))
  .pipe(inject(es.merge(
    cssFiles,
    jsFiles
  ), {ignorePath: 'dist'}))
  .pipe(inject(partialSources, {
    starttag: '<!-- inject:head:{{ext}} -->',
    transform: (filePath, file) -> file.contents.toString('utf8')
  }))
  .pipe(gulp.dest(dist_path))

gulp.task 'clean', ->
  rimraf.sync(dist_path)

gulp.task 'copy', ->
  gulp.src("#{src_path}/public/fonts/*").pipe(gulp.dest(dist_path + '/fonts'))
  gulp.src("#{semantic_path}/themes/default/assets/**/*").pipe(gulp.dest("#{dist_path}/themes/default/assets/"))

gulp.task 'build', ['clean', 'copy', 'css', 'img', 'js', 'cssVendor', 'jsVendor', 'jsClient', 'lint', 'index']

server_main = "./server.coffee"
gulp.task 'server', ->
  nodemon
    script: server_main
    watch: [server_main]
    env:
      PORT: process.env.PORT or 3000

gulp.task 'default', ['clean', 'copy', 'css', 'img', 'js', 'cssVendor', 'jsVendor', 'jsClient-dev', 'lint', 'index', 'server', 'watch']

gulp.task 'watch', ['copy'], ->
  livereload.listen()
  gulp.watch(["#{dist_path}/**/*"]).on('change', livereload.changed)
  gulp.watch ["#{src_path}/#{styles_path}/**/*.less"], ['css']
  gulp.watch ["#{src_path}/#{js_path}/**/*.js"], ['js', 'lint']
  gulp.watch ["#{src_path}/#{img_path}/**/*"], ['img']
  gulp.watch ["#{src_path}/templates/**/*.html"], ['copy']
