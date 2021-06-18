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
    var postsToShow: [Posts] { get }
}

class RedditListPresenter: RedditListPresenterProtocol {

    let networker: RedditListNetworkerProtocol
    let storage: RedditStorageProtocol
    weak var viewcontroller: RedditListViewControllerProtocol?
    var postsToShow: [Posts] = []
    var paging = 10
    var currentPage = 0

    init(networker: RedditListNetworkerProtocol = RedditListNetworker(),
         storage: RedditStorageProtocol = RedditStorage(),
         viewController: RedditListViewControllerProtocol) {
        self.networker = networker
        self.storage = storage
        self.viewcontroller = viewController
    }

    func getTop50() {
        viewcontroller?.showLoading()
        networker.getTop { [weak self] (posts, error) in
            guard let self = self else { return }
            guard error == nil,
                let posts = posts else {
                // Show error in VC
                    self.viewcontroller?.showMessage(title: "Error",
                                                     message: error?.localizedDescription ?? "Ocurrió un error")
                return
            }
            // Filter posts with deleted ones
            let deletedPosts = self.storage.getDeletedPosts()
            self.postsToShow = posts.filter( { !deletedPosts.contains($0.info.postId) } )
            DispatchQueue.main.async {
                //Stop loading
                self.viewcontroller?.hideLoading()
                // Reload table view with posts
                self.viewcontroller?.updateList()
            }
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
