//
//  ViewController.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 07/04/2024.
//

import UIKit

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var collectionViewLayout: UICollectionViewCompositionalLayout!
    let service = Service()
    let viewModel = SectionViewModel()
    var dataSource: UICollectionViewDiffableDataSource<Content.Section, Content.Item>?
    
    func update() async throws {
        let sections = try await viewModel.fetchData(service: service)
        var snapshot = NSDiffableDataSourceSnapshot<Content.Section, Content.Item>()
        let sectionKeys = sections.keys.sorted { $0.rawValue < $1.rawValue }
        for sectionKey in sectionKeys {
            if let items = sections[sectionKey] {
                snapshot.appendSections([sectionKey])
                snapshot.appendItems(items, toSection: sectionKey)
            }
        }
        dataSource?.apply(snapshot, animatingDifferences: true, completion: {
            print("done")
        })
    }
    
    func updateInBackground() {
        Task {
            do {
                try await update()
            } catch {
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateInBackground()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupView()
        self.setupConstraints()
        self.dataSource = self.makeDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func setupView() {
        collectionViewLayout = buildCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        view.backgroundColor = .white
        title = "MultiFilterCollectionView"
        view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func createLevelOneCellRegistration() -> UICollectionView.CellRegistration<LevelOneCollectionViewCell, Category> {
        UICollectionView.CellRegistration<LevelOneCollectionViewCell, Category> { [weak self] (cell, indexPath, item) in
            cell.item = item
            cell.icon = UIImage(systemName: "pawprint")
            if item.isSelected {
                self?.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func createLevelTwoCellRegistration() -> UICollectionView.CellRegistration<LevelTwoCollectionViewCell, Breed> {
        UICollectionView.CellRegistration<LevelTwoCollectionViewCell, Breed> { [weak self] (cell, indexPath, item) in
            cell.item = item.breed
            cell.image = UIImage(systemName: "pawprint")
            cell.position = indexPath.item
            if item.isSelected {
                self?.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func createCardCellRegistration() -> UICollectionView.CellRegistration<CardCollectionViewCell, Image> {
        UICollectionView.CellRegistration<CardCollectionViewCell, Image> { (cell, indexPath, item) in
            Task { @MainActor in
                let response = try await URLSession.shared.data(for: URLRequest(url: item.url))
                let image = UIImage(data: response.0)
                cell.image = image
            }
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Content.Section, Content.Item> {
        let levelOneRegistration = createLevelOneCellRegistration()
        let levelTwoRegistration = createLevelTwoCellRegistration()
        let cardRegistration = createCardCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Content.Section, Content.Item>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                item.dequeueReusableCell(collectionView: collectionView, levelOneRegistration: levelOneRegistration, levelTwoRegistration: levelTwoRegistration, cardRegistration: cardRegistration, indexPath: indexPath)
            })
        return dataSource
    }

    func buildCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] section, _ in
            guard let sectionId = self?.dataSource?.sectionIdentifier(for: section) else { return nil }
            return sectionId.buildLayout()
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .category(let item):
            return item.name != viewModel.selectedCategory
        case .breed(let breed):
            return true
        case .image(let image):
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .category(let item):
            collectionView.selectOneIndexInSection(at: indexPath, animated: true)
            viewModel.selectCategory(category: item.name)
            updateInBackground()
        case .breed(let breed):
            viewModel.selectBreed(breed: breed.breed)
            updateInBackground()
        case .image(let image):
            print(image)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .category(let category):
            print(category)
        case .breed(let breed):
            viewModel.selectBreed(breed: breed.breed)
            updateInBackground()
        case .image(let image):
            print(image)
        }
    }
}

extension UICollectionView {
    func deselectAllInSection(section: Int, animated: Bool) {
        guard let selectedIndexesInSection = indexPathsForSelectedItems?
            .filter({  $0.section == section }) else { return }
        for index in selectedIndexesInSection {
            deselectItem(at: index, animated: animated)
        }
    }
    
    func selectOneIndexInSection(at indexPath: IndexPath, animated: Bool) {
        deselectAllInSectionExcept(at: indexPath, animated: animated)
        selectItem(at: indexPath, animated: animated, scrollPosition: [])
    }
    
    private func deselectAllInSectionExcept(at indexPath: IndexPath, animated: Bool) {
        guard let selectedIndexesInSection = indexPathsForSelectedItems?
            .filter({  $0.section == indexPath.section && $0.row != indexPath.row }) else { return }
        for index in selectedIndexesInSection {
            deselectItem(at: index, animated: animated)
        }
    }
    
//    func scrollToFirstItemIfAvailable(animated: Bool = false) {
//        for section in 0..<numberOfSections {
//            let items = numberOfItems(inSection: section)
//            if items > 0 {
//                let firstIndexPath = IndexPath(row: 0, section: section)
//                scrollToItem(at: firstIndexPath, at: .right, animated: animated)
//            }
//        }
//    }
}
