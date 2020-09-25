//
//  streamflowTests.swift
//  streamflowTests
//
//  Created by 周煜杰 on 2020/2/4.
//  Copyright © 2020 周煜杰. All rights reserved.
//

import XCTest
@testable import streamflow

class streamflowTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print("test example")
        
        RequestFeatureUtil.getFeature(x: -13770103.02913648, y: 5037686.105056448) { (result) in
            print(result)
        }
        
        XCTWaiter.wait(for: [XCTestExpectation(description: "Hello World!")], timeout: 10.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
