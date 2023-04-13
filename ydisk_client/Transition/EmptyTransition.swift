import UIKit

final class EmptyTransition: Transition {
    func open(_ viewController: UIViewController, from: UIViewController, completion: (() -> Void)?) {}
    func close(_ viewController: UIViewController, completion: (() -> Void)?) {}
}
