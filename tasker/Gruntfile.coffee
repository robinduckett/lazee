module.exports = (grunt) ->

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks("grunt-mocha-test")

  grunt.initConfig(
    watch:
      files: ['test/**/*.coffee', 'src/**/*.coffee']
      tasks: ['mochaTest']

    mochaTest:
      files: ['test/**/*.test.coffee']

    mochaTestConfig:
      options:
        reporter: 'spec'
  )

  grunt.registerTask('default', 'mochaTest')