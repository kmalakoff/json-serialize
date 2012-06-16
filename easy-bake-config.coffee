module.exports =
  library:
    join: 'json-serialize.js'
    compress: true
    files: 'src/**/*.coffee'
    modes:
      build:
        commands: [
          'cp json-serialize.js packages/npm/json-serialize.js'
          'cp json-serialize.min.js packages/npm/json-serialize.min.js'
          'cp json-serialize.js packages/nuget/Content/Scripts/json-serialize.js'
          'cp json-serialize.min.js packages/nuget/Content/Scripts/json-serialize.min.js'
        ]

  tests:
    output: 'build'
    directories: [
      'test/core'
      'test/packaging'
    ]
    modes:
      build:
        bundles:
          'test/packaging/build/bundle.js':
            'json-serialize': 'json-serialize.js'
        no_files_ok: ['test/core', 'test/packaging']
      test:
        command: 'phantomjs'
        runner: 'phantomjs-qunit-runner.js'
        files: '**/*.html'