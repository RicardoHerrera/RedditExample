//
//  RedditImageNetworker.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/19/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

protocol RedditImageNetworkerProtocol {
    func loadImageFrom(_ url: URL, completionHandler: @escaping (Result<UIImage, NetworkError>) -> Void )
}

final class RedditImageNetworker: RedditImageNetworkerProtocol {

    func loadImageFrom(_ url: URL, completionHandler: @escaping (Result<UIImage, NetworkError>) -> Void ) {
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            // Check for the error, then data and try to create the image.
            guard let responseData = data,
                let image = UIImage(data: responseData),
                error == nil else {
                    completionHandler(.failure(.failWith(error)))
                return
            }
            completionHandler(.success(image))
        }.resume()
    }
}
