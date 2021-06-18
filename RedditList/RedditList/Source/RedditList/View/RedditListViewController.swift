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
    var datasource: UITableViewDiffableDataSource<Int, Post>!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RedditListPresenter(viewController: self)
        configureView()
        presenter?.getNewPage()
    }

    // MKAR: - ConfigureView
    private func configureView() {
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(pullToRefres(refreshControl:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        configureTableView()
        // Delete all
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.fill"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapRemoveAll))
    }

    private func configureTableView() {
        tableView.delegate = self
        let postTableViewCell = UINib(nibName: "PostTableViewCell",
                                      bundle: nil)
        tableView.register(postTableViewCell,
                           forCellReuseIdentifier: PostTableViewCell.identifier())
        datasource = UITableViewDiffableDataSource(tableView: tableView,
                                                   cellProvider: { (tableView, indexPath, post) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier()) as? PostTableViewCell
                else {
                fatalError("Error loading cell")
            }
            cell.setupFor(post)
            cell.selectionStyle = .none
            if self.presenter?.isPostRead(postId: post.postId) ?? false {
                cell.contentView.backgroundColor = .white
            } else {
                cell.contentView.backgroundColor = .magenta
            }
            return cell
        })
    }

    private func updateDatasourcer() {
        guard let presenter = self.presenter else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Int, Post>()
        snapshot.appendSections([0])
        snapshot.appendItems(presenter.postsToShow)

        datasource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - UserInteraction

    @objc func pullToRefres(refreshControl: UIRefreshControl) {
        guard let presenter = self.presenter else { return }
        presenter.restartPagination()
        presenter.getNewPage()
    }

    @objc func didTapRemoveAll() {
        // Call presenter make all current items locally deleted
        print("All removed :)")
        // TODO: fix fake pagination
        presenter?.getNewPage()
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
        updateDatasourcer()
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

extension RedditListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = .white
        guard let post = datasource.itemIdentifier(for: indexPath),
            let presenter = self.presenter else { return }
        presenter.markAsRead(postId: post.postId)
    }
}
