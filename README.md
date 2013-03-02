Nutrients per Calorie
==========

an interface to the nutritional data available at the [USDA National Nutrient Database](http://ndb.nal.usda.gov/)

[Try it here!](http://ryanatkn.github.com/nutrients-per-calorie) (works best with Chrome, is a little wonky in Firefox)

written with [Angular](http://angularjs.org/) and [d3](http://d3js.org/)


How to run locally
==================

1. Download and unzip [everything](https://github.com/ryanatkn/nutrients-per-calorie/archive/master.zip).

2. Serve up the contents of the folder on a local web server. There is no server code, but cross-origin restrictions make this necessary to load the food data. Python's SimpleHTTPServer works well enough.

  <pre>python -m SimpleHTTPServer 3000</pre>
  
3. Go to localhost:3000 in your browser, or wherever your server is.

4. Compare foods!


How to make changes
===================

1. You'll need [CoffeeScript](http://coffeescript.org/) and [Compass](http://compass-style.org/). 

2. To compile and watch coffee/sass and start a server, run the included shell script:
  
  <pre>bash ba.sh</pre>


License
=======

The MIT License (MIT)

Copyright (c) 2013 Ryan Atkinson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
