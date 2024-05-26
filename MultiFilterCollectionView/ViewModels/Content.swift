//
//  Content.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 07/04/2024.
//

import Foundation
import UIKit

struct Category: Hashable {
    let name: String
    let range: ClosedRange<String>
    let isSelected: Bool
}

extension Category {
    func selected() -> Category {
        Category(name: name, range: range, isSelected: true)
    }
}

struct Breed: Hashable {
    let breed: String
    let apiKey: String
    let isSelected: Bool
}

extension Breed {
    func selected() -> Breed {
        Breed(breed: breed, apiKey: apiKey, isSelected: true)
    }
}

struct Image: Hashable {
    let url: URL
}

struct Content {
    enum Section: Int, Hashable {
        case category
        case breed
        case images
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

extension Content.Section {
    func buildLayout() -> NSCollectionLayoutSection {
        switch self {
        case .category:
            return buildCategoryLayout()
        case .breed:
            return buildBreedLayout()
        case .images:
            return buildImagesLayout()
        }
    }
    
    private func buildCategoryLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        return section
    }
    
    private func buildBreedLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(90), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(90), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12)
        return section
    }
    
    private func buildImagesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}

extension Content.Item {
    func dequeueReusableCell(collectionView: UICollectionView,
                             levelOneRegistration: UICollectionView.CellRegistration<LevelOneCollectionViewCell, Category>,
                             levelTwoRegistration: UICollectionView.CellRegistration<LevelTwoCollectionViewCell, Breed>,
                             cardRegistration: UICollectionView.CellRegistration<CardCollectionViewCell, Image>,
                             indexPath: IndexPath) -> UICollectionViewCell {
        switch self {
        case .category(let category):
            return collectionView.dequeueConfiguredReusableCell(using: levelOneRegistration, for: indexPath, item: category)
        case .breed(let breed):
            return collectionView.dequeueConfiguredReusableCell(using: levelTwoRegistration, for: indexPath, item: breed)
        case .image(let image):
            return collectionView.dequeueConfiguredReusableCell(using: cardRegistration, for: indexPath, item: image)
        }
    }
}
