require! {
  'gulp'
  'browserify'
  'gulp-util' : gutil
  'gulp-sourcemaps' : sourcemaps
  'vinyl-transform' : transform
  'gulp-uglify' : uglify
  'gulp-jade' : jade
  'gulp-watch' : watch
  'watchify'
  'del'
  'gulp-concat' : concat
  'gulp-less' : less
  'path'
  'gulp-livescript' : gulp-live-script
  'merge-stream' : merge
  'streamqueue' : streamqueue
  'vinyl-source-stream' : source
  'fs'
  'gulp-plumber' : plumber
  'gulp-notify' : notify
  'gulp-changed' : changed
  'gulp-insert' : insert
  'gulp-replace' : replace
}

gulp.task 'clean:scripts', (cb) -> del ['dist/js'], cb

gulp.task 'clean:stylesheet', (cb) -> del ['dist/css'], cb

gulp.task 'clean:templates', (cb) -> del [
  'dist/templates',
  'dist/layouts',
  'dist/popup.html',
  'dist/background.html'], cb

gulp.task 'clean:files', (cb) -> del ['dist/fonts', 'dist/icons'], cb

gulp.task 'copy-fonts', ->
  gulp.src('./src/fonts/**/*', {base: './src/'})
    .pipe(watch('./src/fonts/**/*', {base: './src/'}))
    .pipe(gulp.dest('./dist/'))

gulp.task 'only-copy-fonts', ->
  gulp.src('./src/fonts/**/*', {base: './src/'})
    .pipe(gulp.dest('./dist/'))

gulp.task 'copy-icons', ->
  gulp.src('./src/icons/**/*', {base: './src/'})
    .pipe(watch('./src/icons/**/*', {base: './src/'}))
    .pipe(gulp.dest('./dist/'))

gulp.task 'only-copy-icons', ->
  gulp.src('./src/icons/**/*', {base: './src/'})
    .pipe(gulp.dest('./dist/'))

gulp.task 'copy-manifest', ->
  gulp.src('./src/manifest.json', {base: './src/'})
    .pipe(watch('./src/manifest.json', {base: './src/'}))
    .pipe(gulp.dest('./dist/'))

gulp.task 'only-copy-manifest', ->
  gulp.src('./src/manifest.json', {base: './src/'})
    .pipe(gulp.dest('./dist/'))

gulp.task 'copy-locales', ->
  gulp.src('./src/_locales/**/*', {base: './src/'})
    .pipe(watch('./src/_locales/**/*', {base: './src/'}))
    .pipe(gulp.dest('./dist/'))

gulp.task 'only-copy-locales', ->
  gulp.src('./src/_locales/**/*', {base: './src/'})
    .pipe(gulp.dest('./dist/'))

gulp.task 'popup-ls', ->
  b = watchify(browserify("./src/livescript/popup.ls", watchify.args))
  b.transform('liveify')
  b.bundle()
    .on('error', notify.onError("Error compiling livescript! \n <%= error.message %>"))
    .pipe(source('popup.js'))
    .pipe(gulp.dest('./dist/js'))
    .pipe(notify(message: "Livescript compiled!", on-last: true))

gulp.task 'background-ls', ->
  b = watchify(browserify("./src/livescript/background.ls", watchify.args))
  b.transform('liveify')
  b.bundle()
    .on('error', notify.onError("Error compiling livescript! \n <%= error.message %>"))
    .pipe(source('background.js'))
    .pipe(gulp.dest('./dist/js'))
    .pipe(notify(message: "Livescript compiled!", on-last: true))

gulp.task 'background-prepend', ['background-ls'], ->
  gulp.src('./dist/js/background.js')
    .pipe(insert.prepend(fs.readFileSync('./src/helpers/background.js.banner').toString().replace(/\%version\%/g, (new Date()).getTime())))
    .pipe(gulp.dest('./dist/js'))

gulp.task 'injected-ls', ->
  b = watchify(browserify("./src/livescript/injected.ls", watchify.args))
  b.transform('liveify')
  b.bundle()
    .on('error', notify.onError("Error compiling livescript! \n <%= error.message %>"))
    .pipe(source('injected.js'))
    .pipe(gulp.dest('./dist/js'))
    .pipe(notify(message: "Livescript compiled!", on-last: true))

