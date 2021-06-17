//
//  RedditStorageHandler.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditStorageProtocol { // Use user defaults
    func getReadPosts() -> [Post]
    func getDeletedPots() -> [Post]
}

class RedditStorage: RedditStorageProtocol {
    func getReadPosts() -> [Post] {
        return []
    }

    func getDeletedPots() -> [Post] {
        return []
    }

}

