//  SectionViewModel.swift

import Foundation

class SectionViewModel {
    private(set) var selectedCategory: String = "a-c"
    private(set) var selectedBreeds: [String] = []
    
    // Breed List
    private var breedList: [Breed] = []
    // Category cache
    private var categoryDictionary: [String: [Breed]] = [:]
    // Breed cache
    private var breedDictionary: [String: [URL]] = [:]
    
    private var categoryList: [Category] = {
        let ranges = [
            "a"..."c",
            "d"..."f",
            "g"..."i",
            "j"..."k",
            "l"..."n",
            "o"..."r",
            "s"..."z"
        ]
        return ranges.map {
            let name = String("\($0.lowerBound)-\($0.upperBound)")
            return Category(name: name, range: $0, isSelected: false)
        }
    }()

    func selectCategory(category: String) {
        selectedCategory = category
        if let firstBreedInCategory = categoryDictionary[category]?.first?.breed {
            selectedBreeds = [firstBreedInCategory]
        }
    }
    
    func selectBreed(breed: String) {
        if selectedBreeds.contains(breed) {
            selectedBreeds.removeAll { $0 == breed }
        } else {
            selectedBreeds.append(breed)
        }
    }
    
    private func loadAllBreedsIfNeeded(service: Service) async throws -> [Breed] {
        var allBreeds: [Breed] = []
        let allBreedsDTO = try await service.fetchAllBreeds()
        for (key, value) in allBreedsDTO.message {
            if value.isEmpty {
                let newBreed = Breed(breed: key, apiKey: key, isSelected: false)
                allBreeds.append(newBreed)
            } else {
                let newBreeds = value.compactMap { Breed(breed: "\(key) \($0)", apiKey: "\(key)/\($0)", isSelected: false) }
                allBreeds.append(contentsOf: newBreeds)
            }
        }
        return allBreeds.sorted(by: { $0.breed < $1.breed })
    }
        
    private func splitBreedsInCategories(breeds: [Breed]) -> [String: [Breed]] {
        var categories: [String: [Breed]] = [:]
        for breed in breeds {
            if let first = breed.breed.first,
               let currentIndex = categoryList.firstIndex(where: { $0.range.contains(String(first)) }) {
                if categories[categoryList[currentIndex].name] == nil {
                    categories[categoryList[currentIndex].name] = [breed]
                } else {
                    categories[categoryList[currentIndex].name]?.append(breed)
                }
            }
        }
        return categories
    }
    
    func fetchData(service: Service) async throws -> [Content.Section: [Content.Item]] {
        if breedList.isEmpty {
            breedList = try await loadAllBreedsIfNeeded(service: service)
        }
        if categoryDictionary.isEmpty {
            categoryDictionary = splitBreedsInCategories(breeds: breedList)
            selectCategory(category: "a-c")
        }
        
        let categories: [Content.Item] = categoryList.compactMap({
            if selectedCategory == $0.name {
                Content.Item.category($0.selected())
            } else {
                Content.Item.category($0)
            }
        })
        
        let breeds: [Content.Item]? = categoryDictionary[selectedCategory]?.compactMap({
            if selectedBreeds.contains([$0.breed]) {
                Content.Item.breed($0.selected())
            } else {
                Content.Item.breed($0)
            }
        })
        
        let selectedBreedList: [Breed] = selectedBreeds.compactMap { selected in
            breedList.first(where: { selected == $0.breed })
        }
        
        var images: [Content.Item] = []
        for selected in selectedBreedList {
            if breedDictionary[selected.breed] == nil {
                let imageList = try await service.fetchBreedList(breed: selected.apiKey).message
                breedDictionary[selected.breed] = imageList.compactMap({ URL(string: $0) })
            }
            if let items = breedDictionary[selected.breed] {
                images.append(contentsOf: items.compactMap( { Content.Item.image(Image(url: $0)) }))
            }
        }
        let sections: [Content.Section: [Content.Item]] = [
            .category: categories,
            .breed: breeds ?? [],
            .images: images
        ]
        return sections
    }
}
