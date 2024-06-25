//  LevelTwoCollectionViewCell.swift
//
//  Copyright (c) 2024 Andrea Scuderi
//

import Foundation
import UIKit

final class LevelTwoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: LevelTwoCollectionViewCell.self)
    
    enum Constants {
        static let imageSize = CGSize(width: 74, height: 56)
        static let imageWidthHeightRatio: CGFloat = 8.0 / 7.0
        static let space: CGFloat = 4
        static let selectedSize: CGFloat = 32
        static let checkboxSize: CGFloat = 32
    }
    
    private (set) var id: String = ""
    
    private let label: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textAlignment = .center
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let container: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.alignment = .top
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkboxImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "checkmark.circle")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.selectedSize / 2.0
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var borderColor: UIColor = .orange
    
    var position: Int? {
        didSet {
            borderColor = (position ?? 0).borderColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                accessibilityTraits.insert(.selected)
            } else {
                accessibilityTraits.remove(.selected)
            }
            selectedView.isHidden = !isSelected
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
    
    private lazy var selectedViewHeightConstraint = selectedView.heightAnchor.constraint(equalToConstant: Constants.selectedSize)
    
    var item: String? {
        didSet {
            isAccessibilityElement = true
            accessibilityTraits.insert(.button)
            if isSelected { accessibilityTraits.insert(.selected) }
            label.text = item
            styleView()
        }
    }

    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    private func setupView() {
        container.alignment = .center
        imageContainer.addSubview(imageView)
        container.addArrangedSubview(imageContainer)
        container.addArrangedSubview(spacer)
        container.addArrangedSubview(label)
        container.addArrangedSubview(bottomSpacer)
        contentView.addSubview(container)
        selectedView.addSubview(checkboxImage)
        contentView.addSubview(selectedView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            
            imageContainer.heightAnchor.constraint(equalToConstant: Constants.imageSize.height),
            imageContainer.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            
            spacer.heightAnchor.constraint(equalToConstant: Constants.space),
            
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            checkboxImage.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            checkboxImage.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            checkboxImage.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor),
            checkboxImage.centerYAnchor.constraint(equalTo: selectedView.centerYAnchor),
            
            selectedView.widthAnchor.constraint(equalTo: selectedView.heightAnchor, multiplier: 1),
            selectedViewHeightConstraint,
            
            selectedView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 2),
            selectedView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessibilityTraits = .none
        accessibilityLabel = nil
        accessibilityHint = nil
        isSelected = false
        label.text = nil
        image = nil
        selectedView.isHidden = true
        styleView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        styleView()
    }
    
    func contentColor() -> UIColor {
        if isSelected {
            return .black
        }
        return .gray
    }
    
    func labelStyle() -> UIFont {
        if isSelected {
            return .boldSystemFont(ofSize: 12)
        }
        return .systemFont(ofSize: 12)
    }
    
    private func styleView() {
        label.textColor = contentColor()
        label.font = labelStyle()
        selectedView.backgroundColor = .white
        checkboxImage.tintColor = borderColor
        imageView.layer.borderColor = borderColor.cgColor
    }
}

private extension Int {
    var borderColor: UIColor {
        let backdrop = self % 6 + 1
        switch backdrop {
        case 1:
            return .red
        case 2:
            return .orange
        case 3:
            return .tintColor
        case 4:
            return .blue
        case 5:
            return .magenta
        case 6:
            return .green
        default:
            return .brown
        }
    }
}
