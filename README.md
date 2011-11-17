````
JSON-Serialize.js provides conventions and helpers to manage serialization and deserialization of instances to/from JSON.
````

Uses the following configurable conventions:

1. type in the json with search for a constructor with a fromJSON method to serialize the json into an instance.
2. uses toJSON and fromJSON function for serializing and deserializing instances

Also, JSON-Serialize natively supports nested Date serialization so this "just works":

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

### Examples:

```javascript
var plain_old_json = JSON.serialize(some_instance), some_instance_copy = JSON.deserialize(plain_old_json);
var namespaced_instance = JSON.deserialize({_type: ‘SomeNamepace.SomeClass’, prop1: 1, prop2: 2});
```
