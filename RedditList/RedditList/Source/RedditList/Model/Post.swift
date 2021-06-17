//
//  Post.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

struct Post { //Mappable
    
    var author: String
    var comments: Int
    var thumbnailURL: String
    var fullImageURL: String
    var isVideo: Bool
    var timeStamp: Double
    
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
