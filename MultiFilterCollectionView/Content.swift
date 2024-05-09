//
//  Content.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 07/04/2024.
//

import Foundation
import UIKit

struct Content {
    enum Section: Int, Hashable {
        case breed
        case subBreed
        case images
    }
    
    enum Item {
        case breed(String)
        case subBreed(String)
        case image(String)
    }
}

extension Content.Item {
    var breed: String? {
        if case .breed(let string) = self {
            return string
        }
        return nil
    }
    
    var subBreed: String? {
        if case .subBreed(let string) = self {
            return string
        }
        return nil
    }
    
    var image: URL? {
        if case .image(let string) = self,
           let url = URL(string: string) {
            return url
        }
        return nil
    }
}

extension Content.Section {
    func buildLayout() -> NSCollectionLayoutSection {
        switch self {
        case .breed:
            return buildBreedLayout()
        case .subBreed:
            return buildSubBreedLayout()
        case .images:
            return buildImagesLayout()
        }
    }
    
    private func buildBreedLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private func buildSubBreedLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private func buildImagesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}
