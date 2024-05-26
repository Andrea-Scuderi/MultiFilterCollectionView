//
//  MultiFilterViewController.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 07/04/2024.
//

import UIKit

class MultiFilterViewController: UIViewController {
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    var collectionView: UICollectionView!
    var collectionViewLayout: UICollectionViewCompositionalLayout!
    let service = Service()
    let viewModel = SectionViewModel()
    var dataSource: UICollectionViewDiffableDataSource<Content.Section, Content.Item>?
    
    func update() async throws {
        let sections = try await viewModel.fetchData(service: service)
        var snapshot = NSDiffableDataSourceSnapshot<Content.Section, Content.Item>()
        let sectionKeys = sections.keys.sorted { section0, section1 in
            guard section0.type == section1.type else { return section0.type.rawValue < section1.type.rawValue }
            return section0.id < section1.id
        }
        for sectionKey in sectionKeys {
            if let items = sections[sectionKey] {
                snapshot.appendSections([sectionKey])
                snapshot.appendItems(items, toSection: sectionKey)
            }
        }
        dataSource?.apply(snapshot, animatingDifferences: true, completion: {
            print("Apply snapshot completed!")
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
        title = "Dog Breeds"
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
            cell.icon = indexPath.row % 2 == 0 ? UIImage(systemName: "pawprint") : UIImage(systemName: "pawprint.fill")
            if item.isSelected {
                self?.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func createLevelTwoCellRegistration() -> UICollectionView.CellRegistration<LevelTwoCollectionViewCell, Breed> {
        UICollectionView.CellRegistration<LevelTwoCollectionViewCell, Breed> { [weak self] (cell, indexPath, item) in
            cell.item = item.breed
            Task {
                guard let self else { return }
                if let url = try await self.viewModel.randomImageURL(for: item, service: self.service) {
                    cell.image = try await ImageManager.shared.getImage(for: url)
                } else {
                    cell.image = UIImage(systemName: "pawprint")
                }
            }
            cell.position = indexPath.item
            if item.isSelected {
                self?.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func createCardCellRegistration() -> UICollectionView.CellRegistration<CardCollectionViewCell, Image> {
        UICollectionView.CellRegistration<CardCollectionViewCell, Image> { (cell, indexPath, item) in
            Task { @MainActor in
                cell.image = try await ImageManager.shared.getImage(for: item.url)
            }
        }
    }
    
    private func headerRegistration() -> UICollectionView.SupplementaryRegistration<SectionTitleView> {
        UICollectionView.SupplementaryRegistration
        <SectionTitleView>(elementKind: MultiFilterViewController.sectionHeaderElementKind) { [weak self] (supplementaryView, string, indexPath) in
            guard let section = self?.dataSource?.sectionIdentifier(for: indexPath.section) else { return }
            supplementaryView.label.text = section.id
            supplementaryView.backgroundColor = .white
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Content.Section, Content.Item> {
        let levelOneRegistration = createLevelOneCellRegistration()
        let levelTwoRegistration = createLevelTwoCellRegistration()
        let cardRegistration = createCardCellRegistration()
        let headerRegistration = headerRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<Content.Section, Content.Item>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell? in
                item.dequeueReusableCell(collectionView: collectionView, levelOneRegistration: levelOneRegistration, levelTwoRegistration: levelTwoRegistration, cardRegistration: cardRegistration, indexPath: indexPath)
            })
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
        return dataSource
    }

    func buildCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] section, _ in
            guard let sectionId = self?.dataSource?.sectionIdentifier(for: section) else { return nil }
            return sectionId.type.buildLayout()
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension MultiFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .category(let item):
            return item.name != viewModel.selectedCategory
        case .breed:
            return true
        case .image:
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
}
