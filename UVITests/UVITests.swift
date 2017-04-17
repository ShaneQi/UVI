//
//  UVITests.swift
//  UVITests
//
//  Created by Shane Qi on 3/9/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import XCTest
@testable import UVI

class UVITests: XCTestCase {

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testUVIUserDefaults() {
		let origin = UVIUserDefaults.default.userUid
		UVIUserDefaults.default.userUid = "hello"
		XCTAssert(UVIUserDefaults.default.userUid == "hello")
		UVIUserDefaults.default.userUid = origin
		XCTAssert(UVIUserDefaults.default.userUid == origin)
	}

	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}

}
