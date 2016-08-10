import Swift
import MapKit
import Proto

extension MapElement: MKAnnotation {
	public var coordinate: CLLocationCoordinate2D {
		_ = srand48(time(nil))
		return CLLocationCoordinate2D(
			latitude: self.location?.lat ?? drand48(),
			longitude: self.location?.lon ?? drand48())
	}

	public var title: String? {
		guard let
			lastName = self.user.lastName,
			firstName = self.user.firstName
			else { return nil }
		return "\(firstName) \(lastName)"
	}

	public var subtitle: String? {
//        let testCoords = CLLocationCoordinate2DMake(drand48(), drand48())
//        let location1 = CLLocation.init(coordinate: self.coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSinceReferenceDate: 0))
//        let location2 = CLLocation.init(coordinate: testCoords, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSinceReferenceDate: 0))
//        let distance = String(location1.distanceFromLocation(location2))
//        return distance
        return nil // FIXME: Setup distance
	}
}