// JSON-Serialize.js 1.1.0
// (c) 2011 Kevin Malakoff.
// JSON-Serialize is freely distributable under the MIT license.
// https://github.com/kmalakoff/json-serialize
//

(function() {

this.JSON || (this.JSON = {}); // hopefully JSON is defined!
JSON.SERIALIZE_VERSION = '1.1.0';

////////////////HELPERS - BEGIN//////////////////
var isEmpty = function(obj) {
  for(var key in obj) {
    // a property, not a function
    if (obj.hasOwnProperty(key)) return false;
  }
  return true;
};

var isArray = function(obj) {
  return obj.constructor == Array;
};

var stringHasISO8601DateSignature = function(string) {
  return (string.length>=19) && (string[4] == '-') && (string[7] == '-') && (string[10] == 'T') && (string[string.length-1] == 'Z');
};

var keyPath = function(object, keypath) {
  var keypath_components = keypath.split('.');
  if (keypath_components.length===1) return ((object instanceof Object) && (object.hasOwnProperty(keypath))) ? object[keypath] : void 0; // optimization
  var key, current_object = object;
  for (var i = 0, l = keypath_components.length; i < l;) {
    key = keypath_components[i];
    if (!(key in current_object)) break;
    if (++i === l) return current_object[key];
    current_object = current_object[key];
    if (!current_object || !(current_object instanceof Object)) break;
  }
  return void 0;
};
////////////////HELPERS - END//////////////////

// Convert an array of objects or an object to JSON using the convention that if an
// object has a toJSON function, it will use it rather than the raw object.
JSON.serialize = function(obj, options) {
  // Simple type - exit quickly
  if (!obj || (typeof(obj)!=='object')) return obj;

  // use toJSON function - Note: Dates have a built in toJSON that converts them to ISO8601 UTC ("Z") strings
  if(obj.toJSON) return obj.toJSON();
  else if (isEmpty(obj)) return null;

  // serialize an array
  var result;
  if (isArray(obj)) {
    result = [];
    for (var i=0, l=obj.length; i<l;i++) { result.push(JSON.serialize(obj[i])); }
    return result;
  }

  // serialize the properties
  else {
    result = {};
    for (var key in obj) { result[key] = JSON.serialize(obj[key]); }
    return result;
  }
};

// Deserialized an array of JSON objects or each object individually using the following conventions:
// 1) if JSON has a recognized type identifier ('\_type' as default), it will try to create an instance.
// 2) if the class refered to by the type identifier has a fromJSON function, it will try to create an instance.
// <br/>**Options:**<br/>
//* `skip_type_field` - skip a type check. Useful for if your model is already deserialized and you want to deserialize your properties. See Backbone.Articulation for an example.
//* `skip_dates` - skip the automatic Date conversion check from ISO8601 string format. Useful if you want to keep your dates in string format.
// <br/>**Global settings:**<br/>
//* `JSON.deserialize.TYPE_FIELD` - the field key in the serialized JSON that is used for constructor lookup.<br/>
//* `JSON.deserialize.NAMESPACE_ROOTS` - the array of roots that are used to find the constructor. Useful for reducing global namespace pollution<br/>
JSON.deserialize = function(json, options) {
  var json_type = typeof(json);

  // special checks for strings
  if (json_type==='string') {
    // The object is still a JSON string, convert to JSON
    if (json.length && ((json[0] === '{') || (json[0] === '['))) {
      try { var json_as_JSON = JSON.parse(json); if (json_as_JSON) json = json_as_JSON; }
      catch (e) {throw new TypeError("Unable to parse JSON: " + json);}
    }
    // the object looks like a Date serialized to ISO8601 UTC ("Z") format, try automatically converting
    else if (!(options && options.skip_dates) && stringHasISO8601DateSignature(json)) {
      try { var date = new Date(json); if (date) return date; }
      catch (e) {}
    }
  }

  // Simple type - exit quickly
  if ((json_type!=='object') || isEmpty(json))  return json;

  // Parse an array
  var result;
  if (isArray(json)) {
    result = [];
    for (var i=0, l=json.length; i<l;i++) { result.push(JSON.deserialize(json[i])); }
    return result;
  }

  // Parse the properties individually
  else if ((options && options.skip_type_field) || !json.hasOwnProperty(JSON.deserialize.TYPE_FIELD)) {
    result = {};
    for (var key in json) { result[key] = JSON.deserialize(json[key]); }
    return result;
  }

  // Find and use the fromJSON function
  else
  {
    var type = json[JSON.deserialize.TYPE_FIELD];
    var root, constructor_or_root, instance;

    // Try searching in the available namespaces
    for (var j=0, k=JSON.deserialize.NAMESPACE_ROOTS.length; j<k;j++) {
      root = JSON.deserialize.NAMESPACE_ROOTS[j];
      constructor_or_root = keyPath(root, type);
      if (!constructor_or_root) continue;

      // class/root parse function
      if (constructor_or_root.fromJSON) return constructor_or_root.fromJSON(json);
      // instance parse function (Backbone.Model and Backbone.Collection style)
      else if (constructor_or_root.prototype && constructor_or_root.prototype.parse) {
        instance = new constructor_or_root();
        if (instance.set) return instance.set(instance.parse(json));
        else return instance.parse(json);
      }
    }

    return null;
  }
};

JSON.deserialize.TYPE_FIELD = '_type';
JSON.deserialize.NAMESPACE_ROOTS = [this];
})();