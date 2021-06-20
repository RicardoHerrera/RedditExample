//
//  RedditListNetworker.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case failWith(_ error: Error?)
    case badURL
    case maxPostReached
    case invalidResponse
}

protocol RedditListNetworkerProtocol {
    func getTop(limit: Int, completioHandler: @escaping (Result<[Posts]?, NetworkError>) -> Void)
}

class RedditListNetworker: RedditListNetworkerProtocol {

    private var after: String {
        return DataModelManager.sharedInstance.after
    }
    private var count: Int {
        return  DataModelManager.sharedInstance.currentCount
    }
    private var maxTop = 50

    func getTop(limit: Int = 10, completioHandler: @escaping (Result<[Posts]?, NetworkError>) -> Void) {
        guard count < 50 else {
            completioHandler(.failure(.maxPostReached))
            return
        }

        let maxLeftPosts = maxTop - count
        let finalLimit = min(maxLeftPosts, limit)

        // Build url components with parameters
        var components = URLComponents(string: "https://www.reddit.com/top/.json")!
        var parameters: [String: String] = ["limit": "\(finalLimit)"]
        if !after.isEmpty {
            parameters["after"] = after
        }
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        // Create request
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 299) ~= response.statusCode else {
                    completioHandler(.failure(.failWith(error)))
                return
            }

            if let topList = try? JSONDecoder().decode(TopList.self, from: data) {
                // we have good data – go back to the main thread
                DataModelManager.sharedInstance.after = topList.after ?? ""
                let posts = topList.posts
                DataModelManager.sharedInstance.currentCount += posts.count
                completioHandler(.success(posts))
                // everything is good, so we can exit
                return
            } else {
                completioHandler(.failure(.invalidResponse))
                return
            }
        }.resume()
    }
}
