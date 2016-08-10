import Swift
import UIKit

@IBDesignable
public class AwesomeView: UIView {
	@IBInspectable
	var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
}