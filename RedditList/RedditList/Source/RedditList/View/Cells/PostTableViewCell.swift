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
            postImageView.isUserInteractionEnabled = false
        }
    }

    // MARK: - properties
    weak var delegate: RedditListViewControllerProtocol?
    private var fullImageUrl: String?

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
        fullImageUrl = post.fullImageURL
        addActionToImage(post: post)
    }

    func updatethumbnailWith(image: UIImage) {
        postImageView.image = image
    }

    func loadImageFor(_ post: Post) {
        guard post.hasValidImage() else {
                self.postImageView.image = UIImage(named: "placeholder")
                return
        }
        ImageCache.publicCache.load(url: NSURL(string: post.thumbnailURL)!) { (image) in
            self.postImageView.image = image
        }
    }

    func addActionToImage(post: Post) {
        guard post.hasValidFullImage() else { return }

        postImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(presentPostDetail))
        postImageView.addGestureRecognizer(tapGesture)
    }

    @objc func presentPostDetail() {
        guard let delegate = delegate,
            let fullImageUrl = self.fullImageUrl else { return }
        delegate.presentPostDetail(imageUrl: fullImageUrl)
    }

    // MARK: - Helper
    class func identifier() -> String {
        return "PostTableViewCell"
    }
}
