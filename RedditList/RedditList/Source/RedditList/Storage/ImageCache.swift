//
//  ImageCache.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/18/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit
import Foundation

public class ImageCache {

    public static let publicCache = ImageCache()
    var placeholderImage = UIImage(named: "placeholder")!
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(UIImage?) -> Swift.Void]]()

    public final func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(url: NSURL, completion: @escaping (UIImage?) -> Swift.Void) {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        // Go fetch the image.
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            // Check for the error, then data and try to create the image.
            guard let responseData = data, let image = UIImage(data: responseData),
                error == nil else {
                DispatchQueue.main.async { [weak self] in
                    completion(self?.placeholderImage)
                }
                return
            }
            // Cache the image.
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            // Iterate over each requestor for the image and pass it back.
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

}

