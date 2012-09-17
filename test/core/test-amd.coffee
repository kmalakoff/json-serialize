root = this

root.SomeNamespace or= {}
class SomeNamespace.SomeClass
  constructor: (int_value, string_value, date_value) ->
    @int_value = int_value
    @string_value = string_value
    @date_value = date_value

  toJSON: ->
    return {
      _type: 'SomeNamespace.SomeClass',
      int_value: @int_value,
      string_value: @string_value,
      date_value: @date_value.toJSON()
    }

  @fromJSON: (json) ->
    return null if (json._type!='SomeNamespace.SomeClass')
    return new SomeClass(json.int_value, json.string_value, new Date(json.date_value))

class CouchClass
  constructor: (key, value) -> @key = key; @value = value
  toJSON: ->
    return {type: 'couch_class', key: @key, value: @value}

  @fromJSON: (json) ->
    return null if (json.type!='couch_class')
    return new CouchClass(json.key, json.value)

$(->
  module("json-serialize")

  # JSON-serialize
  require(['json-serialize'], (JSONS) ->
    test("TEST DEPENDENCY MISSING", ->
      ok(!!JSONS)
    )

    test("JSONS.serialize", ->
      int_value = 123456; string_value = 'Hello'; date_value = new Date()
      object = {
        _type:'SomeNamespace.SomeClass',
        int_value:int_value,
        string_value:string_value,
        date_value: date_value.toJSON()
      }

      result = JSONS.serialize(date_value)
      equal(result, date_value.toJSON(), 'date matches')

      some_class = new SomeNamespace.SomeClass(int_value, string_value, date_value)
      result = JSONS.serialize(some_class)
      equal(result._type, object._type, 'serialized object is equal')
      equal(result.int_value, object.int_value, 'serialized object is equal')
      equal(result.string_value, object.string_value, 'serialized object is equal')
      equal(result.date_value, object.date_value, 'serialized object is equal')

      array = [some_class, some_class, some_class]
      result = JSONS.serialize(array)
      ok(result.length is 3, 'serialized array length')
      equal(result[0]._type, object._type, 'serialized object is equal')
      equal(result[0].int_value, object.int_value, 'serialized object is equal')
      equal(result[0].string_value, object.string_value, 'serialized object is equal')
      equal(result[0].date_value, object.date_value, 'serialized object is equal')
      equal(result[1]._type, object._type, 'serialized object is equal')
      equal(result[1].int_value, object.int_value, 'serialized object is equal')
      equal(result[1].string_value, object.string_value, 'serialized object is equal')
      equal(result[1].date_value, object.date_value, 'serialized object is equal')
      equal(result[2]._type, object._type, 'serialized object is equal')
      equal(result[2].int_value, object.int_value, 'serialized object is equal')
      equal(result[2].string_value, object.string_value, 'serialized object is equal')
      equal(result[2].date_value, object.date_value, 'serialized object is equal')

      embedded_dates = [date_value, {from: date_value, to: date_value}, [1, date_value]]
      result = JSONS.serialize(embedded_dates)
      equal(result[0], date_value.toJSON(), 'date in array matches')
      equal(result[1].from, date_value.toJSON(), 'from date in object in array matches')
      equal(result[1].to, date_value.toJSON(), 'to date in object in array matches')
      equal(result[2][0], 1, '1 in array in array matches')
      equal(result[2][1], date_value.toJSON(), 'date in array in array matches')
    )

    test("JSONS.deserialize", ->
      int_value = 123456; string_value = 'Hello'; date_value = new Date()
      object = {
        _type:'SomeNamespace.SomeClass',
        int_value:int_value,
        string_value:string_value,
        date_value: date_value.toJSON()
      }

      result = JSONS.deserialize(object.date_value)
      ok(result instanceof Date, 'Date deserialized')
      equal(result.valueOf(), date_value.valueOf(), 'date matches')

      result = JSONS.deserialize(object)
      ok(result instanceof SomeNamespace.SomeClass, 'deserialized is SomeNamespace.SomeClass')
      equal(result.int_value, int_value, 'int_value deserialized')
      equal(result.string_value, string_value, 'string_value deserialized')
      ok(result.date_value instanceof Date, 'date_value deserialized')
      equal(result.date_value.valueOf(), date_value.valueOf(), 'date matches')

      array = [object, object, object]
      result = JSONS.deserialize(array)
      ok(result.length is 3, 'serialized array length')
      ok(result[0] instanceof SomeNamespace.SomeClass, 'serialized object 1 correct type')
      ok(result[0].date_value instanceof Date, 'serialized object date 1 correct type')
      ok(result[1] instanceof SomeNamespace.SomeClass, 'serialized object 2 correct type')
      ok(result[1].date_value instanceof Date, 'serialized object date 2 correct type')
      ok(result[2] instanceof SomeNamespace.SomeClass, 'serialized object 3 correct type')
      ok(result[2].date_value instanceof Date, 'serialized object date 3 correct type')

      embedded_date_objects = [
        date_value.toJSON(),
        {to: date_value.toJSON(), from: date_value.toJSON()},
        [1, date_value.toJSON()]
      ]

      result = JSONS.deserialize(embedded_date_objects)
      equal(result.length, 3, 'serialized property count')
      ok(result[0] instanceof Date, 'serialized object date 1 correct type')
      equal(result[0].valueOf(), date_value.valueOf(), 'serialized object date 1 correct type')
      ok(result[1].to instanceof Date, 'serialized object date 2 correct type')
      equal(result[1].to.valueOf(), date_value.valueOf(), 'serialized object date 2 correct type')
      ok(result[1].from instanceof Date, 'serialized object date 2 correct type')
      equal(result[1].from.valueOf(), date_value.valueOf(), 'serialized object date 2 correct type')
      equal(result[2][0], 1, 'serialized object 1 correct type')
      ok(result[2][1] instanceof Date, 'serialized object 3 correct type')
      equal(result[2][1].valueOf(), date_value.valueOf(), 'serialized object 3 correct type')

      embedded_date_objects = [
        new Date(),
        {to: new Date, from: new Date},
        [1, new Date]
      ]

      result = JSONS.deserialize(JSONS.serialize(embedded_date_objects))

      equal(result.length, 3, 'serialized property count')
      ok(result[0] instanceof Date, 'serialized object date 1 correct type')
      equal(result[0].valueOf(), embedded_date_objects[0].valueOf(), 'serialized object date 1 correct type')
      ok(result[1].to instanceof Date, 'serialized object date 2 correct type')
      equal(result[1].to.valueOf(), embedded_date_objects[1].to.valueOf(), 'serialized object date 2 correct type')
      ok(result[1].from instanceof Date, 'serialized object date 2 correct type')
      equal(result[1].from.valueOf(), embedded_date_objects[1].to.valueOf(), 'serialized object date 2 correct type')
      equal(result[2][0], 1, 'serialized object 1 correct type')
      ok(result[2][1] instanceof Date, 'serialized object 3 correct type')
      equal(result[2][1].valueOf(), embedded_date_objects[2][1].valueOf(), 'serialized object 3 correct type')

      root.couch_class = CouchClass  # register the constructor on root
      previous_json_field = JSONS.TYPE_FIELD
      JSONS.TYPE_FIELD = 'type'
      couch_class_instance_json = { type:'couch_class', key: 42, value: 'meaning'}
      couch_class_instance = JSONS.deserialize(couch_class_instance_json)
      ok(couch_class_instance instanceof CouchClass, 'deserialized with type instead of _type identifier')

      # get rid of the constructor from global namespace and put in local 'Constructors' namespace
      # (like if you were using CommonJS and don't want to pollute global namespace)
      root.Constructors or= {}
      JSONS.NAMESPACE_ROOTS.unshift(root.Constructors)
      root.Constructors.couch_class = CouchClass
      delete root['couch_class']

      couch_class_instance = JSONS.deserialize(couch_class_instance_json)
      ok(couch_class_instance instanceof CouchClass, 'deserialized with type instead of _type identifier using root.Constructors instead of global namespace')

      # cleanup
      JSONS.TYPE_FIELD = previous_json_field
      JSONS.NAMESPACE_ROOTS.shift()
    )
  )
)