/*
*
*/

var _ = require('underscore');

var highbrow = module.exports = {};
var Backbone = highbrow.Backbone = global.Backbone || require('backbone');
var nct = highbrow.nct = global.nct || require('nct');
var cheerio = highbrow.$ = require('cheerio');
