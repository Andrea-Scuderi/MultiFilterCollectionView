//
//  ViewController.swift
//  MultiFilterCollectionView
//
//  Created by Andrea Scuderi on 07/04/2024.
//

import UIKit

class SectionViewModel {
    var sections: [Content.Section: [Content.Item]] = [:]
    var selectedLevel1: String?
    var selectedLevel2: [String] = []
    
    func fetchData(service: Service, selectedBreed: String? = nil, selectedSubBreeds: [String]? = nil) async throws {
        let allBreeds = try await service.fetchAllBreeds()
        let breeds = allBreeds.message.keys.sorted().map { Content.Item.breed($0) }
        sections[.breed] = breeds
        selectedLevel1 = selectedBreed ?? breeds.first?.breed
        if let selected = selectedBreed,
           let subBreeds = allBreeds.message[selected] {
            sections[.subBreed] = subBreeds.map { Content.Item.subBreed($0) }
            if let subBreed = sections[.subBreed]?.first?.subBreed {
                selectedLevel2 = selectedSubBreeds ?? [subBreed]
            }
        }
        if !selectedLevel2.isEmpty {
            var images: [String] = []
            for selected in selectedLevel2 {
                let breedImages = try await service.fetchBreedList(breed: selected)
                images.append(contentsOf: breedImages.message)
            }
            sections[.images] = images.map { Content.Item.image($0) }
        } else if let selectedLevel1 {
            var images: [String] = []
            let breedImages = try await service.fetchBreedList(breed: selectedLevel1)
            images.append(contentsOf: breedImages.message)
            sections[.images] = images.map { Content.Item.image($0) }
        } else {
            print("No Content")
        }
        print(sections)
    }
}

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var collectionViewLayout: UICollectionViewCompositionalLayout!
    let service = Service()
    let viewModel = SectionViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            do {
                try await viewModel.fetchData(service: service)
            } catch {
                print(error)
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupConstraints()
    }
    
    func setupView() {
        collectionViewLayout = buildCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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

    func buildCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { section, _ in
            guard let sectionId = Content.Section(rawValue: section) else { return nil }
            return sectionId.buildLayout()
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

