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
    case state
}

protocol RedditStorageProtocol { // Use user defaults
    func saveDeletedPost(postId: String)
    func saveReadPost(postId: String)
    func getReadPosts() -> Set<String>
    func getDeletedPosts() -> Set<String>
    func isPostRead(postId: String) -> Bool
    func resetDeletedPosts()
}

class RedditStorage: RedditStorageProtocol {

    func saveDeletedPost(postId: String) {
        saveInUserDefaults(postId: postId, for: .deleted)
    }

    func saveReadPost(postId: String) {
        saveInUserDefaults(postId: postId, for: .read)
    }

    private func saveInUserDefaults(postId: String, for key: StorageKeys) {
        let userDefaults = UserDefaults.standard
        var posts: Set<String> = Set<String>(userDefaults.object(forKey: key.rawValue) as? [String] ?? [])
        posts.insert(postId)
        userDefaults.set(Array(posts), forKey: key.rawValue)
    }

    func getReadPosts() -> Set<String> {
        return getObjectFromUserDefaults(for: .read)
    }

    func getDeletedPosts() -> Set<String> {
        return getObjectFromUserDefaults(for: .deleted)
    }

    private func getObjectFromUserDefaults(for key: StorageKeys) -> Set<String> {
        let userDefaults = UserDefaults.standard
        return Set<String>(userDefaults.object(forKey: key.rawValue) as? [String] ?? [])
    }

    func isPostRead(postId: String) -> Bool {
        // Evaluate how to avoid calling this every scroll time in tableview
        let posts = getReadPosts()
        return posts.contains(postId)
    }

    func resetDeletedPosts() {
        let userDefaults = UserDefaults.standard
        userDefaults.set([], forKey: StorageKeys.deleted.rawValue)
    }

    func saveState(datamodel: DataModel) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(datamodel, forKey: StorageKeys.state.rawValue)
    }

    func loadLastState() -> DataModel? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: StorageKeys.state.rawValue) as? DataModel
    }
}

