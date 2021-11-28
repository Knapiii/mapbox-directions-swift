import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct MatrixResponse {
    public let httpResponse: HTTPURLResponse?
    
    public let destinations: [Waypoint]?
    public let sources: [Waypoint]?
    public var distances: [Route]?
    public var durations: [Route]?
}

extension MatrixResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case error
        case distances
        case durations
        case destinations
        case sources
    }
    
    public init(httpResponse: HTTPURLResponse?, distances: [Route]?, durations: [Route]?, destinations: [Waypoint]?, sources: [Waypoint]?) {
        self.httpResponse = httpResponse
        self.destinations = destinations
        self.sources = sources
        self.distances = distances
        self.durations = durations
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var distances: [Route] = []
        var durations: [Route] = []
        
        self.httpResponse = decoder.userInfo[.httpResponse] as? HTTPURLResponse
        self.destinations = try container.decode([Waypoint].self, forKey: .destinations)
        self.sources = try container.decode([Waypoint].self, forKey: .sources)
        
        let decodedDistances = try container.decodeIfPresent([[Double]].self, forKey: .distances)
        decodedDistances?.forEach { distanceArray in
            distanceArray.forEach { distance in
                // TODO: get the profile identifier
                let leg = RouteLeg(steps: [], name: "", distance: distance, expectedTravelTime: 0, profileIdentifier: .automobile)
                distances.append(Route(legs: [leg], shape: nil, distance: distance, expectedTravelTime: 0))
            }
        }
        
        let decodedDurations = try container.decodeIfPresent([[Double]].self, forKey: .durations)
        decodedDurations?.forEach { durationArray in
            durationArray.forEach { duration in
                // TODO: get the profile identifier
                let leg = RouteLeg(steps: [], name: "", distance: 0, expectedTravelTime: duration, profileIdentifier: .automobile)
                durations.append(Route(legs: [leg], shape: nil, distance: 0, expectedTravelTime: duration, typicalTravelTime: nil))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(destinations, forKey: .destinations)
        try container.encode(sources, forKey: .sources)
        try container.encodeIfPresent(distances, forKey: .distances)
        try container.encodeIfPresent(durations, forKey: .durations)
    }
}
