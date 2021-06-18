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
    func updateList()
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
        configureView()
        presenter!.getTop50()
    }

    // MKAR: - ConfigureView
    private func configureView() {
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(pullToRefres(refreshControl:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        let postTableViewCell = UINib(nibName: "PostTableViewCell",
                                  bundle: nil)
        tableView.register(postTableViewCell,
                                forCellReuseIdentifier: PostTableViewCell.identifier())
        tableView.dataSource = self
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

    func updateList() {
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

extension RedditListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.postsToShow.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.identifier()) as? PostTableViewCell,
            let presenter = self.presenter else {
            fatalError("Error loading cell")
        }
        let post = presenter.postsToShow[indexPath.row].info
        cell.setupFor(post)

        return cell
    }
}
