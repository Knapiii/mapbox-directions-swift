import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// TODO: Make MatrixResponse adhere to codeable!
public struct MatrixResponse {
    // Is this value needed?
    public let httpResponse: HTTPURLResponse?
    
    public var durationsMatrix: [[Route]]?
    public var distanceMatrix: [[Route]]?
    public let destinations: [Waypoint]?
    public let sources: [Waypoint]?
    
    public let options: ResponseOptions
    public let credentials: DirectionsCredentials
}
