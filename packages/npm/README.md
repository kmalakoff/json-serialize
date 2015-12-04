JSON-Serialize.js provides conventions and helpers to manage serialization and deserialization of instances to/from JSON.

#Download Latest (1.1.3):

Please see the [release notes](https://github.com/kmalakoff/json-serialize/blob/master/RELEASE_NOTES.md) for upgrade pointers.

* [Development version](https://raw.github.com/kmalakoff/json-serialize/1.1.3/json-serialize.js)
* [Production version](https://raw.github.com/kmalakoff/json-serialize/1.1.3/json-serialize.min.js)

###Module Loading

JSON-Serialize.js is compatible with RequireJS, CommonJS, Brunch and AMD module loading. Module names:

* 'json-serialize' - json-serialize.js.

Examples
--------

1) JSON-Serialize natively supports nested Date serialization so this "just works":

```javascript
var embedded_date_objects = [
  new Date(),
  {to: new Date, from: new Date},
  [1, new Date]
];

var json = JSON.serialize(embedded_date_objects);
var deserialized_embedded_date_objects = JSON.deserialize(json);

equal(_.isEqual(embedded_date_objects, deserialized_embedded_date_objects), true, 'the nested dates were deserialized automatically')
```

Pretty cool, eh?

2) Creating custom serialization for one of your classes.

```coffeescript
class SomeClass
  constructor: (int_value, string_value, date_value) ->
    this.int_value = int_value;
    this.string_value = string_value;
    this.date_value = date_value;

  toJSON: ->
    return {
      _type:'SomeClass',
      int_value:this.int_value,
      string_value:this.string_value,
      date_value:JSON.serialize(this.date_value)
    }

  @fromJSON: (json) ->    # note: this is a class method
    if (json._type!='SomeClass') return null;
    return new SomeClass(json.int_value, json.string_value, JSON.deserialize(json.date_value));
```

Now you can automatically serialize and deserialize it:

```coffeescript
instance = new SomeClass(1, 'two', new Date());
json = JSON.serialize(instance)   # this calls the toJSON function on the instance

instance2 = JSON.deserialize(json)   # this calls the fromJSON function on the class (you need to make sure the constructor can be found)
```

# Conventions

Uses the following configurable conventions:

1. use a '_type" field in the json that you serialize
2. for serializing, implement a toJSON function as an **instance** method.
3. for deserializing, implement a fromJSON deserialization factory function as an **class** method. This doesn't need to be a class function but can be any function as long as it can be found (see JSON.deserialize.NAMESPACE_ROOTS).

# Options

* JSON.deserialize.TYPE_FIELD

You can globally choose the type field used when deserializing an instance from JSON.

For example, if you use couchdb, you could use a 'type' field convention:

```coffeescript
JSON.deserialize.TYPE_FIELD = 'type'
```

* JSON.deserialize.NAMESPACE_ROOTS

If you don't want to pollute the global namespace with your deserialization factory functions, you can put them in any sort of nested namespaces. Just register your namespace roots like:

```coffeescript
JSON.deserialize.NAMESPACE_ROOTS.push(window.my_classes)
```

Building, Running and Testing the library
-----------------------

###Installing:

1. install node.js: http://nodejs.org
2. install node packages: 'npm install'

###Commands:

Look at: https://github.com/kmalakoff/easy-bake