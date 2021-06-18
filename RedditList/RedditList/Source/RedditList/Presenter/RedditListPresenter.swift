//
//  RedditListPresenter.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditListPresenterProtocol {
    func getNewPage()
    func deletePost(postId: String)
    func deleteAllPosts()
    func markAsRead(postId: String)
    func isPostRead(postId: String) -> Bool
    func restartPagination()
    var postsToShow: [Post] { get }
}

class RedditListPresenter: RedditListPresenterProtocol {

    let networker: RedditListNetworkerProtocol
    let storage: RedditStorageProtocol
    weak var viewcontroller: RedditListViewControllerProtocol?
    var postsToShow: [Post] = []
    var paging = 2
    var currentPage = 0

    init(networker: RedditListNetworkerProtocol = RedditListNetworker(),
         storage: RedditStorageProtocol = RedditStorage(),
         viewController: RedditListViewControllerProtocol) {
        self.networker = networker
        self.storage = storage
        self.viewcontroller = viewController
    }

    func getNewPage() {
        viewcontroller?.showLoading()
        networker.getTop(limit: paging) { [weak self] (posts, error) in
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
            let filtered = posts.filter( { !deletedPosts.contains($0.info.postId) } )
            self.postsToShow.append(contentsOf: filtered.map( { $0.info } ))
            DispatchQueue.main.async {
                //Stop loading
                self.viewcontroller?.hideLoading()
                // Reload table view with posts
                self.viewcontroller?.updateList()
            }
        }
    }

    func deletePost(postId: String) {
        storage.saveDeletedPost(postId: postId)
    }

    func deleteAllPosts() {
        for post in postsToShow {
            deletePost(postId: post.postId)
        }
    }

    func markAsRead(postId: String) {
        storage.saveReadPost(postId: postId)
    }

    func isPostRead(postId: String) -> Bool {
        return storage.isPostRead(postId: postId)
    }

    func restartPagination() {
        networker.resetPagination()
        currentPage = 0
        postsToShow = []
    }
}
