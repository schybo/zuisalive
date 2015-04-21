zuisalive
=============================

[![Build Status](https://travis-ci.org/bscheibe/zuisalive.svg?branch=master)](https://travis-ci.org/bscheibe/zuisalive)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bscheibe/zuisalive?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=body_badge)

Visualizing data the easy way!

Web app starter template with React, React Router, ES6 (via Babel), CoffeeScript, Express/Node.js, Semantic-UI, Gulp and more.

### Getting Started ###

1. Fork and/or clone
2. Run ```npm install```
3. Run `npm install -g coffee-script` if not installed
4. Start the dev server by running ```$(npm bin)/gulp```
5. Visit http://localhost:3000
6. Get to work!

### Languages / Frameworks / Libraries ###

* Facebook's React for client side view and controller logic
* React Router for client side routing
* ES6 (via Babel)
* CoffeeScript with React sugar (.cjsx)
* Normalize-CSS for normalization of default element styles across browsers
* Semantic-UI CSS framework
* LESS for extended styling capabilities
* Autoprefixer for automatic vendor prefixing
* JQuery because semantic wants it (use React for most client side view rendering / manipulation)
* Webpack for client side CommonJS modules and script concatenation
* Express for server side logic
* Gulp for building and change monitoring
* LiveReload

### Development Notes ###

* Client side scripts are concatenated using Webpack.  The main entry point is client.cjsx.  From here you can require() other .cjsx, .coffee, .jsx, or .js files.
* ES6 is supported in JS and JSX files; these are transpiled to ES5 via Babel.  There's an example of this in ```src/header.jsx```.
* The main stylesheet entry point is styles.less.
* The server entry point is server.coffee.

### LiveReload ###

Install a live reload plugin for your browser (e.g. [RemoteLiveReload for Chrome](https://chrome.google.com/webstore/detail/remotelivereload/jlppknnillhjgiengoigajegdpieppei)) to instantly see your changes in the browser when a client side file (cjsx/coffee/jsx/js/less/css/html) changes.
