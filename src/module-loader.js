/*
  JSON-Serialize.js 1.1.2
  (c) 2011, 2012 Kevin Malakoff - http://kmalakoff.github.com/json-serialize/
  License: MIT (http://www.opensource.org/licenses/mit-license.php)
*/
(function() {
  return (function(factory) {
    // AMD
    if (typeof define === 'function' && define.amd) {
      return define('json-serialize', factory);
    }
    // CommonJS/NodeJS or No Loader
    else {
      return factory.call(this);
    }
  })(function() {'__REPLACE__'; return JSONS;});
}).call(this);