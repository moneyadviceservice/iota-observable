chai = require "chai"
sinon = require "sinon"
sinonChai = require "sinon-chai"
Observable = require "../iota-observable"

should = chai.should()
chai.use(sinonChai)

# TODO
# - add nested property support
# - add computed properties
# - add dependency watching
# - add observer parameters (old/new)

## Reused stuff

# Creates reused tests
createTests = (description, createObservable) ->
  describe description, ->
    o = null
    
    beforeEach -> 
      o = createObservable()
      
    it "should return property values using get", ->  
      o.get("foo").should.equal 1
      
    it "should return nested property values using get", ->  
      o.get("nested.bum").should.equal 3
      
    it "should return nested observable property values using get", ->  
      o.get("nested.observableObj.observedProp").should.equal 7
      
    it "should return undefined when it meets a dead end or incompatible property using get", ->  
      result = o.get("nested.bum.olli")
      should.equal(result, undefined)
      
    it "should return property values using dot operator", ->  
      o.foo.should.equal 1
      
    it "should return nested property values using dot operator", ->  
      o.nested.bum.should.equal 3

    it "should set property values using dot operator", ->
      o.bar = 3
      o.get("bar").should.equal 3
      
    it "should set nested property values using dot operator", ->
      o.nested.baz = 7
      o.get("nested.baz").should.equal 7

    it "should set property values using set", ->
      o.set("bar", 3).should.equal true
      o.get("bar").should.equal 3
      
    it "should set nested property values using set", ->
      o.set("nested.baz", 7).should.equal true
      o.get("nested.baz").should.equal 7
      
    it "should set nested observable property values using set", ->
      o.set("nested.observableObj.observedProp", 8).should.equal true
      o.get("nested.observableObj.observedProp").should.equal 8
      
    it "should pave the way when it meets a dead end using set", ->
      o.set("nested.hui.super", 7).should.equal true
      o.get("nested.hui.super").should.equal 7
      
    it "shouldn't pave the way when it meets an incompatible property using set", ->
      o.set("nested.bum.super", 7).should.equal false
      result = o.get("nested.bum.super")
      should.equal(result, undefined)
      
    it "should set property values using set with a map", ->
      [fooSuccessful, barSuccessful] = o.set
        foo: 3
        bar: 4
        
      fooSuccessful.should.equal true
      barSuccessful.should.equal true
      o.get("foo").should.equal 3
      o.get("bar").should.equal 4
          
    it "should call registered observers when setting a property value via set", ->
      callback = sinon.spy()
      o.on "foo", callback
      
      o.set
        foo: 3

      callback.should.have.been.called
      
    it "should call registered observers when setting a new property value via set", ->
      callback = sinon.spy()
      o.on "newProp", callback
      
      o.set
        newProp: 3

      callback.should.have.been.called
      
    it "should call registered observers when setting a nested property value via set", ->
      callback = sinon.spy()
      o.on "nested.baz", callback
      
      o.set("nested.baz", 3)

      callback.should.have.been.called
      
    it "should also call registered observers of last nested observable when setting a nested property value via set", ->
      nestedCallback = sinon.spy()
      callback = sinon.spy()
        
      o.nested.observableObj.on "observedProp", nestedCallback
      o.on "nested.observableObj.observedProp", callback
      
      o.set("nested.observableObj.observedProp", 3)

      callback.should.have.been.called
      nestedCallback.should.have.been.called
      
    it "should also call registered observers of middle nested observable when setting a nested property value via set", ->
      nestedCallback = sinon.spy()
      callback = sinon.spy()
        
      o.nested.observableObj.on "observedObj2.observableProp2", nestedCallback
      o.on "nested.observableObj.observedObj2.observableProp2", callback
      
      o.set("nested.observableObj.observedObj2.observableProp2", 3)

      callback.should.have.been.called
      nestedCallback.should.have.been.called
      
    it "should not call unregistered observers when setting a property value via set", ->
      callback = sinon.spy()
      o.on "foo", callback
      o.off "foo", callback
      
      o.set
        foo: 3

      callback.should.not.have.been.called
      
    it "should not call unregistered observers when setting a nested property value via set", ->
      callback = sinon.spy()
      o.on "nested.baz", callback
      o.off "nested.baz", callback
      
      o.set("nested.baz", 3)

      callback.should.not.have.been.called


# Creates reused data
createData = ->
  foo: 1
  bar: 2
  nested:
    bum: 3
    observableObj: new Observable
      observedProp: 7
      observableObj2: new Observable
        observedProp2: 8 
    nested2:
      baw: 4
  
# Instantiates an Observable
instantiateObservable = ->
  new Observable(createData())
  
# Makes an existing object observable
makeObservable = ->
  o = createData()
  Observable.makeObservable(o)
  o
  

## Tests

describe "Observable", ->
  it "should be a class whose constructor is okay with getting no arguments", ->
    o = new Observable
    
  it "should be a class whose constructor copies a given object's properties", ->
    instantiateObservable()
    
  it "should let you make existing objects observable", ->
    makeObservable()
    

createTests "An Observable instance", instantiateObservable
# createTests "An object which has been made observable", makeObservable
    

  
  
