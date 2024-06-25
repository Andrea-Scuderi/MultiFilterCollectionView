//  LevelOneCollectionViewCell.swift
//
//  Copyright (c) 2024 Andrea Scuderi
//

import Foundation
import UIKit

class LevelOneCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: LevelOneCollectionViewCell.self)
    
    enum Constants {
        static let imageSize = CGSize(width: 16, height: 16)
    }
    
    private (set) var id: String = ""
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 16.0
        return view
    }()
    
    private var chipContainer: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected { accessibilityTraits.insert(.selected)
            } else {
                accessibilityTraits.remove(.selected)
            }
            styleView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        styleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var position: Int?
    
    var item: Category? {
        didSet {
            isAccessibilityElement = true
            accessibilityTraits.insert(.button)
            if isSelected { accessibilityTraits.insert(.selected) }
            label.text = item?.name
            styleView()
        }
    }

    var icon: UIImage? {
        get {
            iconView.image
        }
        set {
            iconView.image = newValue?.withRenderingMode(.alwaysTemplate)
        }
    }

    private func setupView() {
        chipContainer.addArrangedSubview(iconView)
        chipContainer.addArrangedSubview(label)
        container.addSubview(chipContainer)
        contentView.addSubview(container)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            chipContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            chipContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            chipContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            chipContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessibilityTraits = .none
        accessibilityLabel = nil
        accessibilityHint = nil
        isSelected = false
        label.text = nil
        styleView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        styleView()
    }
    
    func contentColor() -> UIColor {
        if isSelected {
            return .white
        }
        return .black
    }
    
    func backgroundColor() -> UIColor {
        if isSelected {
            return .black
        }
        return .lightGray
    }
    
    private func styleView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        container.backgroundColor = backgroundColor()
        label.textColor = contentColor()
        iconView.tintColor = contentColor()
    }
}
