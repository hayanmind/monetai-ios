//
//  ViewController.swift
//  SimpleApp
//
//  Created by Daehoon Kim on 7/23/25.
//

import UIKit
import MonetaiSDK

class ViewController: UIViewController {

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let predictButton = UIButton(type: .system)
    private let logEventButton = UIButton(type: .system)
    private let discountStatusLabel = UILabel()
    private let resultLabel = UILabel()
    private var discountBannerView: DiscountBannerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMonetaiSDK()
        setupNotifications()
        
        // Log app launch event
        Task {
            await MonetaiSDK.shared.logEvent(eventName: "app_in")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Title Label
        titleLabel.text = "MonetaiSDK Demo"
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Status Label
        statusLabel.text = "SDK Status: Initializing..."
        statusLabel.textColor = UIColor.secondaryLabel
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Predict Button
        predictButton.setTitle("Predict Purchase", for: .normal)
        predictButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        predictButton.backgroundColor = UIColor.systemBlue
        predictButton.setTitleColor(UIColor.white, for: .normal)
        predictButton.layer.cornerRadius = 10
        predictButton.translatesAutoresizingMaskIntoConstraints = false
        predictButton.addTarget(self, action: #selector(predictButtonTapped), for: .touchUpInside)
        view.addSubview(predictButton)
        
        // Log Event Button
        logEventButton.setTitle("Log Event", for: .normal)
        logEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        logEventButton.backgroundColor = UIColor.systemGreen
        logEventButton.setTitleColor(UIColor.white, for: .normal)
        logEventButton.layer.cornerRadius = 8
        logEventButton.translatesAutoresizingMaskIntoConstraints = false
        logEventButton.addTarget(self, action: #selector(logEventButtonTapped), for: .touchUpInside)
        view.addSubview(logEventButton)

		// Removed manual Paywall controls per requirement
        
        // Discount Status Label
        discountStatusLabel.text = "Discount: None"
        discountStatusLabel.textColor = UIColor.secondaryLabel
        discountStatusLabel.font = UIFont.systemFont(ofSize: 14)
        discountStatusLabel.textAlignment = .center
        discountStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(discountStatusLabel)
        
        // Result Label
        resultLabel.text = "Tap buttons to test SDK functionality"
        resultLabel.textColor = UIColor.secondaryLabel
        resultLabel.font = UIFont.systemFont(ofSize: 14)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            // Status Label
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            // Predict Button
            predictButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            predictButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            predictButton.widthAnchor.constraint(equalToConstant: 200),
            predictButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Log Event Button
            logEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logEventButton.topAnchor.constraint(equalTo: predictButton.bottomAnchor, constant: 20),
            logEventButton.widthAnchor.constraint(equalToConstant: 150),
            logEventButton.heightAnchor.constraint(equalToConstant: 40),

			// Manual Paywall buttons removed
            
			// Discount Status Label
			discountStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			discountStatusLabel.topAnchor.constraint(equalTo: logEventButton.bottomAnchor, constant: 30),
            
            // Result Label
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: discountStatusLabel.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - MonetaiSDK Setup
    private func setupMonetaiSDK() {
        // Set up discount info change callback
        MonetaiSDK.shared.onDiscountInfoChange = { [weak self] discountInfo in
            DispatchQueue.main.async {
                self?.handleDiscountInfoChange(discountInfo)
            }
        }
        
        // Start checking SDK status periodically
        startSDKStatusCheck()

		// Configure paywall
		configurePaywall()
    }

	private func configurePaywall() {
		let features = [
			Feature(title: "Unlimited Access", description: "Use all premium features without limits"),
			Feature(title: "Advanced Analytics", description: "AI-powered insights", isPremiumOnly: true)
		]
		let config = PaywallConfig(
			discountPercent: 30,
			regularPrice: "$99.99",
			discountedPrice: "$69.99",
			locale: "en",
			features: features,
			style: .highlightBenefits
		)

		config.onPurchase = { [weak self] close in
			print("[SimpleApp] onPurchase called")
			self?.resultLabel.text = "🛒 Purchase flow started"
			self?.resultLabel.textColor = UIColor.systemBlue
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				print("[SimpleApp] calling close()")
				close()
			}
		}
		config.onTermsOfService = { [weak self] in
			print("[SimpleApp] onTermsOfService called")
			self?.presentAlert(title: "Terms of Service", message: "Open Terms of Service URL")
		}
		config.onPrivacyPolicy = { [weak self] in
			print("[SimpleApp] onPrivacyPolicy called")
			self?.presentAlert(title: "Privacy Policy", message: "Open Privacy Policy URL")
		}

		MonetaiSDK.shared.configurePaywall(config)
	}
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sdkInitialized),
            name: .monetaiSDKInitialized,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sdkInitializationFailed),
            name: .monetaiSDKInitializationFailed,
            object: nil
        )
    }
    
    @objc private func sdkInitialized() {
        DispatchQueue.main.async {
            self.updateSDKStatus()
            self.resultLabel.text = "✅ SDK initialized successfully!"
            self.resultLabel.textColor = UIColor.systemGreen
        }
    }
    
    @objc private func sdkInitializationFailed(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateSDKStatus()
            if let error = notification.object as? Error {
                self.resultLabel.text = "❌ SDK initialization failed: \(error.localizedDescription)"
                self.resultLabel.textColor = UIColor.systemRed
            }
        }
    }
    
    private func startSDKStatusCheck() {
        // Check status immediately
        updateSDKStatus()
        
        // Check status every 1 second until initialized
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let isInitialized = MonetaiSDK.shared.getInitialized()
            self.updateSDKStatus()
            
            // Stop timer when SDK is initialized
            if isInitialized {
                timer.invalidate()
            }
        }
    }
    
    private func updateSDKStatus() {
        let isInitialized = MonetaiSDK.shared.getInitialized()
        statusLabel.text = isInitialized ? "SDK Status: ✅ Ready" : "SDK Status: ⏳ Initializing..."
        statusLabel.textColor = isInitialized ? UIColor.systemGreen : UIColor.systemOrange
        
        // Enable/disable buttons based on initialization status
        predictButton.isEnabled = isInitialized
        logEventButton.isEnabled = isInitialized
        
        if isInitialized {
            predictButton.alpha = 1.0
            logEventButton.alpha = 1.0
        } else {
            predictButton.alpha = 0.5
            logEventButton.alpha = 0.5
        }
    }
    
	private func handleDiscountInfoChange(_ discountInfo: AppUserDiscount?) {
		if let discount = discountInfo {
			let now = Date()
			let endTime = discount.endedAt
			if now < endTime {
				discountStatusLabel.text = "Discount: ✅ Active (Expires: \(endTime.formatted(date: .abbreviated, time: .shortened)))"
				discountStatusLabel.textColor = UIColor.systemGreen
			} else {
				discountStatusLabel.text = "Discount: ❌ Expired"
				discountStatusLabel.textColor = UIColor.systemRed
			}
		} else {
			discountStatusLabel.text = "Discount: None"
			discountStatusLabel.textColor = UIColor.secondaryLabel
		}
	}
    
    // MARK: - Button Actions
    @objc private func predictButtonTapped() {
        Task {
            do {
                let result = try await MonetaiSDK.shared.predict()

                print("Prediction result:", result.prediction?.stringValue ?? "None")
                print("Test group:", result.testGroup?.stringValue ?? "None")

                if result.prediction == .nonPurchaser {
                    // When predicted as non-purchaser, offer discount
                    print("Predicted as non-purchaser - discount can be applied")
                } else if result.prediction == .purchaser {
                    // When predicted as purchaser
                    print("Predicted as purchaser - discount not needed")
                }
                
                await MainActor.run {
                    resultLabel.text = "✅ Prediction completed - check console for details"
                    resultLabel.textColor = UIColor.systemGreen
						
						// Show alert with prediction result (present from top-most VC safely)
						self.presentAlert(
							title: "Purchase Prediction",
							message: "Prediction: \(result.prediction?.stringValue ?? "None")\nTest Group: \(result.testGroup?.stringValue ?? "None")"
						)
                }
                
            } catch {
                await MainActor.run {
                    resultLabel.text = "❌ Prediction failed: \(error.localizedDescription)"
                    resultLabel.textColor = UIColor.systemRed
                }
                print("Prediction failed:", error)
            }
        }
    }
    
    @objc private func logEventButtonTapped() {
        Task {
            // Log a sample event with parameters
            await MonetaiSDK.shared.logEvent(
                eventName: "button_click",
                params: ["button": "test_button", "screen": "main"]
            )
            
            await MainActor.run {
                resultLabel.text = "✅ Event logged: button_click\nParameters: button=test_button, screen=main"
                resultLabel.textColor = UIColor.systemGreen
            }
            
            print("Event logged: button_click")
        }
    }

	private func presentAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		DispatchQueue.main.async {
			let presenter = self.presentedViewController ?? self.topMostViewController() ?? self
			presenter.present(alert, animated: true)
		}
	}

	private func topMostViewController() -> UIViewController? {
		if let windowScene = UIApplication.shared.connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.first(where: { $0.activationState == .foregroundActive }) {
			if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
				var topVC = keyWindow.rootViewController
				while let presented = topVC?.presentedViewController { topVC = presented }
				return topVC
			}
		}
		if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first {
			var topVC = window.rootViewController
			while let presented = topVC?.presentedViewController { topVC = presented }
			return topVC
		}
		return nil
	}
}

