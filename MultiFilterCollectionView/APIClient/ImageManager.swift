//
//  ImageManager.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 26/05/2024.
//

import Foundation
import UIKit

struct ImageManager {
    
    static let shared = ImageManager()
    
    private var cache: NSCache<NSURL, UIImage> = NSCache()
    
    init() {
        cache.countLimit = 50
    }
    
    func getImage(for url: URL) async throws -> UIImage? {
        if let key = NSURL(string: url.absoluteString),
            let cachedImage = cache.object(forKey: key) {
            return cachedImage
        } else {
            let response = try await URLSession.shared.data(for: URLRequest(url: url))
            let image = UIImage(data: response.0)
            if let key = NSURL(string: url.absoluteString),
               let image {
                cache.setObject(image, forKey: key)
            }
            return image
        }
    }
}

