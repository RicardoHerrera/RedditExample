//
//  RedditStorageHandler.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

enum StorageKeys: String {
    case deleted
    case read
}

protocol RedditStorageProtocol { // Use user defaults
    func saveDeletedPost(postId: String)
    func getReadPosts() -> [String]
    func getDeletedPosts() -> [String]
    func isPostRead(postId: String) -> Bool
}

class RedditStorage: RedditStorageProtocol {

    func saveDeletedPost(postId: String) {
        saveInUserDefaults(postId: postId, for: .deleted)
    }

    func saveReadPost(postId: String) {
        saveInUserDefaults(postId: postId, for: .read)
    }

    func saveInUserDefaults(postId: String, for key: StorageKeys) {
        let userDefaults = UserDefaults.standard
        var deletedPosts: [String] = userDefaults.object(forKey: key.rawValue) as? [String] ?? [String]()
        deletedPosts.append(postId)
        userDefaults.set(deletedPosts, forKey: key.rawValue)
    }

    func getReadPosts() -> [String] {
        return getObjectFromUserDefaults(for: .read)
    }

    func getDeletedPosts() -> [String] {
        return getObjectFromUserDefaults(for: .deleted)
    }

    func getObjectFromUserDefaults(for key: StorageKeys) -> [String] {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: key.rawValue) as? [String] ?? [String]()
    }

    func isPostRead(postId: String) -> Bool {
        // Evaluate how to avoid calling this every scroll time in tableview
        let posts = getReadPosts()
        return posts.contains(postId)
    }

}

