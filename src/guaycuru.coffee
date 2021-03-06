#!/usr/bin/env coffee

Router = require 'node-simple-router'
http   = require 'http'

argv = process.argv.slice 2

router = Router(
  static_route: process.cwd()
  served_by: "Guaycuru Web Server"
  version: '0.2.4'
  cgi_dir: argv[1] or 'cgi-bin'
  software_name: 'guaycuru'
  use_nsr_session: false
  default_home: []
)

# Test if it will run in gallery mode
if '-g' in argv
  console.log "Will run in gallery mode"
  router.dir = router.directory
  router.directory = router.gallery        

# Provide alternative urls to list directory
  router.get "/dir/:directory", (request, response) ->
    router.dir "#{router.static_route}/#{unescape(request.params.directory)}", "/#{unescape(request.params.directory)}", response
        
  router.get "/dir", (request, response) ->
    router.dir "#{router.static_route}", ".", response

        
#Ok, just start the server!

argv = process.argv.slice 2

server = http.createServer router

server.on 'listening', ->
  addr = server.address() or {address: '0.0.0.0', port: argv[0] or 8000}
  router.log "Guaycuru v#{router.version} serving web content at " + addr.address + ":" + addr.port  + " - PID: " + process.pid
  router.log "Working directory: #{router.static_route}"

clean_up = ->
  router.log ' '
  router.log "Server shutting up..."
  router.log ' '
  server.close()
  process.exit 0

process.on 'SIGINT', clean_up
process.on 'SIGHUP', clean_up
process.on 'SIGQUIT', clean_up
process.on 'SIGTERM', clean_up

server.listen if argv[0]? and not isNaN(parseInt(argv[0])) then parseInt(argv[0]) else 8000