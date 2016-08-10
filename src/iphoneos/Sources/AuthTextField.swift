import Swift
import UIKit

public class AuthTextField: UITextField {
	override public func tintColorDidChange() {
		self.textColor = self.tintColor
	}
}