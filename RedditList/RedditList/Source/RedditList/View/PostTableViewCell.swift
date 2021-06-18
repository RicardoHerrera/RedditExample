//
//  PostTableViewCell.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView! {
        didSet {
            postImageView.image = UIImage(named: "placeholder")
        }
    }

    // MARK: - Config
    func setupFor(_ post: Post) {
        titleLabel.text = post.title
        authorLabel.text = "By " + post.author
        let prefix = (post.comments == 1) ? "comment" : "comments"
        commentsLabel.text = "\(post.comments) " + prefix
        timeAgoLabel.text = post.date()
    }

    // MARK: - Helper
    class func identifier() -> String {
        return "PostTableViewCell"
    }
}
