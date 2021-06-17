//
//  RedditListPresenter.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditListPresenterProtocol {
    func getTop50() -> [String] // make async with completion
    func getNextPage(page: Int) -> [String]
    func deleteItems(idList: [String])

}

class RedditListPresenter: RedditListPresenterProtocol {

    let networker: RedditListNetworkerProtocol

    init(networker: RedditListNetworkerProtocol = RedditListNetworker()) {
        self.networker = networker
    }

    func getTop50() -> [String] {
        return []
    }
    
    func getNextPage(page: Int) -> [String] {
        return []
    }
    
    func deleteItems(idList: [String]) {
    }
}
