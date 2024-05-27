//
//  Content.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 07/04/2024.
//

import Foundation
import UIKit

// MARK: 1 - Define your Data Model

struct Category: Hashable {
    let name: String
    let range: ClosedRange<String>
    let isSelected: Bool
}

struct Breed: Hashable {
    let breed: String
    let apiKey: String
    let isSelected: Bool
}

struct Image: Hashable {
    let url: URL
}

struct Content {
    enum SectionType: Int, Hashable {
        case category
        case breed
        case images
    }
    
    struct Section: Hashable {
        var id: String
        var type: SectionType
    }
    
    enum Item: Hashable {
        case category(Category)
        case breed(Breed)
        case image(Image)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .category(let item):
                hasher.combine(item.hashValue)
            case .breed(let item):
                hasher.combine(item.hashValue)
            case .image(let image):
                hasher.combine(image)
            }
        }
    }
}
