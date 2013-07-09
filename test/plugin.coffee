suite = require "symfio-suite"
fs = require "fs"


describe "contrib-assets()", ->
  it = suite.plugin (container, containerStub) ->
    require("..") containerStub
    
    container.set "app", (sandbox) ->
      app = sandbox.spy()
      app.use = sandbox.spy()
      app

    container.set "express", (sandbox) ->
      express = sandbox.spy()
      express.static = sandbox.spy()
      express

    container.set "serveStatic", (sandbox) ->
      sandbox.spy()

    container.set "serveJade", (sandbox) ->
      sandbox.spy()

    container.set "serveCoffee", (sandbox) ->
      sandbox.spy()

    container.set "serveStylus", (sandbox) ->
      sandbox.spy()

    container.set "serve", (sandbox) ->
      sandbox.spy()

    container.inject (sandbox) ->
      sandbox.stub fs, "stat"
      sandbox.stub fs, "mkdir"

  describe "container.unless publicDirectory", ->
    it "should define", (containerStub) ->
      factory = containerStub.unless.get "publicDirectory"
      factory("/").should.equal "/public"

  describe "container.set serve", ->
    it "should register four middlewares",
      (containerStub, serveStatic, serveJade, serveCoffee, serveStylus) ->
        factory = containerStub.set.get "serve"
        serve = factory serveStatic, serveJade, serveCoffee, serveStylus
        serve "/"
        serveStatic.should.be.calledOnce
        serveStatic.should.be.calledWith "/"
        serveJade.should.be.calledOnce
        serveJade.should.be.calledWith "/"
        serveCoffee.should.be.calledOnce
        serveCoffee.should.be.calledWith "/"
        serveStylus.should.be.calledOnce
        serveStylus.should.be.calledWith "/"

  it "should reject if publicDirectory isn't directory",
    (containerStub, serve, logger) ->
      fs.stat.yields null, isDirectory: -> false
      factory = containerStub.inject.get 0
      factory(serve, "/", logger).should.be.rejected

  it "should create directory", (containerStub, serve, logger) ->
    fs.stat.yields errno: 34
    fs.mkdir.yields()
    factory = containerStub.inject.get 0
    factory(serve, "/", logger).then ->
      fs.mkdir.should.be.calledOnce
      fs.mkdir.should.be.calledWith "/"

  it "should serve publicDirectory", (containerStub, serve, logger) ->
    fs.stat.yields null, isDirectory: -> true
    factory = containerStub.inject.get 0
    factory(serve, "/", logger).then ->
      serve.should.be.calledOnce
      serve.should.be.calledWith "/"
