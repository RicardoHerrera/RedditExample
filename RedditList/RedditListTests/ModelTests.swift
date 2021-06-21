//
//  ModelTests.swift
//  RedditListTests
//
//  Created by Ricardo Herrera on 20/06/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import XCTest
@testable import RedditList

class ModelTests: XCTestCase {

    var SUT: TopList!
    var SUTPost: Post!
    var filePath: String!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: ModelTests.self)
        filePath = bundle.path(forResource: "TopList", ofType: "json")
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
        SUT = try JSONDecoder().decode(TopList.self, from: jsonData)
        SUTPost = SUT.posts.first?.info
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecode() throws {
        XCTAssertNotNil(SUT, "Decode should work with mocked file")
    }

    func testDate() {
        let currentTimeStamp = Date().timeIntervalSince1970
        let post = Post(timeStamp: currentTimeStamp - 2)
        XCTAssertEqual(post.date(), "2 seconds ago")
    }

    func testValidImage() {
        XCTAssertTrue(SUTPost.hasValidImage(), "Mock file has valid image")
    }

    func testValidFullImage() {
        XCTAssertTrue(SUTPost.hasValidFullImage(), "Mock file has valid full image")
    }

    func testNotValidImage() {
        let post = Post()
        XCTAssertFalse(post.hasValidImage(), "Invalid image")
    }

    func testNotValidFullImage() {
        let post = Post()
        XCTAssertFalse(post.hasValidFullImage(), "Invalid image")
    }
}
