import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 An error that occurs when computing matrices.
 */
public enum MatrixError: LocalizedError {
    
    public init(code: String?, message: String?, response: URLResponse?, underlyingError error: Error?) {
        if let response = response as? HTTPURLResponse {
            switch (response.statusCode, code ?? "") {
            // TODO: What are the error codes for network and rate limiting?
            case (200, "NoRoute"):
                self = .noRoute
            case (404, "ProfileNotFound"):
                self = .profileNotFound
            case (422, "InvalidInput"):
                self = .invalidInput(message: message)
            default:
                self = .unknown(response: response, underlying: error, code: code, message: message)
            }
        } else {
            self = .unknown(response: response, underlying: error, code: code, message: message)
        }
    }
    
    /**
     There is no network connection available to perform the network request.
     */
    case network(_: URLError)
    
    /**
     The API did not find a route for the given coordinates. Check for impossible routes or incorrectly formatted coordinates.
     */
    case noRoute
    
    /**
     Unrecognized profile identifier.
     
     Make sure the `MatrixOptions.profileIdentifier` option is set to one of the predefined values, such as `MatrixProfileIdentifier.automobile`.
     */
    case profileNotFound
    
    /**
    The API recieved input that it didn't understand.
     */
    case invalidInput(message: String?)
    
    /**
     Too many requests have been made with the same access token within a certain period of time.
     
     Wait before retrying.
     */
    case rateLimited(rateLimitInterval: TimeInterval?, rateLimit: UInt?, resetTime: Date?)
    
    /**
     Unknown error case. Look at associated values for more details.
     */
    case unknown(response: URLResponse?, underlying: Error?, code: String?, message: String?890iuo)
}
