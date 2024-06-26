//  Content+Extensions.swift
//
//  Copyright (c) 2024 Andrea Scuderi
//

import Foundation


extension Category {
    func selected() -> Category {
        Category(name: name, range: range, isSelected: true)
    }
}

extension Breed {
    func selected() -> Breed {
        Breed(breed: breed, apiKey: apiKey, isSelected: true)
    }
}

extension Content.Item {
    var breed: Breed? {
        if case .breed(let value) = self {
            return value
        }
        return nil
    }
    
    var category: Category? {
        if case .category(let value) = self {
            return value
        }
        return nil
    }
    
    var image: Image? {
        if case .image(let value) = self {
            return value
        }
        return nil
    }
}
