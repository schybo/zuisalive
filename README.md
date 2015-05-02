zuisalive
=============================

[![Build Status](https://travis-ci.org/bscheibe/zuisalive.svg?branch=master)](https://travis-ci.org/bscheibe/zuisalive) ![Heroku](https://heroku-badge.herokuapp.com/?app=zuisalive&style=flat) ![License](https://img.shields.io/dub/l/vibe-d.svg?style=flat-square)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bscheibe/zuisalive?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=body_badge)

Visualizing data the easy way!

We're live at: https://zuisalive.herokuapp.com/

Data visualization app with ES6 (via Babel), CoffeeScript, Express/Node.js, Semantic-UI, Gulp and more.

**Do not that `heroku config:set NPM_CONFIG_PRODUCTION=true` since we want to now do no want to install devDependencies too.**

### Getting Started ###

1. Fork and/or clone
2. Run `npm install` && `bower install`
3. Run `npm install -g coffee-script` if not installed
4. Start the dev server by running `gulp`
5. Visit http://localhost:3000
6. Get to work!

### Languages / Frameworks / Libraries ###

* ES6 (via Babel)
* CoffeeScript with React sugar (.cjsx)
* Normalize-CSS for normalization of default element styles across browsers
* Semantic-UI CSS framework
* LESS for extended styling capabilities
* Autoprefixer for automatic vendor prefixing
# Jade for cleaner HTML
* JQuery because semantic wants it
* Express for server side logic
* Gulp for building and change monitoring
* LiveReload
* So, so much more

### Releasing ###

Release from the dist folder onto Heroku.

1. When ready run `gulp --production` to generate distribution with highest optimization
2. Commit changes with commit title `Heroku Release`
3. `git push <herokuRemoteName>`

Will get around to creating a branch just for distributions

### Development Notes ###

* ES6 is supported in JS files; these are transpiled to ES5 via Babel.  ~~There's an example of this in ```src/header.jsx```.~~
* The main stylesheet entry point is styles.less.
* The server entry point is server.coffee.

### Development Docs ###
* FontAwesome currently being used. Docs found [here](http://fortawesome.github.io/Font-Awesome/examples/#)
* Semantic UI currrently being used. Docs found [here](http://semantic-ui.com/collections/grid.html)
* NVD3 currently being used. Examples and Docs found [here](http://nvd3.org/examples/stackedArea.html)

### LiveReload ###

Install a live reload plugin for your browser (e.g. [RemoteLiveReload for Chrome](https://chrome.google.com/webstore/detail/remotelivereload/jlppknnillhjgiengoigajegdpieppei)) to instantly see your changes in the browser when a client side file (cjsx/coffee/jsx/js/less/css/html) changes.
