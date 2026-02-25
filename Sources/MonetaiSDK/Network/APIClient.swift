import Foundation
import Alamofire

/// Thread-safe header adapter that automatically injects SDK headers into every request
private class SDKHeaderAdapter: RequestInterceptor {
    private let lock = NSLock()
    private var headers: [String: String] = [
        SDKHeaders.sdkPlatform: "ios",
        SDKHeaders.sdkVersion: SDKVersion.getVersion(),
        SDKHeaders.deviceOS: "ios"
    ]

    func setHeader(_ key: String, value: String) {
        lock.lock()
        defer { lock.unlock() }
        headers[key] = value
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        lock.lock()
        let snapshot = headers
        lock.unlock()
        for (key, value) in snapshot {
            request.setValue(value, forHTTPHeaderField: key)
        }
        completion(.success(request))
    }
}

/// API client class
final class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://monetai-api-414410537412.us-central1.run.app/sdk"
    private let session: Session
    private let decoder: JSONDecoder
    private let headerAdapter = SDKHeaderAdapter()

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = Session(configuration: configuration, interceptor: headerAdapter)

        // JSONDecoder configuration
        self.decoder = JSONDecoder()

        // Support for ISO 8601 format with milliseconds
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
    }

    /// Set App Version header (called during initialization)
    func setAppVersionHeader(_ version: String) {
        headerAdapter.setHeader(SDKHeaders.appVersion, value: version)
    }

    /// Set Bundle ID header (called during initialization)
    func setBundleIdHeader(_ bundleId: String) {
        headerAdapter.setHeader(SDKHeaders.bundleId, value: bundleId)
    }

    /// Set User ID header (called during initialization)
    func setUserIdHeader(_ userId: String) {
        headerAdapter.setHeader(SDKHeaders.userId, value: userId)
    }

    /// Generic method to perform API requests
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ) async throws -> T {
        let url = baseURL + endpoint

        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: method, parameters: parameters, encoding: encoding)
                .validate()
                .response { response in
                    switch response.result {
                    case .success(let data):
                        // Handle empty response - when data is nil or empty
                        let responseData = data ?? Data()

                        let isEmptyResponse = responseData.isEmpty ||
                                            String(data: responseData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true

                        if isEmptyResponse {
                            if T.self == EmptyResponse.self {
                                continuation.resume(returning: EmptyResponse() as! T)
                                return
                            } else {
                                let error = DecodingError.dataCorrupted(
                                    DecodingError.Context(
                                        codingPath: [],
                                        debugDescription: "Empty response data"
                                    )
                                )
                                continuation.resume(throwing: MonetaiError.networkError(error))
                                return
                            }
                        }

                        do {
                            let value = try self.decoder.decode(T.self, from: responseData)
                            continuation.resume(returning: value)
                        } catch {
                            print("[MonetaiSDK] Decoding error: \(error)")
                            continuation.resume(throwing: MonetaiError.networkError(error))
                        }
                    case .failure(let error):
                        if let data = response.data,
                           let errorResponse = try? self.decoder.decode(ErrorResponse.self, from: data) {
                            continuation.resume(throwing: MonetaiError.apiError(errorResponse.message))
                        } else {
                            continuation.resume(throwing: MonetaiError.networkError(error))
                        }
                    }
                }
        }
    }
}

/// SDK HTTP header constants
enum SDKHeaders {
    static let sdkPlatform = "X-SDK-Platform"
    static let sdkVersion = "X-SDK-Version"
    static let deviceOS = "X-Device-OS"
    static let appVersion = "X-App-Version"
    static let bundleId = "X-App-Bundle-Id"
    static let userId = "X-User-Id"
}

/// API error response model
struct ErrorResponse: Codable {
    let message: String
}

/// Monetai SDK error type
public enum MonetaiError: Error, LocalizedError {
    case notInitialized
    case invalidSDKKey
    case invalidUserId
    case apiError(String)
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "MonetaiSDK has not been initialized. Please call initialize() first."
        case .invalidSDKKey:
            return "Invalid SDK key."
        case .invalidUserId:
            return "Invalid user ID."
        case .apiError(let message):
            return "API error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
