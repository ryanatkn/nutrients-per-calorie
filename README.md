:dolphin: Nutrients Per Calorie
===============================

*a web interface to the nutritional data available at the [USDA National Nutrient Database](http://ndb.nal.usda.gov/)*

###[Try it here!](http://ryanatkn.github.com/nutrients-per-calorie)###

*made with [AngularJS](http://angularjs.org/) and [d3](http://d3js.org/)*


:elephant: Mission
==================

This app attempts to help us make better food choices by putting the nutrition data from the [USDA National Nutrient Database](http://ndb.nal.usda.gov/) in an easily digestible form. By comparing foods in terms of nutrients per calorie, we're able to get an idea of what's healthy and what's empty.


:monkey: It works offline too!
==============================

1. Download and unzip [everything](https://github.com/ryanatkn/nutrients-per-calorie/archive/master.zip).

2. Serve the extracted folder from a web server. If you have Python installed, you have [a server](http://docs.python.org/2/library/simplehttpserver.html) ready to go. See instructions below for Node. There's no server code, but this step is necessary to load the food data due to browser security restrictons.

3. Visit localhost:1337 in your browser or wherever your server is.

4. Compare f☯☮ds!


:octopus: For developers
========================

To tinker with the uncompiled code, you'll need [Node](http://nodejs.org), [CoffeeScript](http://coffeescript.org/) and [Compass](http://compass-style.org/).
  
    npm install
    npm start


:snake: License
===============

The MIT License (MIT)

Copyright (c) 2013 Ryan Atkinson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
