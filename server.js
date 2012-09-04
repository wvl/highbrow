var fs = require('fs');
var path = require('path');
var express = require('express');
var cheerio = require('cheerio');
var nct = require('nct');
var Backbone = require('backbone');
Backbone.$ = cheerio

module.exports = app = express()

app.configure('development', function() {
  app.use(express.logger('dev'));
});

app.configure(function() {
  app.use(express.static(__dirname+'/www'));
  app.use(express.cookieParser());
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
});


// app.get('/js/*', function(req, res) {
//   res.send(404);
// });

app.get('/*', function(req, res) {
  var layout = fs.readFileSync(path.join(__dirname, 'app/templates/layout.nct'), 'utf8')
  var html = nct.renderTemplate(layout, {})
  res.send(html);
});

// Run the server if it is run directly
if (!module.parent) {
  app.listen(3010);
  console.log( "listening on port: 3010");
}
