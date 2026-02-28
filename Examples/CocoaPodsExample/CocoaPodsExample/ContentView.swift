//
//  ContentView.swift
//  Example
//
//  Created by Daehoon Kim on 7/21/25.
//

import SwiftUI
import MonetaiSDK
import RevenueCat

struct ContentView: View {
    @StateObject private var monetaiSDK = MonetaiSDK.shared
    @State private var isInitialized = false
    @State private var isLoading = false
    @State private var packages: [Package] = []
    @State private var customerInfo: CustomerInfo?
    @State private var offer: Offer?
    @State private var initializationError: String = ""

    private let sdkKey = Constants.sdkKey
    private let userId = Constants.userId
    private let useStoreKit2 = Constants.useStoreKit2
    private let revenueCatAPIKey = Constants.revenueCatAPIKey
    private let promotionId = Constants.promotionId
    private let defaultProductId = Constants.defaultProductId

    // MARK: - Computed Properties

    private var offerSkuSet: Set<String> {
        guard let offer = offer else { return [] }
        return Set(offer.products.map { $0.sku })
    }

    private var basePackage: Package? {
        packages.first { $0.storeProduct.productIdentifier == defaultProductId }
    }

    private var displayedPackages: [Package] {
        guard let basePackage = basePackage else { return [] }
        guard offer != nil else { return [basePackage] }
        let offerPackages = packages.filter {
            offerSkuSet.contains($0.storeProduct.productIdentifier) &&
            $0.storeProduct.productIdentifier != defaultProductId
        }
        return [basePackage] + offerPackages
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                storeKitInfoSection
                offerSection

                ScrollView {
                    VStack(spacing: 0) {
                        productsSection
                        customerInfoSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Monetai Example")
            .onAppear {
                initializeSDKs()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("Monetai Example App")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 8) {
                Text("Status:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(isInitialized ? "Connected" : "Connecting...")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isInitialized ? Color.blue.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .bottom
        )
    }

    // MARK: - StoreKit Info Section
    private var storeKitInfoSection: some View {
        HStack {
            Text("StoreKit Version:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("StoreKit \(useStoreKit2 ? "2" : "1")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .bottom
        )
    }

    // MARK: - Offer Section
    private var offerSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task { await fetchOffer() }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    }
                    Text("Get Offer")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isLoading || !isInitialized)

            if let offer = offer {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Agent: \(offer.agentName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.18, green: 0.49, blue: 0.2))
                    ForEach(offer.products, id: \.sku) { product in
                        Text("\(product.name): \(Int(product.discountRate * 100))% off")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.22, green: 0.56, blue: 0.24))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(red: 0.91, green: 0.96, blue: 0.91))
                .cornerRadius(8)
            }

            // Subscriber status
            HStack {
                Text("Subscriber Status:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let customerInfo = customerInfo, !customerInfo.entitlements.active.isEmpty {
                    Text("Subscribed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text("Not Subscribed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if !initializationError.isEmpty {
                Text(initializationError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .bottom
        )
    }

    // MARK: - Products Section
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Products")
                .font(.headline)
                .foregroundColor(.primary)

            if displayedPackages.isEmpty {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading products...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 1)
            } else {
                ForEach(displayedPackages, id: \.identifier) { package in
                    let offerProduct = offer?.products.first { $0.sku == package.storeProduct.productIdentifier }

                    ProductRow(
                        package: package,
                        offerProduct: offerProduct,
                        basePackage: basePackage
                    ) {
                        await purchasePackage(package)
                    }
                }
            }
        }
    }

    // MARK: - Customer Info Section
    private var customerInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customer Information")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 20)

            if let customerInfo = customerInfo,
               !customerInfo.entitlements.active.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Entitlements")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ForEach(Array(customerInfo.entitlements.active.keys), id: \.self) { key in
                        if let entitlement = customerInfo.entitlements.active[key] {
                            EntitlementRow(key: key, entitlement: entitlement)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text("No active subscriptions found")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Text("Purchase a product to see your subscription details here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 1)
            }
        }
    }

    // MARK: - Helper Methods
    private func initializeSDKs() {
        Task {
            // Test pending events before SDK initialization
            await monetaiSDK.logEvent(eventName: "app_launched", params: [
                "launch_time": Date().timeIntervalSince1970,
                "version": "1.0.0",
                "device": "iOS"
            ])

            await monetaiSDK.logEvent(eventName: "app_background_to_foreground", params: [
                "session_start": true,
                "user_type": "example_user"
            ])

            do {
                // Initialize RevenueCat
                Purchases.logLevel = .verbose
                Purchases.configure(with: .builder(withAPIKey: revenueCatAPIKey)
                    .with(appUserID: userId)
                    .with(storeKitVersion: useStoreKit2 ? .storeKit2 : .storeKit1)
                    .build()
                )

                // Initialize MonetaiSDK
                _ = try await monetaiSDK.initialize(
                    sdkKey: sdkKey,
                    userId: userId,
                    useStoreKit2: useStoreKit2
                )

                await MainActor.run {
                    isInitialized = true
                    initializationError = ""
                }

                await monetaiSDK.logEvent(eventName: "monetai_initialized")
                await loadProducts()
                await loadCustomerInfo()

            } catch {
                await MainActor.run {
                    isInitialized = false
                    initializationError = "Initialization failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadProducts() async {
        do {
            let offerings = try await Purchases.shared.offerings()

            await MainActor.run {
                if let currentOffering = offerings.current {
                    self.packages = currentOffering.availablePackages
                } else {
                    self.packages = offerings.all.values.flatMap { $0.availablePackages }
                }
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    private func loadCustomerInfo() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.customerInfo = customerInfo
            }
        } catch {
            print("Failed to load customer info: \(error)")
        }
    }

    private func purchasePackage(_ package: Package) async {
        do {
            let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)

            if userCancelled { return }

            await MainActor.run {
                self.customerInfo = customerInfo
            }

            await monetaiSDK.logEvent(eventName: "purchase_completed", params: [
                "product_id": package.storeProduct.productIdentifier,
                "price": package.storeProduct.price,
                "currency": package.storeProduct.priceFormatter?.currencyCode ?? "USD"
            ])
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    private func fetchOffer() async {
        await MainActor.run { isLoading = true }

        do {
            let result = try await monetaiSDK.getOffer(promotionId: promotionId)

            await MainActor.run {
                isLoading = false
                offer = result
            }

            // Log viewProductItem for offer products
            if let offer = result, let basePackage = basePackage {
                for offerProduct in offer.products {
                    let pkg = packages.first { $0.storeProduct.productIdentifier == offerProduct.sku }
                    guard let pkg = pkg else { continue }

                    await monetaiSDK.logViewProductItem(ViewProductItemParams(
                        productId: pkg.storeProduct.productIdentifier,
                        price: NSDecimalNumber(decimal: pkg.storeProduct.price).doubleValue,
                        regularPrice: NSDecimalNumber(decimal: basePackage.storeProduct.price).doubleValue,
                        currencyCode: pkg.storeProduct.currencyCode ?? "USD",
                        promotionId: promotionId,
                        month: pkg.storeProduct.subscriptionPeriod?.unit == .year ? 12 : nil
                    ))
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                initializationError = "Get offer failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Supporting Views
struct ProductRow: View {
    let package: Package
    let offerProduct: OfferProduct?
    let basePackage: Package?
    let onPurchase: () async -> Void

    private var isOfferProduct: Bool { offerProduct != nil }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(package.storeProduct.localizedTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                if isOfferProduct, let basePackage = basePackage, let offerProduct = offerProduct {
                    HStack(spacing: 8) {
                        Text(basePackage.localizedPriceString)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough()

                        Text(package.localizedPriceString)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)

                        Text("-\(Int(offerProduct.discountRate * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                    }
                } else {
                    Text(package.localizedPriceString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button("Buy") {
                Task { await onPurchase() }
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
}

struct EntitlementRow: View {
    let key: String
    let entitlement: EntitlementInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(key)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)

                Spacer()
            }

            HStack {
                Text("Expiration:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(entitlement.expirationDate?.formatted() ?? "Lifetime")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
