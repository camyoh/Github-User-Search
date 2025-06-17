import UIKit
@testable import git_test

class MockNavigationController: UINavigationController {
    var presentedVC: UIViewController?
    var pushedVC: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedVC = viewController
        super.pushViewController(viewController, animated: animated)
    }
    
    override var visibleViewController: UIViewController? {
        return self
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedVC = viewControllerToPresent
        // No llamamos al super para evitar presentar realmente el controlador en las pruebas
        if let completion = completion {
            completion()
        }
    }
}
