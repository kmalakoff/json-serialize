###
  JSON-Serialize.js 1.1.2
  (c) 2011, 2012 Kevin Malakoff - http://kmalakoff.github.com/json-serialize/
  License: MIT (http://www.opensource.org/licenses/mit-license.php)
###
root = @

# export or create JSONS namespace
JSONS = @JSONS = if (typeof(exports) != 'undefined') then exports else {}
JSONS.VERSION = "1.1.2"

JSONS.TYPE_FIELD = "_type"
JSONS.NAMESPACE_ROOTS = [root]

################HELPERS - BEGIN#################
isEmpty = (obj) ->
  # a property, not a function
  (return false if obj.hasOwnProperty(key)) for key of obj
  return true

isArray = (obj) ->
  obj.constructor is Array

stringHasISO8601DateSignature = (string) ->
  (string.length >= 19) and (string[4] is "-") and (string[7] is "-") and (string[10] is "T") and (string[string.length - 1] is "Z")

keyPath = (object, keypath) ->
  keypath_components = keypath.split(".")
  return (if (object instanceof Object) and (object.hasOwnProperty(keypath)) then object[keypath] else undefined) if keypath_components.length is 1
  current_object = object
  l = keypath_components.length
  for i, key of keypath_components
    key = keypath_components[i]
    break  unless key of current_object
    return current_object[key] if ++i is l
    current_object = current_object[key]
    break if not current_object or (current_object not instanceof Object)
  return undefined
################HELPERS - END#################

# Convert an array of objects or an object to JSON using the convention that if an
# object has a toJSON function, it will use it rather than the raw object.
JSONS.serialize = (obj, options) ->
  # Simple type - exit quickly
  return obj if not obj or (typeof (obj) isnt "object")

  # use toJSON function - Note: Dates have a built in toJSON that converts them to ISO8601 UTC ("Z") strings
  return obj.toJSON() if obj.toJSON
  return null if isEmpty(obj)

  # serialize an array
  if isArray(obj)
    result = []
    result.push(JSONS.serialize(value)) for value in obj

  # serialize the properties
  else
    result = {}
    result[key] = JSONS.serialize(value) for key, value of obj
  return result

# Deserialized an array of JSON objects or each object individually using the following conventions:
# 1) if JSON has a recognized type identifier ('\_type' as default), it will try to create an instance.
# 2) if the class refered to by the type identifier has a fromJSON function, it will try to create an instance.
# <br/>**Options:**<br/>
#* `skip_type_field` - skip a type check. Useful for if your model is already deserialized and you want to deserialize your properties. See Backbone.Articulation for an example.
#* `skip_dates` - skip the automatic Date conversion check from ISO8601 string format. Useful if you want to keep your dates in string format.
# <br/>**Global settings:**<br/>
#* `JSONS.TYPE_FIELD` - the field key in the serialized JSON that is used for constructor lookup.<br/>
#* `JSONS.NAMESPACE_ROOTS` - the array of roots that are used to find the constructor. Useful for reducing global namespace pollution<br/>
JSONS.deserialize = (json, options) ->
  json_type = typeof (json)

  # special checks for strings (is a date, etc)
  if json_type is "string"
    # The object is still a JSON string, convert to JSON
    if json.length and (json[0] is "{") or (json[0] is "[")
      try
        json_as_JSON = JSON.parse(json)
        json = json_as_JSON if json_as_JSON
      catch e
        throw new TypeError("Unable to parse JSON: " + json)
    # the object looks like a Date serialized to ISO8601 UTC ("Z") format, try automatically converting
    else if not (options and options.skip_dates) and stringHasISO8601DateSignature(json)
      try
        date = new Date(json)
        return date if date

  # Simple type - exit quickly
  return json if (json_type isnt "object") or isEmpty(json)

  # Parse an array
  if isArray(json)
    result = []
    result.push(JSONS.deserialize(value)) for value in json
    return result

  # Parse the properties individually
  else if (options and options.skip_type_field) or not json.hasOwnProperty(JSONS.TYPE_FIELD)
    result = {}
    (result[key] = JSONS.deserialize(value)) for key, value of json
    return result

  # Find and use the fromJSON function
  else
    type = json[JSONS.TYPE_FIELD]

    # Try searching in the available namespaces
    for namespace_root in JSONS.NAMESPACE_ROOTS
      constructor_or_root = keyPath(namespace_root, type)
      continue  unless constructor_or_root

      # class/root parse function
      if constructor_or_root.fromJSON
        return constructor_or_root.fromJSON(json)

      # instance parse function (Backbone.Model and Backbone.Collection style)
      else if constructor_or_root.prototype and constructor_or_root.prototype.parse
        instance = new constructor_or_root()
        return instance.set(instance.parse(json)) if instance.set
        return instance.parse(json)
    return null