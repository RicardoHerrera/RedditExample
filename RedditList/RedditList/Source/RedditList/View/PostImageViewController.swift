//
//  PostImageViewController.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/19/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

final class PostImageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = false
            activityIndicator.style = .large
            activityIndicator.startAnimating()
        }
    }

    // MARK: - Properties
    public var imageUrl: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        loadImage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUserActivity()
    }

    func loadImage() {
        guard let imageUrl = imageUrl else { return }
        // TODO: this should be in a presenter.
        ImageCache.publicCache.load(url: NSURL(string: imageUrl)!) { [weak self] (image) in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = image
            self?.loadSaveImageButton()
        }
    }

    private func loadSaveImageButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
        style: .plain,
        target: self,
        action: #selector(didTapSaveImage))
    }

    @objc func didTapSaveImage() {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage,
                         didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let message = error == nil ? "Imaged saved!" : error?.localizedDescription
        let alert = UIAlertController(title: "Saving", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Restoration

extension PostImageViewController {

    func updateUserActivity() {
        var currentUserActivity = view.window?.windowScene?.userActivity
        if currentUserActivity == nil {
            currentUserActivity = NSUserActivity(activityType: SceneDelegate.MainSceneActivityType())
        }
        currentUserActivity?.targetContentIdentifier = imageUrl
        currentUserActivity?.addUserInfoEntries(from: [SceneDelegate.postUrlImage: imageUrl!,
                                                       SceneDelegate.targetKey: SceneDelegate.postImageContentIdentifier])
        view.window?.windowScene?.userActivity = currentUserActivity
        view.window?.windowScene?.session.userInfo = [SceneDelegate.valueToRestoreKey: imageUrl!]
    }
}
