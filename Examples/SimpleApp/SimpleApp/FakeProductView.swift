//
//  FakeProductView.swift
//  SimpleApp
//
//  Created by Daehoon Kim on 7/23/25.
//

import UIKit

final class FakeProductView: UIView {
    
    // Callback triggered when view is attached to a window
    var onAppear: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let regularPriceLabel = UILabel()
    private let discountPriceLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            onAppear?()
        }
    }
    
    func configure(title: String, regularPrice: String, discountPrice: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        
        let attributed = NSMutableAttributedString(string: regularPrice)
        attributed.addAttribute(.strikethroughStyle,
                                value: NSUnderlineStyle.single.rawValue,
                                range: NSRange(location: 0, length: (regularPrice as NSString).length))
        regularPriceLabel.attributedText = attributed
        
        discountPriceLabel.text = discountPrice
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.secondarySystemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        regularPriceLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        regularPriceLabel.textColor = UIColor.secondaryLabel
        regularPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        discountPriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        discountPriceLabel.textColor = UIColor.systemBlue
        discountPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(regularPriceLabel)
        addSubview(discountPriceLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            regularPriceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            regularPriceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            regularPriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            discountPriceLabel.topAnchor.constraint(equalTo: regularPriceLabel.bottomAnchor, constant: 4),
            discountPriceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            discountPriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: discountPriceLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        // Default content
        configure(
            title: "Fake Monthly Plan",
            regularPrice: "$14.99",
            discountPrice: "$9.99 / month",
            description: "Demo-only fake product to showcase logViewProductItem."
        )
    }
}

