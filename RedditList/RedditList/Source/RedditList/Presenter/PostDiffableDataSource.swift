//
//  PostDiffableDataSource.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/18/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

class PostDiffableDataSource: UITableViewDiffableDataSource<Int, Post> {

    weak var delegate: RedditListViewControllerProtocol?

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var snapshot = self.snapshot()
            if let post = itemIdentifier(for: indexPath) {
                snapshot.deleteItems([post])
                apply(snapshot, animatingDifferences: true)
                delegate?.deletePost(at: indexPath.row)
            }
        }
    }
}
