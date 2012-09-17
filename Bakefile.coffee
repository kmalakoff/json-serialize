module.exports =
  library:
    join: 'json-serialize.js'
    wrapper: 'src/module-loader.js'
    compress: true
    files: 'src/**/*.coffee'
    _build:
      commands: [
        'cp json-serialize.js packages/npm/json-serialize.js'
        'cp json-serialize.min.js packages/npm/json-serialize.min.js'
        'cp README.md packages/npm/README.md'
        'cp json-serialize.js packages/nuget/Content/Scripts/json-serialize.js'
        'cp json-serialize.min.js packages/nuget/Content/Scripts/json-serialize.min.js'
      ]

  tests:
    _build:
      output: 'build'
      directories: [
        'test/core'
      ]

      commands: [
        'mbundle test/packaging/bundle-config.coffee'
      ]
    _test:
      command: 'phantomjs'
      runner: 'phantomjs-qunit-runner.js'
      files: ['**/*.html']
      directories: [
        'test/core'
        'test/packaging'
      ]