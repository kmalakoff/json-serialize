try
  require.config({
    paths:
      'json-serialize': "../../json-serialize"
  })

  # library and dependencies
  require ['json-serialize', 'qunit_test_runner'], (jsn, runner) ->
    window.JSONS = null # force each test to require dependencies synchronously
    require ['./build/test'], -> runner.start()