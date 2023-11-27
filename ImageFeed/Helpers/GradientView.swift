import UIKit

@IBDesignable
final class GradientView: UIView {

    @IBInspectable private var FirstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable private var SecondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
      private func updateView() {
            let layer = self.layer as! CAGradientLayer
            layer.colors = [ FirstColor.cgColor, SecondColor.cgColor ]
            layer.locations = [ 0.0, 1.0 ]
        }
}
