//
//  ViewController.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

class RedditListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.isHidden = true
        }
    }

    // MARK: - properties
    var presenter: RedditListPresenterProtocol? = RedditListPresenter()
    var refreshControl = UIRefreshControl()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(pullToRefres(refreshControl:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        presenter!.getTop50()
    }

    // MARK: - UserInteraction

    @objc func pullToRefres(refreshControl: UIRefreshControl) {
        guard let presenter = self.presenter else { return }
        presenter.restartPagination()
        presenter.getTop50()
        
    }

}

