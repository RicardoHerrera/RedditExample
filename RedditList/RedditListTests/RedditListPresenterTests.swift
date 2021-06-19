//
//  RedditListPresenterTests.swift
//  RedditListTests
//
//  Created by Ricardo Herrera on 6/19/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import XCTest
@testable import RedditList

class RedditListPresenterTests: XCTestCase {

    var SUT: RedditListPresenter!
    var viewController: MockViewController = MockViewController()
    var network: MockNetwork = MockNetwork()
    var storage = MockStorage()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SUT = RedditListPresenter(networker: network,
                                  storage: storage,
                                  viewController: viewController)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetNewPage() {
        SUT?.getNewPage()
        XCTAssert(viewController.showLoadingCalled, "View controller should start loading for user")
    }

    func testDeletePost() {
        SUT?.postsToShow = [Post()]
        SUT?.deletePost(at: 0)
        XCTAssert(storage.saveDeletedPostCalled, "storage should save deleted item")
        XCTAssert(viewController.updateListCalled, "View controller should upload list")
    }

    func testDeleteAllPost() {
        SUT.postsToShow = [Post(), Post()]
        SUT.deleteAllPosts()
        XCTAssert(storage.saveDeletedPostCalled, "storage should save deleted item")
        XCTAssert(viewController.updateListCalled, "View controller should upload list")
        XCTAssertEqual(SUT.postsToShow.count, 0)
    }

    func testMarkAsRead() {
        SUT.markAsRead(postId: "testId")
        XCTAssertEqual("testId", storage.readPost, "Should save the correct ID")
    }

    func testIsPostRead() {
        _ = SUT.isPostRead(postId: "readPost")
        XCTAssert(storage.isPostRead, "Validate id")
    }

    func testIsPostReadFalse() {
        _ = SUT.isPostRead(postId: "unreadPost")
        XCTAssertFalse(storage.isPostRead, "Validate id")
    }

    func testRestartPagination() {
        SUT?.restartPagination()
        XCTAssert(network.resetPaginationCalled, "Network should restart values")
    }
}

class MockViewController: RedditListViewControllerProtocol {

    var showLoadingCalled = false
    var hideLoadingCalled = false
    var updateListCalled = false
    var showMessageCalled = false
    var deletePostCalled = false
    var presentPostDetailCalled = false

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }

    func updateList() {
        updateListCalled = true
    }

    func showMessage(title: String, message: String) {
        showMessageCalled = true
    }

    func deletePost(at index: Int) {
        deletePostCalled = true
    }

    func presentPostDetail(imageUrl: String) {
        presentPostDetailCalled = true
    }
}

class MockNetwork: RedditListNetworkerProtocol {

    var resetPaginationCalled = false

    func getTop(limit: Int, completioHandler: @escaping ([Posts]?, Error?) -> Void) {
        completioHandler([], nil)
    }

    func resetPagination() {
        resetPaginationCalled = true
    }
}

class MockStorage: RedditStorageProtocol {

    var saveDeletedPostCalled = false
    var readPost = ""
    var getReadPostsCalled = false
    var getDeletedPostsCalled = false
    var resetDeletedPostsCalled = false
    var isPostRead = false

    func saveDeletedPost(postId: String) {
        saveDeletedPostCalled = true
    }

    func saveReadPost(postId: String) {
        readPost = postId
    }

    func getReadPosts() -> Set<String> {
        getReadPostsCalled = true
        return []
    }

    func getDeletedPosts() -> Set<String> {
        getDeletedPostsCalled = true
        return []
    }

    func isPostRead(postId: String) -> Bool {
        if postId == "readPost" {
            isPostRead = true
        }
        return true
    }

    func resetDeletedPosts() {
        resetDeletedPostsCalled = true
    }
}
