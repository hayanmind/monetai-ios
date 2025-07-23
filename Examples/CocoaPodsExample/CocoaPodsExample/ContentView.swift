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
    @State private var predictionResult: String = ""
    @State private var isLoading = false
    @State private var packages: [Package] = []
    @State private var customerInfo: CustomerInfo?
    @State private var initializationResult: String = ""
    @State private var initializationError: String = ""
    @State private var discountStatus: String = ""
    
    private let sdkKey = Constants.sdkKey
    private let userId = Constants.userId
    private let useStoreKit2 = Constants.useStoreKit2
    
    // RevenueCat API Keys
    private let revenueCatAPIKey = Constants.revenueCatAPIKey
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // StoreKit Version Info
                    storeKitInfoSection
                    
                    // Available Products
                    productsSection
                    
                    // Customer Information
                    customerInfoSection
                    
                    // Discount Information
                    discountInfoSection
                    
                    // MonetaiSDK Actions
                    monetaiActionsSection
                }
                .padding()
            }
            .navigationTitle("Monetai Example")
            .onAppear {
                initializeSDKs()
                setupDiscountInfoListener()
            }
        }
    }
    
    private func setupDiscountInfoListener() {
        // Set up automatic discount information update callback for Monetai SDK
        monetaiSDK.onDiscountInfoChange = { discount in
            Task { @MainActor in
                if let discount = discount {
                    let isActive = discount.endedAt > Date()
                    discountStatus = isActive ?
                        "✅ Active until \(discount.endedAt.formatted(date: .abbreviated, time: .shortened))" :
                        "❌ Expired on \(discount.endedAt.formatted(date: .abbreviated, time: .shortened))"
                } else {
                    discountStatus = "No discount available"
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Monetai Example App")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack {
                Text("Status:")
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(isInitialized ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(isInitialized ? "Connected" : "Connecting...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Display initialization result
            if !initializationResult.isEmpty {
                Text(initializationResult)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.leading)
            }
            
            // Display initialization error
            if !initializationError.isEmpty {
                Text(initializationError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - StoreKit Info Section
    private var storeKitInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RevenueCat + StoreKit")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("StoreKit \(useStoreKit2 ? "2" : "1") via RevenueCat")
                .font(.subheadline)
                .foregroundColor(.blue)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Products Section
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Products")
                .font(.headline)
                .foregroundColor(.primary)
            
            if packages.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading products...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            } else {
                ForEach(packages, id: \.identifier) { package in
                    ProductRow(package: package) {
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
                    Image(systemName: "creditcard")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
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
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Discount Information Section
    private var discountInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💰 Discount Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let discount = monetaiSDK.currentDiscount {
                let isActive = discount.endedAt > Date()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("🎯 Status:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(isActive ? "🟢 Active" : "🔴 Expired")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isActive ? .green : .red)
                    }
                    
                    HStack {
                        Text("👤 User ID:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(discount.appUserId)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("⏰ Started:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(discount.startedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("⏳ Expires:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(discount.endedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(isActive ? .orange : .red)
                    }
                    
                    if isActive {
                        let timeRemaining = discount.endedAt.timeIntervalSince(Date())
                        let totalSeconds = Int(timeRemaining)
                        let hours = totalSeconds / 3600
                        let minutes = (totalSeconds % 3600) / 60
                        
                        HStack {
                            Text("⏱️ Time Left:")
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(hours)h \(minutes)m")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isActive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "tag.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No active discount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(discountStatus.isEmpty ? "Use 'Predict User' to check for available discounts" : discountStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - MonetaiSDK Actions Section
    private var monetaiActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monetai SDK Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Test Events Section
            VStack(spacing: 8) {
                Text("Test Events")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Button("App Opened") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "app_opened")
                                print("✅ [TEST] app_opened event log request")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                        
                        Button("Product Viewed") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "product_viewed")
                                print("✅ [TEST] product_viewed event log request")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 8) {
                        Button("Add to Cart") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "add_to_cart", params: ["value": 9.99])
                                print("✅ [TEST] add_to_cart event log request (value: 9.99)")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                        
                        Button("Purchase Started") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "purchase_started", params: ["value": 19.99])
                                print("✅ [TEST] purchase_started event log request (value: 19.99)")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    
                    // New params-based events
                    Text("New Params Events")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    
                    HStack(spacing: 8) {
                        Button("Screen View") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "screen_view", params: [
                                    "screen_name": "home",
                                    "previous_screen": "onboarding"
                                ])
                                print("✅ [TEST] screen_view event log request (params)")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                        
                        Button("Button Click") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "button_click", params: [
                                    "button_name": "upgrade",
                                    "location": "header",
                                    "experiment_id": "exp_123"
                                ])
                                print("✅ [TEST] button_click event log request (params)")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 8) {
                        Button("Feature Used") {
                            Task {
                                await monetaiSDK.logEvent(eventName: "feature_used", params: [
                                    "feature_name": "premium_filter",
                                    "usage_count": 5,
                                    "is_premium_user": false
                                ])
                                print("✅ [TEST] feature_used event log request (params)")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                        
                        Button("LogEventOptions") {
                            Task {
                                let options = LogEventOptions(
                                    eventName: "custom_event",
                                    params: [
                                        "category": "test",
                                        "timestamp": Date().timeIntervalSince1970,
                                        "user_level": 10
                                    ]
                                )
                                await monetaiSDK.logEvent(options)
                                print("✅ [TEST] Event log request using LogEventOptions")
                            }
                        }
                        .buttonStyle(TestButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Prediction Section
            Button(action: {
                Task {
                    await predictUser()
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    }
                    
                    Text("Predict User")
                        .fontWeight(.medium)
                }
            }
            .buttonStyle(ActionButtonStyle())
            .disabled(isLoading || !isInitialized)
            
            if !predictionResult.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prediction Result:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(predictionResult)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(predictionResult.contains("Error") ? .red : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            // SDK Status Info (Detailed)
            VStack(alignment: .leading, spacing: 8) {
                Text("SDK Status Details:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("🔧 Initialized:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(isInitialized ? "✅ YES" : "❌ NO")
                            .font(.caption)
                            .foregroundColor(isInitialized ? .green : .red)
                    }
                    
                    HStack {
                        Text("🔑 SDK Key:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(sdkKey.prefix(12))...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("👤 User ID:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(userId)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("🛒 StoreKit:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text("Version \(useStoreKit2 ? "2" : "1")")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("📱 Platform:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text("iOS Native")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("🌐 Server:")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(isInitialized ? "🟢 Connected" : "🔴 Disconnected")
                            .font(.caption)
                            .foregroundColor(isInitialized ? .green : .red)
                    }
                    
                    if let exposureTimeSec = monetaiSDK.exposureTimeSec {
                        HStack {
                            Text("⏱️ Exposure Time:")
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(exposureTimeSec) sec")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Helper Methods
    private func initializeSDKs() {
        Task {
            // 🧪 Test logging for pending events before SDK initialization
            print("🧪 [PENDING EVENTS TEST] Starting event logging before SDK initialization...")
            
            await monetaiSDK.logEvent(eventName: "app_launched", params: [
                "launch_time": Date().timeIntervalSince1970,
                "version": "1.0.0",
                "device": "iOS"
            ])
            
            await monetaiSDK.logEvent(eventName: "app_background_to_foreground", params: [
                "session_start": true,
                "user_type": "example_user"
            ])
            
            await monetaiSDK.logEvent(eventName: "feature_accessed", params: [
                "feature": "monetai_example",
                "access_method": "direct_launch"
            ])
            
            print("🧪 [PENDING EVENTS TEST] 3 events logged before SDK initialization")
            print("🧪 [PENDING EVENTS TEST] Now initializing SDK to verify pending events are sent...")
            
            do {
                // Initialize RevenueCat
                Purchases.logLevel = .verbose
                Purchases.configure(with: .builder(withAPIKey: revenueCatAPIKey)
                    .with(appUserID: userId)
                    .with(storeKitVersion: useStoreKit2 ? .storeKit2 : .storeKit1)
                    .build()
                )
                
                print("🚀 [SDK] Starting Monetai SDK initialization...")
                
                // Initialize MonetaiSDK
                let result = try await monetaiSDK.initialize(
                    sdkKey: sdkKey,
                    userId: userId,
                    useStoreKit2: useStoreKit2
                )
                
                print("🎉 [SDK] Monetai SDK initialization complete!")
                
                await MainActor.run {
                    isInitialized = true
                    initializationResult = """
                    ✅ Monetai SDK initialization successful!
                    
                    📊 Initialization result:
                    • Organization ID: \(result.organizationId)
                    • Platform: \(result.platform)
                    • Version: \(result.version)
                    • User ID: \(result.userId)
                    • Test Group: \(result.group?.rawValue ?? "None")
                    
                    🎯 Status: Ready
                    🧪 Pending Events: 3 events before initialization sent automatically
                    """
                    initializationError = ""
                }
                
                // Log initialization event (sent immediately after SDK initialization)
                await monetaiSDK.logEvent(eventName: "monetai_initialized", params: [
                    "initialization_time": Date().timeIntervalSince1970,
                    "test_group": result.group?.rawValue ?? "none"
                ])
                
                // Load products
                await loadProducts()
                
                // Load customer info
                await loadCustomerInfo()
                
                print("MonetaiSDK initialized successfully: \(result)")
                
            } catch {
                await MainActor.run {
                    isInitialized = false
                    initializationError = """
                    ❌ Monetai SDK initialization failed

                    🚨 Error details:
                    \(error.localizedDescription)
                    
                    🔧 확인 사항:
                    • SDK 키가 올바른지 확인
                    • 네트워크 연결 상태 확인
                    • 서버 상태 확인
                    """
                    initializationResult = ""
                }
                print("Failed to initialize SDKs: \(error)")
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
                    // Fallback: 기본 패키지들 로드
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
        print("🛒 [PURCHASE] 구매 시작: \(package.storeProduct.productIdentifier)")
        print("🛒 [PURCHASE] 제품 정보: \(package.storeProduct.localizedTitle) - \(package.localizedPriceString)")
        
        do {
            print("🛒 [PURCHASE] RevenueCat purchase() 호출...")
            let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            
            print("🛒 [PURCHASE] 구매 완료!")
            print("🛒 [PURCHASE] Transaction: \(transaction?.debugDescription ?? "nil")")
            print("🛒 [PURCHASE] Transaction ID: \(transaction?.transactionIdentifier ?? "nil")")
            print("🛒 [PURCHASE] Product ID: \(transaction?.productIdentifier ?? "nil")")
            print("🛒 [PURCHASE] User cancelled: \(userCancelled)")
            print("🛒 [PURCHASE] Customer ID: \(customerInfo.originalAppUserId)")
            print("🛒 [PURCHASE] Active entitlements count: \(customerInfo.entitlements.active.count)")
            print("🛒 [PURCHASE] Active entitlements: \(customerInfo.entitlements.active.keys.joined(separator: ", "))")
            
            // userCancelled가 true인 경우 성공으로 처리하지 않음
            if userCancelled {
                print("🛒 [PURCHASE] 사용자가 구매를 취소했습니다.")
                return
            }
            
            await MainActor.run {
                self.customerInfo = customerInfo
                print("🛒 [PURCHASE] UI 업데이트 완료")
            }
            
            print("✅ Purchase successful: \(package.storeProduct.productIdentifier)")
            
        } catch {
            print("❌ Purchase failed: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            print("❌ Error type: \(type(of: error))")
            
            // RevenueCat 에러 타입별 상세 정보
            if let rcError = error as? RevenueCat.ErrorCode {
                print("❌ RevenueCat Error Code: \(rcError.rawValue)")
                print("❌ RevenueCat Error Description: \(rcError.description)")
            }
            
            // NSError로 캐스팅해서 더 자세한 정보 확인
            if let nsError = error as NSError? {
                print("❌ NSError domain: \(nsError.domain)")
                print("❌ NSError code: \(nsError.code)")
                print("❌ NSError userInfo: \(nsError.userInfo)")
            }
            
            // RevenueCat 에러 추가 정보
            print("❌ Error mirror: \(String(reflecting: error))")
            
            // 에러를 문자열로 변환해서 더 많은 정보 확인
            let errorString = String(describing: error)
            print("❌ Error description: \(errorString)")
        }
    }
    

    
    private func predictUser() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let result = try await monetaiSDK.predict()
            await MainActor.run {
                predictionResult = result.prediction?.rawValue ?? "Unknown"
                isLoading = false
            }
            
            // SDK가 자동으로 할인 정보를 확인하고 업데이트하므로 별도 호출 불필요
            
        } catch {
            await MainActor.run {
                predictionResult = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

}

// MARK: - Supporting Views
struct ProductRow: View {
    let package: Package
    let onPurchase: () async -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(package.storeProduct.localizedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(package.localizedPriceString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Buy") {
                print("🛒 [UI] Buy 버튼 클릭됨: \(package.storeProduct.productIdentifier)")
                Task {
                    print("🛒 [UI] onPurchase 콜백 호출 중...")
                    await onPurchase()
                    print("🛒 [UI] onPurchase 콜백 완료")
                }
            }
            .buttonStyle(BuyButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
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

// MARK: - Button Styles
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TestButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BuyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

//#Preview {
//    ContentView()
//}
