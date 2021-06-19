//
//  PostImageViewController.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/19/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

class PostImageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = false
            activityIndicator.style = .large
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

    func loadImage() {
        guard let imageUrl = imageUrl else { return }
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
