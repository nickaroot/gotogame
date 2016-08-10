import UIKit
import Material
import MapKit
import Proto

public class ProfileViewController: UIViewController {
	@IBOutlet
	weak var backButton: FabButton?

	@IBOutlet
	weak var firstNameLabel: UILabel?

	@IBOutlet
	weak var lastNameLabel: UILabel?

	@IBOutlet
	weak var avatarView: UIImageView?

	@IBOutlet
	weak var foundButton: RaisedButton?

	public var user: UserProfile?

	public override func viewDidLoad() {
		self.prepareBackButton()
		self.firstNameLabel?.text = user?.firstName
		self.lastNameLabel?.text = user?.lastName

		// FIXME: make asynchronous request
		if let
			imageUrl = user?.profileImage,
			url = NSURL(string: imageUrl),
			data = NSData(contentsOfURL: url) {

			self.avatarView?.image = UIImage(data: data)
		}
	}

	@IBAction
	func foundButtonTouchUp(sender: AnyObject) {
	}

	func prepareBackButton() {
		let img = MaterialIcon.cm.arrowBack
		self.backButton?.setImage(img, forState: .Normal)
		self.backButton?.setImage(img, forState: .Highlighted)
		self.backButton?.tintColor = MaterialColor.white
	}

	@IBAction
	func backButtonTouchUp(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}