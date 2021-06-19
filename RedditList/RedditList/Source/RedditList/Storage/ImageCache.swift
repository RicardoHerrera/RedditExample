//
//  ImageCache.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/18/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit
import Foundation

final class ImageCache {

    public static let publicCache = ImageCache()
    var placeholderImage = UIImage(named: "placeholder")!
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(UIImage?) -> Swift.Void]]()
    var networker: RedditImageNetworkerProtocol

    init(networker: RedditImageNetworkerProtocol = RedditImageNetworker()) {
        self.networker = networker
    }

    func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }

    func load(url: NSURL, completion: @escaping (UIImage?) -> Void) {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        // fetch the image.
        networker.loadImageFrom(url as URL) { (result) in
            switch result {
            case .failure(let error):
                print("Error downloading image: " + error.localizedDescription)
                DispatchQueue.main.async { [weak self] in
                    completion(self?.placeholderImage)
                }
            case .success(let image):
                // Cache the image.
                self.cachedImages.setObject(image, forKey: url)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

}

