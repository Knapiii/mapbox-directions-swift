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
     
     - parameter coordinates: An array of `LocationCoordinate2D` objects representing locations that will be in the matrix. The array should contain at least X coordinates and at most X coordinates. (Some profiles, such as `DirectionsProfileIdentifier.automobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/matrix/#matrix-api-restrictions-and-limits).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes.
     */
    public init(coordinates: [LocationCoordinate2D], profileIdentifier: DirectionsProfileIdentifier) {
        self.coordinates = coordinates
        self.profileIdentifier = profileIdentifier
    }
    
    /**
     Side of road for approaching locations in `coordinates` array.
     */
    public enum SideOfRoad {
        /**
         
         */
        case unrestricted
        case curb
    }
    
    /**
     A string specifying the primary mode of transportation for the contours.
    */
    public var profileIdentifier: ProfileIdentifier
    
    /**
     An array of `LocationCoordinate2D` objects representing locations that will be in the matrix.
     */
    public var coordinates: [LocationCoordinate2D]
    
    /**
     AttributeOptions for the matrix. Only `AttributeOptions.distance` and `AttributeOptions.expectedTravelTime` can be specified.

     By default, no attribute options are specified.
     */
    // TODO: Include comment about these options will return duration matrix, distance matrix, or both
    public var attributeOptions: AttributeOptions?
    
    /**
     The side of the road from which to approach waypoints in the requested route.
     */
    // TODO: Include default
    // Shoul
    public var approachSides: [SideOfRoad]?
    
    // TODO: How to handle index vs .all values? default to .all
    public var destinations: [Int]? = []
    public var sources: [Int]? = []
    
    
    private enum CodingKeys: String, CodingKey {
        case coordinates
        case profileIdentifier = "profile"
        case attributeOptions = "annotations"
        case approachSides = "approaches"
        case destinations
        case sources
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(profileIdentifier, forKey: .profileIdentifier)
        try container.encodeIfPresent(attributeOptions, forKey: .attributeOptions)
        try container.encodeIfPresent(approachSides, forKey: .approachSides)
        try container.encodeIfPresent(destinations, forKey: .destinations)
        try container.encodeIfPresent(sources, forKey: .sources)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coordinates = try container.decode([LocationCoordinate2D].self, forKey: .coordinates)
        profileIdentifier = try container.decode(ProfileIdentifier.self, forKey: .profileIdentifier)
        attributeOptions = try container.decodeIfPresent(AttributeOptions.self, forKey: .attributeOptions)
        approachSides = try container.decodeIfPresent([SideOfRoad].self, forKey: .approachSides)
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
     TODO: Verify this!
    */
   var path: String {
    guard let coordinates = coordinates, !coordinates.isEmpty else { assr}
       return "\(abridgedPath)/\(coordinates).json"
   }
    
    /**
     An array of URL query items (parameters) to include in an HTTP request.
     */
    public var urlQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        // TODO: Handle formatting of query items
        if let annotations = self.annotations {
            queryItems.append((URLQueryItem(name: "annotations", value: annotations)))
        }
        if let sideOfApproach = self.sideOfApproach {
            queryItems.append(URLQueryItem(name: "approaches", value: sideOfApproach))
        }
        if let destinations = self.destinations {
            queryItems.append(URLQueryItem(name: "destinations", value: destinations))
        }
        if let sources = self.sources {
            queryItems.append(URLQueryItem(name: "sources", value: sources))
        }
        return queryItems
    }
}

// TODO: Does MatrixOptions need to be Equatable?
