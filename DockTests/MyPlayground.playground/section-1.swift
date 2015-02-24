// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

class TestClass: NSObject {
    override init() { self.name = "?" }
    init(name: String) { self.name = name }
    
    var name: String
}

var test = TestClass(name: "Test")

test.name






