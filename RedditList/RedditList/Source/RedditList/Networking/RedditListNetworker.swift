//
//  RedditListNetworker.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

protocol RedditListNetworkerProtocol {
    func getTop(completioHandler: @escaping (_ posts: [Posts]?, _ error: Error?) -> Void)
}

class RedditListNetworker: RedditListNetworkerProtocol {
    
    func getTop(completioHandler: @escaping (_ posts: [Posts]?, _ error: Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.reddit.com/top/.json?limit=2")!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 299) ~= response.statusCode else {
                completioHandler(nil, error)
                return
            }

            if let topList = try? JSONDecoder().decode(TopList.self, from: data) {
                // we have good data – go back to the main thread
                let posts = topList.posts
                for post in posts {
                    print(post.info)
                }
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
}
