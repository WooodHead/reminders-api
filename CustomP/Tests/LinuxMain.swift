import XCTest

import CustomPTests

var tests = [XCTestCaseEntry]()
tests += CustomPTests.allTests()
XCTMain(tests)
