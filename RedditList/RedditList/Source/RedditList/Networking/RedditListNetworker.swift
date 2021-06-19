//
//  RedditListNetworker.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditListNetworkerProtocol {
    func getTop(limit: Int, completioHandler: @escaping (_ posts: [Posts]?, _ error: Error?) -> Void)
    func resetPagination()
}

class RedditListNetworker: RedditListNetworkerProtocol {

    private var after: String = ""
    private var count = 0
    private var maxTop = 50

    func getTop(limit: Int = 10, completioHandler: @escaping (_ posts: [Posts]?, _ error: Error?) -> Void) {
        guard count < 50 else {
            let customError = NSError(domain: "Reddit", code: 888,
                                      userInfo: [ NSLocalizedDescriptionKey: "Top 50 reached"])
            completioHandler(nil, customError)
            return
        }

        let maxLeftPosts = maxTop - count
        let finalLimit = min(maxLeftPosts, limit)

        var url = "https://www.reddit.com/top/.json"
        url += "?limit=\(finalLimit)"
        if !after.isEmpty { url += "&after=\(after)" }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil,
                let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 299) ~= response.statusCode else {
                completioHandler(nil, error)
                return
            }

            if let topList = try? JSONDecoder().decode(TopList.self, from: data) {
                // we have good data – go back to the main thread
                self?.after = topList.after ?? ""
                let posts = topList.posts
                self?.count += posts.count
                completioHandler(posts, nil)
                // everything is good, so we can exit
                return
            } else {
                let customError = NSError(domain: "", code: 999,
                                          userInfo: [ NSLocalizedDescriptionKey: "Invalid JSon"])
                completioHandler(nil, customError)
                return
            }
        }.resume()
    }

    func resetPagination() {
        after = ""
        count = 0
    }
}
