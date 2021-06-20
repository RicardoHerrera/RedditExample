//
//  RedditListPresenter.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditListPresenterProtocol {
    func initialLoad()
    func getNewPage()
    func deletePost(at index: Int)
    func deleteAllPosts()
    func markAsRead(postId: String)
    func isPostRead(postId: String) -> Bool
    func restartPagination()
    var postsToShow: [Post] { get }
}

final class RedditListPresenter: RedditListPresenterProtocol {

    let networker: RedditListNetworkerProtocol
    var storage: RedditStorageProtocol {
        return DataModelManager.sharedInstance.storage
    }
    weak var viewcontroller: RedditListViewControllerProtocol?
    var postsToShow: [Post] {
        return DataModelManager.sharedInstance.postToShow
    }
    var paging = 7
    var currentPage = 0

    init(networker: RedditListNetworkerProtocol = RedditListNetworker(),
         viewController: RedditListViewControllerProtocol) {
        self.networker = networker
        self.viewcontroller = viewController
    }

    func initialLoad() {
        if DataModelManager.sharedInstance.postToShow.count == 0
            && DataModelManager.sharedInstance.currentCount == 0 {
            getNewPage()
        }
    }

    func getNewPage() {
        viewcontroller?.showLoading()
        networker.getTop(limit: paging) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.viewcontroller?.hideLoading()
                    self.viewcontroller?.showMessage(title: "Error",
                    message: error.localizedDescription)
                    // Here I could do a switch case for error types
                }
            case .success(let posts):
                guard let posts = posts else {
                    DispatchQueue.main.async {
                        self.viewcontroller?.hideLoading()
                        self.viewcontroller?.showMessage(title: "Error",
                        message: "Ocurrió un error")
                    }
                    return
                }
                // Filter posts with deleted ones
                let deletedPosts = self.storage.getDeletedPosts()
                let filtered = posts.filter( { !deletedPosts.contains($0.info.postId) } )
                DataModelManager.sharedInstance.append(posts: filtered.map( { $0.info } ))
                DispatchQueue.main.async {
                    //Stop loading
                    self.viewcontroller?.hideLoading()
                    // Reload table view with posts
                    self.viewcontroller?.updateList()
                }
            }
        }
    }

    func deletePost(at index: Int) {
        let post = postsToShow[index]
        storage.saveDeletedPost(postId: post.postId)
        DataModelManager.sharedInstance.removePost(at: index)
        viewcontroller?.updateList()
    }

    func deleteAllPosts() {
        for post in postsToShow {
            storage.saveDeletedPost(postId: post.postId)
        }
        DataModelManager.sharedInstance.removeAllPosts()
        viewcontroller?.updateList()
    }

    func markAsRead(postId: String) {
        storage.saveReadPost(postId: postId)
    }

    func isPostRead(postId: String) -> Bool {
        return storage.isPostRead(postId: postId)
    }

    func restartPagination() {
        DataModelManager.sharedInstance.resetValues()
        storage.resetDeletedPosts()
    }
}
