var config = {
    bowerDir: './bower_components', srcDir: './src'
};

var gulp = require('gulp'),
    imagemin = require('gulp-imagemin'),
    pngcrush = require('imagemin-pngcrush'),
    //sourcemaps = require('gulp-sourcemaps'),
    uglify = require('gulp-uglify'),
    rename = require('gulp-rename'),
    cssmin = require('gulp-cssmin'),
    seq = require('run-sequence'),
    rimraf = require('gulp-rimraf'),
    concat = require('gulp-concat'),
    ngAnnotate = require('gulp-ng-annotate'),
    ngFilesort = require('gulp-angular-filesort'),
    templateCache = require('gulp-angular-templatecache'),
    streamqueue = require('streamqueue');

gulp.on('error', function (e) {
    throw(e);
});

gulp.task('icons', function () {
    return gulp.src(config.bowerDir + '/font-awesome/fonts/**.*')
        .pipe(gulp.dest('./www/fonts'));
});

gulp.task('js', function () {
    streamqueue({objectMode: true},
        gulp.src([
            config.bowerDir + '/jquery/dist/jquery.js',
            config.bowerDir + '/angular/angular.js',
            config.bowerDir + '/angular-route/angular-route.js',
            config.bowerDir + '/bootstrap/dist/js/bootstrap.js',
            config.bowerDir + '/angular-bootstrap/ui-bootstrap.js',
            config.bowerDir + '/angular-bootstrap/ui-bootstrap-tpls.js',
            config.bowerDir + '/ig-js-utils/src/lib/cryptoBundle.js',
            config.bowerDir + '/ig-js-utils/src/crypto/cryptoUtil.js',
            config.bowerDir + '/fingerprintjs2/dist/fingerprint2.js',
            config.bowerDir + '/html5shiv/dist/html5shiv.min.js']),
        gulp.src(config.srcDir + '/js/**/*.js').pipe(ngFilesort()),
        gulp.src([config.srcDir + '/templates/**/*.html']).pipe(templateCache({module: 'accord.ly'}))
    )
        //.pipe(sourcemaps.init())
        .pipe(concat('app.js'))
        .pipe(ngAnnotate())
        .pipe(uglify())
        .pipe(rename({suffix: '.min'}))
        //.pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./www/js'));
});

gulp.task('css', function () {
    return gulp.src([
        config.bowerDir + '/bootstrap/dist/css/bootstrap.css',
        config.bowerDir + '/bootstrap/dist/css/bootstrap-theme.css',
        config.bowerDir + '/angular/angular-csp.css',
        config.bowerDir + '/angular-bootstrap/ui-bootstrap-csp.css',
        config.srcDir + '/css/styles.css',
        config.srcDir + '/css/options.css',
        config.bowerDir + '/font-awesome/css/font-awesome.min.css'
    ])
        .pipe(concat('app.css'))
        .pipe(cssmin())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest('./www/css'))
});

gulp.task('images', function () {
    var stream = gulp.src(config.srcDir + '/images/**/*');

    stream = stream.pipe(imagemin({
        progressive: true,
        svgoPlugins: [{removeViewBox: false}],
        use: [pngcrush()]
    }));

    return stream.pipe(gulp.dest('./www/images'));
});

//gulp.task('fonts', function () {
//    gulp.src([config.bowerDir + '/font-awesome/fonts/**.*'])
//        .pipe(gulp.dest('./www/fonts'));
//});

gulp.task('html', function () {
    gulp.src([config.srcDir + '/**/*.html'])
        .pipe(gulp.dest('./www'));
});

gulp.task('clean', function (cb) {
    return gulp.src([
        './www/*.html',
        './www/images',
        './www/css',
        './www/js',
        './www/fonts'
    ], {read: false})
        .pipe(rimraf());
});

gulp.task('default', function (done) {
    var tasks = ['html', 'icons', 'images', 'css', 'js'];
    seq('clean', tasks, done);
});