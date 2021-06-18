//
//  ViewController.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

protocol RedditListViewControllerProtocol: class {
    func showLoading()
    func hideLoading()
    func updateList(posts: [Posts])
    func showMessage(title: String, message: String)
}

class RedditListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = true
        }
    }

    // MARK: - properties
    var presenter: RedditListPresenterProtocol?
    var refreshControl = UIRefreshControl()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RedditListPresenter(viewController: self)
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

// MARK: - RedditListViewControllerProtocol
extension RedditListViewController: RedditListViewControllerProtocol {
    func showLoading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }

    func updateList(posts: [Posts]) {
        tableView.reloadData()
    }

    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Aceptar",
                                   style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

