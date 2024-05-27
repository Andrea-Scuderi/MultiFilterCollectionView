//  CardCollectionViewCell.swift

import Foundation
import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: CardCollectionViewCell.self)
    
    enum Constants {
        static let imageSize = CGSize(width: 16, height: 16)
    }
    
    private (set) var id: String = ""
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        styleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessibilityTraits = .none
        accessibilityLabel = nil
        accessibilityHint = nil
        isSelected = false
        image = nil
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
    }
}
