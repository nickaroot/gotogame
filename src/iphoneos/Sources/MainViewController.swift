import Swift
import UIKit
import MapKit
import QuartzCore
import Material

import Proto

// FIXME: temporary typealiases for tests. DELETE THEM!!!!
// Use self as a delegate instead.
typealias Coordinate = (latitude: Double, longitude: Double)
typealias Client = (coordinate: Coordinate, title: String, subtitle: String)

public class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	@IBOutlet
	weak var bView: UIVisualEffectView?
	@IBOutlet
	weak var visEfView: UIVisualEffectView?
	@IBOutlet
	weak var loginTextField: AwesomeTextField?
	@IBOutlet
	weak var passwordTextField: AwesomeTextField?
	@IBOutlet
	weak var signView: AuthView?
	@IBOutlet
	weak var mapView: MKMapView?
	@IBOutlet
	weak var nuLabel: UILabel?
	@IBOutlet
	weak var baseConstraint: NSLayoutConstraint?

    @IBOutlet
    weak var mButton: FabButton!
    
    public let remoteHost = "nickaroot.me:5001"
    
	public var manager: CLLocationManager?

	public override func viewDidLoad() {
		super.viewDidLoad()
        
        GRPCCall.useInsecureConnectionsForHost(remoteHost)

		self.manager = CLLocationManager()

		mapView?.delegate = self
		manager?.delegate = self

		let animate = #selector(
			MainViewController.animate(usingKeyboardNotification:))

		NSNotificationCenter.defaultCenter()
			.addObserver(
				self,
				selector: animate,
				name: UIKeyboardWillShowNotification,
				object: nil)
		NSNotificationCenter.defaultCenter()
			.addObserver(
				self,
				selector: animate,
				name: UIKeyboardWillHideNotification,
				object: nil)

		loginTextField?.backgroundColor = UIColor(white: 1.0, alpha: 0)
		passwordTextField?.backgroundColor = UIColor(white: 1.0, alpha: 0)
		signView?.backgroundColor = UIColor(white: 1.0, alpha: 0.1)

		self.prepareMButton()
	}

	@IBAction
	public func mButtonTouchUp(sender: AnyObject) {
        var clientsArray = [Client]()
        
        clientsArray.append(Client(
            coordinate: (55.806304123305, 37.54148039039),
            title: "Muhammad Solomon",
            subtitle: "124 метра")
        )
        self.loadAnnotations(clientsArray)
	}

	public func mapViewDidFinishLoadingMap(mapView: MKMapView) {
//		var clientsArray = [Client]()
//
//		clientsArray.append(Client(
//			coordinate: (55.806304123305, 37.54148039039),
//			title: "Muhammad Solomon",
//			subtitle: "124 метра")
//		)
//		self.loadAnnotations(clientsArray)
	}

	public func mapView(
		mapView: MKMapView,
		viewForAnnotation annotation: MKAnnotation
		) -> MKAnnotationView? {

		if annotation is MKUserLocation {
			//return nil so map view draws "blue dot" for standard user location
			return nil
		}

		let reuseId = StaticConstant.ReuseIdentifier.pinView

		let pinView = self.mapView?
			.dequeueReusableAnnotationViewWithIdentifier(
				reuseId) as? MKPinAnnotationView ?? {

			let view = MKPinAnnotationView(
				annotation: annotation,
				reuseIdentifier: reuseId)
			view.canShowCallout = true
			view.animatesDrop = true

			if #available(iOS 9.0, *) {
				view.pinTintColor = .redColor()
			} else {
				// TODO: Fallback on earlier versions
			}

			view.rightCalloutAccessoryView = UIButton(type: .ContactAdd)
			return view
		}()

		pinView.annotation = annotation

		return pinView
	}

	public func mapView(
		mapView: MKMapView,
		annotationView view: MKAnnotationView,
		calloutAccessoryControlTapped control: UIControl
	) {

		if control == view.rightCalloutAccessoryView {
			let up = UserProfile()
			up.firstName = "Muhammad"
			up.lastName = "Solomon"
			up.profileImage = "http://euphrates.org/wp-content/uploads/2015/03/terrorism-guy.jpg"
			performSegueWithIdentifier(StaticConstant.Segue.fromMainToProfile, sender: up)
			//performSegueWithIdentifier(kAwesomeSegue, sender: (view.annotation as? MapElement)?.user)
		}
	}

	public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier {
		case .Some(StaticConstant.Segue.fromMainToProfile):
			guard let
				dst = segue.destinationViewController as? ProfileViewController,
				usr = sender as? UserProfile
				else { break }

			dst.user = usr
		case _:
			break
		}
	}

