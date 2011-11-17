// JSON-Serialize.js 1.0.0
// (c) 2011 Kevin Malakoff.
// JSON-Serialize is freely distributable under the MIT license.
// https://github.com/kmalakoff/json-serialize
//
(function(){this.JSON||(this.JSON={});JSON.SERIALIZE_VERSION="1.0.0";var j=function(a){for(var e in a)if(a.hasOwnProperty(e))return!1;return!0};JSON.serialize=function(a){if(!a||typeof a!=="object")return a;if(a.toJSON)return a.toJSON();else if(j(a))return null;var e;if(a.constructor==Array){e=[];for(var b=0,g=a.length;b<g;b++)e.push(JSON.serialize(a[b]))}else for(b in e={},a)e[b]=JSON.serialize(a[b]);return e};JSON.deserialize=function(a,e){var b=typeof a;if(b==="string")if(a.length&&(a[0]==="{"||
a[0]==="["))try{var g=JSON.parse(a);g&&(a=g)}catch(l){throw new TypeError("Unable to parse JSON: "+a);}else if((!e||!e.skip_dates)&&a.length>=19&&a[4]=="-"&&a[7]=="-"&&a[10]=="T"&&a[a.length-1]=="Z")try{var c=new Date(a);if(c)return c}catch(m){}if(b!=="object"||j(a))return a;if(a.constructor==Array){for(var b=[],d=0,g=a.length;d<g;d++)b.push(JSON.deserialize(a[d]));return b}else if(e&&e.skip_type_field||!a.hasOwnProperty(JSON.deserialize.TYPE_FIELD)){b={};for(d in a)b[d]=JSON.deserialize(a[d]);return b}else{d=
a[JSON.deserialize.TYPE_FIELD];b=0;for(g=JSON.deserialize.CONSTRUCTOR_ROOTS.length;b<g;b++){c=JSON.deserialize.CONSTRUCTOR_ROOTS[b];a:{var f=c,h=d,c=h.split(".");if(c.length===1)c=f instanceof Object&&f.hasOwnProperty(h)?f[h]:void 0;else{for(var h=void 0,i=0,k=c.length;i<k;){h=c[i];if(!(h in f))break;if(++i===k){c=f[h];break a}f=f[h];if(!f||!(f instanceof Object))break}c=void 0}}if(c)if(c.fromJSON)return c.fromJSON(a);else if(c.prototype&&c.prototype.parse)return d=new c,d.set?d.set(d.parse(a)):d.parse(a)}return null}};
JSON.deserialize.TYPE_FIELD="_type";JSON.deserialize.CONSTRUCTOR_ROOTS=[this]})();
