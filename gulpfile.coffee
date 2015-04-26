##Test Comment
gulp = require 'gulp'
gutil = require 'gulp-util'
livereload = require 'gulp-livereload'
nodemon = require 'gulp-nodemon'
plumber = require 'gulp-plumber'
gwebpack = require 'gulp-webpack'
less = require 'gulp-less'
postcss = require 'gulp-postcss'
autoprefixer = require 'autoprefixer-core'
rimraf = require 'rimraf'
eslint = require 'gulp-eslint'
inject = require 'gulp-inject'
bowerFiles = require 'main-bower-files'
es = require 'event-stream'
#runSequence = require('run-sequence')
GLOBAL.Promise = (require 'es6-promise').Promise # to make gulp-postcss happy

#**** Note must use double brackets to expand variables

#***** Paths *********#
src_path = 'src'
styles_path = 'public/styles'
js_path = 'public/js'
layouts_path = 'templates/layouts'
partials_path = 'templates/partials'
views_path = 'templates/views'
components_path = 'public/vendor'
modules_path = 'node_modules'
semantic_path = "#{modules_path}/semantic-ui-css"
dist_path = 'dist'

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
      modulesDirectories: [components_path, modules_path]
    module:
      loaders: [
        {
          test: /\.coffee$/
          loader: "coffee-loader"
        }
        {
          test: [/\.js$/, /\.jsx$/]
          exclude: [new RegExp(modules_path), new RegExp(components_path)]
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

# jsFiles = null
gulp.task 'js', ->
  js(false)

gulp.task 'js-dev', ->
  js(true)

gulp.task 'lint', ->
  gulp.src("#{src_path}/public/js/*.js")
  .pipe(eslint())
  .pipe(eslint.format())
  .pipe(eslint.failOnError())

cssFiles = null
gulp.task 'css', ->
  cssFiles = gulp.src("#{src_path}/#{styles_path}/styles.less")
  .pipe(plumber())
  .pipe(less(
    paths: [components_path, modules_path]
  ))
  .on('error', err)
  .pipe(postcss([autoprefixer(browsers: ['last 2 versions', 'ie 8', 'ie 9'])]))
  .pipe(gulp.dest(dist_path + '/styles'))

gulp.task 'index', ->
  target = gulp.src("#{src_path}/#{layouts_path}/index.html")

  # publicSources = gulp.src(["js/*.js", "styles/*.css"], {read: false, cwd: "#{src_path}/public"})
  jsSources = gulp.src(["js/*.js"], {read: false, cwd: "#{src_path}/public"})
  #partialSources = gulp.src(["partials/*.html"], {read: false, cwd: "#{src_path}/templates"})
  partialSources = gulp.src(["#{src_path}/#{partials_path}/head/*.html"])
  bowerSources = gulp.src(bowerFiles(), {read: false, base: './src/vendor'})

  target
  .pipe(inject(bowerSources, {name: 'bower', ignorePath: 'src'}))
  .pipe(inject(es.merge(
    cssFiles
  ), {ignorePath: 'dist'}))
  # .pipe(inject(publicSources))
  .pipe(inject(jsSources))
  .pipe(inject(partialSources, {
    starttag: '<!-- inject:head:{{ext}} -->',
    transform: (filePath, file) -> file.contents.toString('utf8')
  }))
  .pipe(gulp.dest(dist_path))

gulp.task 'clean', ->
  rimraf.sync(dist_path)

gulp.task 'copy', ->
  gulp.src("#{src_path}/#{partials_path}/*.html").pipe(gulp.dest(dist_path + '/partials'))
  gulp.src("#{src_path}/public/**/*").pipe(gulp.dest(dist_path))
  gulp.src(bowerFiles(), {read: false, base: './src/vendor'}).pipe(gulp.dest(dist_path + '/vendor'))
  gulp.src("#{semantic_path}/themes/default/assets/**/*").pipe(gulp.dest("#{dist_path}/themes/default/assets/"))

gulp.task 'build', ['clean', 'copy', 'css', 'js', 'lint', 'index']

server_main = "./server.coffee"
gulp.task 'server', ->
  nodemon
    script: server_main
    watch: [server_main]
    env:
      PORT: process.env.PORT or 3000

gulp.task 'default', ['clean', 'copy', 'css', 'js', 'lint', 'index', 'server', 'watch']

gulp.task 'watch', ['copy'], ->
  livereload.listen()
  gulp.watch(["#{dist_path}/**/*"]).on('change', livereload.changed)
  gulp.watch ["#{src_path}/#{styles_path}/**/*.less"], ['css']
  gulp.watch ["#{src_path}/templates/**/*.html"], ['copy']

# Two step build for now
gulp.task 'bp', ['clean', 'copy', 'css', 'js', 'lint', 'index']
gulp.task 'launch', ['server', 'watch']
