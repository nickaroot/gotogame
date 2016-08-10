import Swift
import UIKit

public class AwesomeTextField: UITextField {
	override public func tintColorDidChange() {
		self.textColor = self.tintColor
	}
}