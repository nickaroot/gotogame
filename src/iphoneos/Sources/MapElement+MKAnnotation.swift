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
		return nil // FIXME: add subtitle? possibly, distance to user?
	}
}