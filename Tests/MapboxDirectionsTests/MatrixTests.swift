import XCTest
#if !os(Linux)
import OHHTTPStubs
#if SWIFT_PACKAGE
import OHHTTPStubsSwift
#endif
#endif
#if canImport(CoreLocation)
import CoreLocation
#endif
import Turf
@testable import MapboxDirections

let MatrixBogusCredentials = Credentials(accessToken: BogusToken)

#if !os(Linux)
class MatrixTests: XCTestCase {
    override func tearDown() {
        #if !os(Linux)
        HTTPStubs.removeAllStubs()
        #endif
        super.tearDown()
    }
    
    func testConfiguration() {
        let matrices = Matrix(credentials: MatrixBogusCredentials)
        XCTAssertEqual(matrices.credentials, MatrixBogusCredentials)
    }
    
    func testRequest() {
        let waypoints = [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.751668, longitude: -122.418408), name: "Mission Street"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.755184, longitude: -122.422959), name: "22nd Street"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.759695, longitude: -122.426911))
        ]
        
        let options = MatrixOptions(waypoints: waypoints, profileIdentifier: .automobile)
        options.destinations = [0, 1, 2]
        options.sources = [0, 1, 2]
        options.attributeOptions = [.distance, .expectedTravelTime]

        let matrices = Matrix(credentials: MatrixBogusCredentials)
        let url = matrices.url(forCalculating: options)
        let request = matrices.urlRequest(forCalculating: options)

        guard let components = URLComponents(string: url.absoluteString),
              let queryItems = components.queryItems else { XCTFail("Invalid url"); return }

        XCTAssertEqual(queryItems.count, 4)
        XCTAssertTrue(components.path.contains(waypoints.compactMap { $0.coordinate.requestDescription
        }.joined(separator: ";")))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "access_token" && $0.value == BogusToken }))
        XCTAssertTrue(queryItems.contains(where: {
            $0.name == "annotations" && $0.value == "distance,duration"}))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "destinations" && $0.value == "0;1;2"}))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "sources" && $0.value == "0;1;2"}))
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url, url)
    }
    

    func testUnknownBadResponse() {
        let message = "Lorem ipsum."
        HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/directions-matrix")
        }) { (_) -> HTTPStubsResponse in
            // TODO: Check status code
            return HTTPStubsResponse(data: message.data(using: .utf8)!, statusCode: 420, headers: ["Content-Type" : "text/plain"])
        }
        let expectation = self.expectation(description: "Async callback")
        let one = CLLocation(latitude: 0.0, longitude: 0.0)
        let two = CLLocation(latitude: 2.0, longitude: 2.0)
        let waypoints = [Waypoint(location: one), Waypoint(location: two)]
        
        let matrix = Matrix(credentials: MatrixBogusCredentials)
        let options = MatrixOptions(waypoints: waypoints, profileIdentifier: .automobile)
        matrix.calculate(options, completionHandler: { (session, result) in
            defer { expectation.fulfill() }

            guard case let .failure(error) = result else {
                XCTFail("Expecting an error, none returned. \(result)")
                return
            }

            guard case .invalidResponse(_) = error else {
                XCTFail("Wrong error type returned.")
                return
            }
        })
        wait(for: [expectation], timeout: 2.0)
    }

    func testDownNetwork() {
        let notConnected = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue) as! URLError
        
        HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/directions-matrix")
        }) { (_) -> HTTPStubsResponse in
            return HTTPStubsResponse(error: notConnected)
        }

        let expectation = self.expectation(description: "Async callback")
        let one = CLLocation(latitude: 0.0, longitude: 0.0)
        let two = CLLocation(latitude: 2.0, longitude: 2.0)
        let waypoints = [Waypoint(location: one), Waypoint(location: two)]
        
        let matrix = Matrix(credentials: MatrixBogusCredentials)
        let options = MatrixOptions(waypoints: waypoints, profileIdentifier: .automobile)
        
        matrix.calculate(options, completionHandler: { (session, result) in
            defer { expectation.fulfill() }

            guard case let .failure(error) = result else {
                XCTFail("Error expected, none returned. \(result)")
                return
            }

            guard case let .network(err) = error else {
                XCTFail("Wrong error type returned. \(error)")
                return
            }

            // Comparing just the code and domain to avoid comparing unessential `UserInfo` that might be added.
            XCTAssertEqual(type(of: err).errorDomain, type(of: notConnected).errorDomain)
            XCTAssertEqual(err.code, notConnected.code)
        })
        wait(for: [expectation], timeout: 2.0)
    }

    func testRateLimitErrorParsing() {
        let url = URL(string: "https://api.mapbox.com")!
        let headerFields = ["X-Rate-Limit-Interval" : "60", "X-Rate-Limit-Limit" : "600", "X-Rate-Limit-Reset" : "1479460584"]
        let response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: headerFields)

        let resultError = MatrixError(code: "429", message: "Hit rate limit", response: response, underlyingError: nil)
        if case let .rateLimited(rateLimitInterval, rateLimit, resetTime) = resultError {
            XCTAssertEqual(rateLimitInterval, 60.0)
            XCTAssertEqual(rateLimit, 600)
            XCTAssertEqual(resetTime, Date(timeIntervalSince1970: 1479460584))
        } else {
            XCTFail("Code 429 should be interpreted as a rate limiting error.")
        }
    }
}
#endif