gulp.task 'only-popup-ls', ->
  b = browserify("./src/livescript/popup.ls", watchify.args)
  b.transform('liveify')
  b.bundle()
    .on('error', notify.onError("Error compiling livescript! \n <%= error.message %>"))
    .pipe(source('popup.js'))
    .pipe(gulp.dest('./dist/js'))
    .pipe(notify(message: "Livescript compiled!", on-last: true))

gulp.task 'only-background-ls', ->
  b = browserify("./src/livescript/background.ls", watchify.args)
  b.transform('liveify')
  b.bundle()
    .on('error', notify.onError("Error compiling livescript! \n <%= error.message %>"))
    .pipe(source('background.js'))
    .pipe(gulp.dest('./dist/js'))
    .pipe(notify(message: "Livescript compiled!", on-last: true))

gulp.task 'only-injected-ls', ->
  b = browserify("./src/livescript/injected.ls", watchify.args)
  b.transform('liveify')
  b.bundle()
    .on('error', notify.onError("Error compiling livescript! \n <%= error.message %>"))
    .pipe(source('injected.js'))
    .pipe(gulp.dest('./dist/js'))
    .pipe(notify(message: "Livescript compiled!", on-last: true))



gulp.task 'templates', ->
  locals = {
    api_address: 'http://topfriends.biz'
    image_api_address: 'http://api.topfriends.biz'
    #api_address: 'http://localhost:3000'
    #image_api_address: 'http://localhost:3667'
  }

  jadeTask = jade {locals: locals, pretty: true}

  jadeTask.on('error', notify.onError("Error compiling jade! \n <%= error.message %>"))

  gulp.src('./src/jade/**/*.jade')
    .pipe(jadeTask)
    .pipe(gulp.dest('./dist/'))
    .pipe(notify(message: "Jade compiled!", on-last: true))

gulp.task 'stylesheet', ->
  gulp.src(['./src/less/popup.less'], {base: './src/less/'})
    .pipe(plumber({errorHandler: notify.onError("Error compiling LESS \n <%= error.message %>")}))
    .pipe(less({paths: [path.join __dirname, 'dist', 'components']}))
    .pipe(gulp.dest('./dist/css'))
    .pipe(notify(message: "LESS compiled!", on-last: true))

gulp.task 'connect', [
  'templates'
], ->
  connect.server {
    root: 'dist'
    livereload: true
  }

# Watch stuffs

gulp.task 'popup-ls-watch', ->
  watch('src/livescript/**/*.ls', ['popup-ls'], ->
    gulp.start('popup-ls'))

gulp.task 'background-ls-watch', ->
  watch('src/livescript/**/*.ls', ['background-ls', 'background-prepend'], ->
    gulp.start(['background-ls', 'background-prepend']))

gulp.task 'injected-ls-watch', ->
  watch('src/livescript/**/*.ls', ['injected-ls'], ->
    gulp.start('injected-ls'))

gulp.task 'stylesheet-watch', ['stylesheet'], ->
  watch('src/less/**/*.less', ->
    gulp.start('stylesheet'))

gulp.task 'templates-watch', ['templates'], ->
  watch('src/jade/**/*.jade', ->
    gulp.start('templates'))

gulp.task 'clean', [
  'clean:scripts',
  'clean:stylesheet',
  'clean:templates',
  'clean:files'
]

gulp.task 'default', [
  'popup-ls'
  'background-ls'
  'background-prepend'
  'injected-ls'
  'stylesheet'
  'templates'
  'popup-ls-watch'
  'background-ls-watch'
  'injected-ls-watch'
  'stylesheet-watch'
  'templates-watch'
  'copy-fonts'
  'copy-icons'
  'copy-manifest'
  'copy-locales'
]

gulp.task 'dist-only', [
  'only-popup-ls'
  'only-background-ls'
  'only-injected-ls'
  'stylesheet'
  'templates'
  'only-copy-fonts'
  'only-copy-icons'
  'only-copy-manifest'
  'only-copy-locales'
]