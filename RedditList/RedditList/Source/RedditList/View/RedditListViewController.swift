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
    func presentPostDetail(imageUrl: String)
}

final class RedditListViewController: UIViewController {

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
    var isFirstLoad = true
    var presenter: RedditListPresenterProtocol!
    var refreshControl = UIRefreshControl()
    var datasource: PostDiffableDataSource!
    var tableViewPos: Double = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RedditListPresenter(viewController: self)
        configureView()
        presenter?.initialLoad()
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
        tableView.estimatedRowHeight = 120
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
            cell.delegate = self
            cell.configureAsRead(
                isRead: self.presenter.isPostRead(postId: post.postId))
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

        datasource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let self = self else { return }
            if self.isFirstLoad {
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x:0, y: self.tableViewPos), animated: false)
                self.isFirstLoad.toggle()
            }
            self.updateUserActivity()
        }
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
        let cell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        cell.configureAsRead(isRead: true)
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateUserActivity()
    }
}

// MARK: - Handle navigation
extension RedditListViewController {
    func presentPostDetail(imageUrl: String) {
        performSegue(withIdentifier: "PostDetail", sender: imageUrl)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostDetail",
            let imageUrl = sender as? String {
            if let destinationVC = segue.destination as? PostImageViewController {
                destinationVC.imageUrl = imageUrl
            }
        }
    }
}

// MARK: - Restoration

extension RedditListViewController {

    func updateUserActivity() {
        var currentUserActivity = view.window?.windowScene?.userActivity
        if currentUserActivity == nil {
            currentUserActivity = NSUserActivity(activityType: SceneDelegate.MainSceneActivityType())
        }
        currentUserActivity?.targetContentIdentifier = SceneDelegate.listContentIdentifier
        currentUserActivity?.addUserInfoEntries(from: [SceneDelegate.tableViewPos: tableView.contentOffset.y,
                                                       SceneDelegate.targetKey: SceneDelegate.listContentIdentifier])
        view.window?.windowScene?.userActivity = currentUserActivity
        view.window?.windowScene?.session.userInfo = [SceneDelegate.valueToRestoreKey: tableView.contentOffset.y]
    }
}
