import Foundation
import Turf

// TODO: INCLUDE MATRIX OPTIONS FOR REQUEST HERE

/**
 Options for calculating matrices from the Mapbox Matrix service.
 */
public class MatrixOptions: Codeable {
    // MARK: Creating a Matrix Options Object
    /**
     Initializes a matrix options object for matrices and a given profile identifier.
     
     - parameter waypoints: An array of `Waypoints` objects representing locations that will be in the matrix. The array should contain at least X coordinates and at most X coordinates. (Some profiles, such as `DirectionsProfileIdentifier.automobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/matrix/#matrix-api-restrictions-and-limits).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes.
     */
    public init(waypoints: [Waypoints], profileIdentifier: DirectionsProfileIdentifier) {
        self.waypoints = waypoints
        self.profileIdentifier = profileIdentifier
    }
    
    /**
     A string specifying the primary mode of transportation for the contours.
    */
    public var profileIdentifier: ProfileIdentifier
    
    /**
     An array of `Waypoints` objects representing locations that will be in the matrix.
     */
    public var waypoints: [Waypoints]
    
    /**
     Attribute options for the matrix. Only `AttributeOptions.distance` and `AttributeOptions.expectedTravelTime` can be specified. Currently, you can specify a single attribute or both.

     By default, `AttributeOptions.expectedTravelTime` is specified.
     */
    public var attributeOptions: AttributeOptions?
    
    /**
     The coordinates at a given index in the `waypoints` array that should be used as destinations.
     
     By default, all waypoints in the `waypoints` array are used as destinations.
     */
    public var destinations: [Int]?
    
    /**
     The coordinates at a given index in the `waypoints` array that should be used as sources.
     
     By default, all waypoints in the `waypoints` array are used as sources.
     */
    public var sources: [Int]?
    
    
    private enum CodingKeys: String, CodingKey {
        case waypoints
        case profileIdentifier = "profile"
        case attributeOptions = "annotations"
        case destinations
        case sources
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(profileIdentifier, forKey: .profileIdentifier)
        try container.encodeIfPresent(attributeOptions, forKey: .attributeOptions)
        try container.encodeIfPresent(destinations, forKey: .destinations)
        try container.encodeIfPresent(sources, forKey: .sources)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        waypoints = try container.decode([Waypoints].self, forKey: .waypoints)
        profileIdentifier = try container.decode(ProfileIdentifier.self, forKey: .profileIdentifier)
        attributeOptions = try container.decodeIfPresent(AttributeOptions.self, forKey: .attributeOptions)
        destinations = try container.decodeIfPresent([Int].self, forKey: .destinations)
        sources = try container.decodeIfPresent([Int].self, forKey: .sources)
    }
    
    // MARK: Getting the Request URL
    /**
        An array of URL query items to include in an HTTP request.
    */
   var abridgedPath: String {
       return "directions-matrix/v1/\(profileIdentifier.rawValue)"
   }

   /**
    The path of the request URL, not including the hostname or any parameters.
    */
   var path: String {
    guard let waypoints = waypoints, !waypoints.isEmpty else { assr}
       return "\(abridgedPath)/\(waypoints).json"
   }
    
    /**
     An array of URL query items (parameters) to include in an HTTP request.
     */
    // TODO: Fix appended query items formatting!
    public var urlQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        if let annotations = self.annotations && annotations.isSubset(of: [.distance, .expectedTravelTime]) {
            queryItems.append((URLQueryItem(name: "annotations", value: annotations)))
        }
        
        let mustArriveOnDrivingSide = !waypoints.filter { !$0.allowsArrivingOnOppositeSide }.isEmpty
        if mustArriveOnDrivingSide {
            let approaches = waypoints.map { $0.allowsArrivingOnOppositeSide ? "unrestricted" : "curb" }
            queryItems.append(URLQueryItem(name: "approaches", value: approaches.joined(separator: ";")))
        }
        
        if let destinations = self.destinations {
            queryItems.append(URLQueryItem(name: "destinations", value: destinations.joined(separator: ";")))
        }
        
        if let sources = self.sources {
            queryItems.append(URLQueryItem(name: "sources", value: sources.joined(separator: ";")))
        }
        return queryItems
    }
}

// TODO: Does MatrixOptions need to be Equatable?
