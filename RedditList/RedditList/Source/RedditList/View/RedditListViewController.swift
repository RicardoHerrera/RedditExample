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
    func deletePost(at index: Int)
}

class RedditListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = true
            activityIndicator.style = .large
        }
    }

    // MARK: - properties
    var presenter: RedditListPresenterProtocol?
    var refreshControl = UIRefreshControl()
    var datasource: PostDiffableDataSource!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RedditListPresenter(viewController: self)
        configureView()
        presenter?.getNewPage()
    }

    // MKAR: - ConfigureView
    private func configureView() {
        // Pull to refresh
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(pullToRefres(refreshControl:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        configureTableView()
        // Title
        title = "Reddit - Top 50"
        // Delete all
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.fill"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapRemoveAll))
    }

    private func configureTableView() {
        tableView.delegate = self
        // Handle cell config
        let postTableViewCell = UINib(nibName: "PostTableViewCell",
                                      bundle: nil)
        tableView.register(postTableViewCell,
                           forCellReuseIdentifier: PostTableViewCell.identifier())
        tableView.rowHeight = UITableView.automaticDimension
        // Handle datasource
        datasource = PostDiffableDataSource(tableView: tableView,
                                            cellProvider: { [weak self] (tableView, indexPath, post) -> UITableViewCell? in
            guard let self = self else { fatalError("View controller doesn't exists")}
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier()) as? PostTableViewCell
                else {
                fatalError("Error loading cell")
            }
            // Configure cell
            cell.setupFor(post)
            if self.presenter?.isPostRead(postId: post.postId) ?? false {
                cell.contentView.backgroundColor = .white
            } else {
                cell.contentView.backgroundColor = .magenta
            }
            return cell
        })
        // TODO: Find a better name e.g. uidelegate vcdelegate (?) argh..
        datasource.delegate = self
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
        presenter?.deleteAllPosts()
    }
}

// MARK: - RedditListViewControllerProtocol
extension RedditListViewController: RedditListViewControllerProtocol {
    func showLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = refreshControl.isRefreshing
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

    func deletePost(at index: Int) {
        guard let presenter = self.presenter else { return }
        presenter.deletePost(at: index)
    }
}

// MARK: - UITableViewDelegate
extension RedditListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = .white
        guard let post = datasource.itemIdentifier(for: indexPath),
            let presenter = self.presenter else { return }
        presenter.markAsRead(postId: post.postId)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maxOffset - currentOffset <= 10.0
            && !refreshControl.isRefreshing
            && activityIndicator.isHidden {
            presenter?.getNewPage()
        }
    }
}
