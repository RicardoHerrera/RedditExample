//
//  Post.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

struct TopList: Decodable {
    let after: String?
    let posts: [Posts]

    enum ContainerKeys: String, CodingKey {
        case data
    }

    enum DataKeys: String, CodingKey {
        case after
        case children
    }

    // MARK: - init with decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContainerKeys.self)
        let data = try container.nestedContainer(keyedBy: DataKeys.self,
                                                 forKey: .data)
        posts = try data.decode([Posts].self, forKey: .children)
        after = try? data.decode(String.self, forKey: .after)
    }
}

struct Posts: Decodable {
    let info: Post

    enum CodingKeys: String, CodingKey {
        case info = "data"
    }
}

struct Post: Decodable {

    let postId: String
    let title: String
    let author: String
    let comments: Int
    let thumbnailURL: String
    let fullImageURL: String
    let isVideo: Bool
    let timeStamp: Double

    enum CodingKeys: String, CodingKey {
        case postId = "name"
        case comments = "num_comments"
        case thumbnailURL = "thumbnail"
        case fullImageURL = "url"
        case isVideo = "is_video"
        case timeStamp = "created"
        case author, title
    }
    
    func date() -> String {
        let date: Date = Date(timeIntervalSince1970: timeStamp)
        return timeAgoDisplay(date: date)
    }
    
    private func timeAgoDisplay(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