//	let newYork = CLLocationCoordinate2DMake(40.730872, -74.003066)
//	let dropPin = MKPointAnnotation()
//	dropPin.coordinate = newYork
//	dropPin.title = "New York City"
//	self.mapView?.addAnnotation(dropPin)

	func loadAnnotations(clients: [Client]){
		for client in clients  {
			let annotation = MKPointAnnotation()
			annotation.title = client.title
			annotation.subtitle = client.subtitle
			annotation.coordinate = CLLocationCoordinate2DMake(
				client.coordinate.latitude,
				client.coordinate.longitude)

			self.mapView?.addAnnotation(annotation)
		}

	}
    
    public func errorAlertDissmised(action: UIAlertAction) -> Void {
        switch action.title! {
        case "Dismiss":
            passwordTextField?.text = ""
            loginTextField?.becomeFirstResponder()
            break
        default:
            resignFirstResponder()
        }
    }
    
    public func authSucceed(token: String, animationDuration: Double) {
        UIView.animateWithDuration(animationDuration) {
            self.bView?.effect = UIBlurEffect(style: .ExtraLight)
            self.bView?.alpha = 0
        }
        
//        let service = AuthService(host: remoteHost)
//        
//        let request = LocationUpdateRequest()
//        request.token = token
//        request.lat = (manager?.location?.coordinate.latitude)!
//        request.lon = (manager?.location?.coordinate.longitude)!
//        
//        service.updateLocationWithRequest(request, eventHandler: nil)
    }

	public func authRequest(login lgn: String, pass: String) {

        let request = AuthTokenRequest()
		request.login = lgn
		request.pass = pass

//		let service = MuService(host: "")
//		service.updateLocationWithRequest(<#T##request: LocationUpdateRequest##LocationUpdateRequest#>, eventHandler: <#T##(Bool, MapElement?, NSError?) -> Void#>)
        
        let service = AuthService(host: remoteHost)
		service.authorizeWithRequest(request) { response, error in
			guard let response = response where error == nil else {
                var errMsg = ""
				//fatalError(#function) // FIXME: !!
                switch (error!.code) {
                    case 2:
                        errMsg = "Invalid Password"
                        break
                    default:
                        errMsg = "Unknown Error \(error!.code)"
                        break
                }
                
                let alertController = UIAlertController(title: "Authentication Failed", message: errMsg, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: self.errorAlertDissmised))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return
			}
            
            self.authSucceed(response.token, animationDuration: 0.5)
		}
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == loginTextField {
			self.passwordTextField?.becomeFirstResponder()
			return true
		}
		if textField == passwordTextField {
//			defer {
//				authRequest(
//					login: self.loginTextField?.text ?? "",
//					pass: self.passwordTextField?.text ?? "")
//			}
            
            UIView.animateWithDuration(0.5) {
                self.bView?.effect = UIBlurEffect(style: .ExtraLight)
                self.bView?.alpha = 0
            }

			textField.resignFirstResponder()
			return false
		}
		return true
	}

	public func locationManager(
		manager: CLLocationManager,
		didChangeAuthorizationStatus status: CLAuthorizationStatus
	) {
		switch status {
		case .NotDetermined:
			self.manager?.requestAlwaysAuthorization()
			break
		case .AuthorizedWhenInUse:
			self.manager?.requestAlwaysAuthorization()
			//manager.startUpdatingLocation()
			break
		case .AuthorizedAlways:
			self.mapView?.showsUserLocation = true
			self.manager?.startUpdatingLocation()
			break
		case .Restricted:
			// restricted by e.g. parental controls. 
			// User can't enable Location Services
			break
		case .Denied:
			// user denied your app access to Location Services, 
			// but can grant access from Settings.app
			break
		}
	}

	func prepareMButton() {
		let img = MaterialIcon.cm.edit
		mButton.setImage(img, forState: .Normal)
		mButton.setImage(img, forState: .Highlighted)
		mButton.tintColor = MaterialColor.white
	}

	func animate(usingKeyboardNotification notification: NSNotification) {
		let name = notification.name
		let show = (name == UIKeyboardWillShowNotification)
		guard let
			userInfo = notification.userInfo,
			frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
			duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
			curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
		where
			show || name == UIKeyboardWillHideNotification
		else { return }

		self.baseConstraint?.constant = show ? -frame.height / 2 : 0


		let options = UIViewAnimationOptions(rawValue: curve << 16)
		UIView.animateWithDuration(duration, delay: 0, options: options,
		                           animations: {
																self.view.layoutIfNeeded()
			},
		                           completion: nil
		)

	}
}