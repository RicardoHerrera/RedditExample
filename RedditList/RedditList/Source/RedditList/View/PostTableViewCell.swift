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
        selectionStyle = .none
        titleLabel.text = post.title
        authorLabel.text = "By " + post.author
        let sufix = (post.comments == 1) ? "comment" : "comments"
        commentsLabel.text = "\(post.comments) " + sufix
        timeAgoLabel.text = post.date()
        postImageView.image = UIImage(named: "placeholder")
        loadImageFor(post)
    }

    func updatethumbnailWith(image: UIImage) {
        postImageView.image = image
    }

    func loadImageFor(_ post: Post) {
        guard let url = NSURL(string: post.thumbnailURL),
            UIApplication.shared.canOpenURL(url as URL) else {
                self.postImageView.image = UIImage(named: "placeholder")
                return
        }
        ImageCache.publicCache.load(url: url) { (image) in
            self.postImageView.image = image
        }
    }

    // MARK: - Helper
    class func identifier() -> String {
        return "PostTableViewCell"
    }
}
