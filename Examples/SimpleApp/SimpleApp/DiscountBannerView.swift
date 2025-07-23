//
//  DiscountBannerView.swift
//  SimpleApp
//
//  Created by Daehoon Kim on 7/23/25.
//

import UIKit
import MonetaiSDK

class DiscountBannerView: UIView {
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let timeRemainingLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var discount: AppUserDiscount?
    private var timer: Timer?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // Container View
        containerView.backgroundColor = UIColor.systemGreen
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title Label
        titleLabel.text = "🎉 Special Discount!"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.text = "Limited time offer available for you!"
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Time Remaining Label
        timeRemainingLabel.textColor = UIColor.white
        timeRemainingLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeRemainingLabel.textAlignment = .center
        timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timeRemainingLabel)
        
        // Close Button
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Close Button
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Time Remaining Label
            timeRemainingLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            timeRemainingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            timeRemainingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            timeRemainingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Public Methods
    func showDiscount(_ discount: AppUserDiscount) {
        self.discount = discount
        updateTimeRemaining()
        startTimer()
        
        // Animate in
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func hideDiscount() {
        stopTimer()
        
        // Animate out
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 50)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Private Methods
    private func updateTimeRemaining() {
        guard let discount = discount else { return }
        
        let now = Date()
        let endTime = discount.endedAt
        let timeRemaining = endTime.timeIntervalSince(now)
        
        if timeRemaining > 0 {
            let hours = Int(timeRemaining) / 3600
            let minutes = Int(timeRemaining) % 3600 / 60
            
            if hours > 0 {
                timeRemainingLabel.text = "⏰ \(hours)h \(minutes)m remaining"
            } else {
                timeRemainingLabel.text = "⏰ \(minutes)m remaining"
            }
        } else {
            timeRemainingLabel.text = "⏰ Expired"
            hideDiscount()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        hideDiscount()
    }
} 