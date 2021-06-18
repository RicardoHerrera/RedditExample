//
//  RedditListPresenter.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditListPresenterProtocol {
    func getTop50()// make async with completion
    func getNextPage(page: Int) -> [String]
    func deleteItems(idList: [String])
    func restartPagination()
}

class RedditListPresenter: RedditListPresenterProtocol {

    let networker: RedditListNetworkerProtocol
    let storage: RedditStorageProtocol
    var postsToShow = [Post]()
    var paging = 10
    var currentPage = 0

    init(networker: RedditListNetworkerProtocol = RedditListNetworker(),
         storage: RedditStorageProtocol = RedditStorage()) {
        self.networker = networker
        self.storage = storage
    }

    func getTop50() {
        networker.getTop { [weak self] (posts, error) in
            guard error == nil else {
                // Show error in VC
                return
            }
            guard let self = self else { return }
            // Filter posts with deleted ones
            let deletedPosts = self.storage.getDeletedPosts()
            let filtered = posts?.filter( { !deletedPosts.contains($0.info.postId) } )
            // Reload table view with posts
        }
    }
    
    func getNextPage(page: Int) -> [String] {
        // page = 1

        return []//postsToShow[currentPage..currentPage + paging]
    }

    func deleteItems(idList: [String]) {
    }

    func restartPagination() {
        currentPage = 0
    }
}
