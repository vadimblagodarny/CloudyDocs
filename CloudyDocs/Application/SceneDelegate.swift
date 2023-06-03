import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let router = DefaultRouter(rootTransition: EmptyTransition())
        
        let recentsView = router.makeItemList(role: ItemListRole.recentsViewRole,
                                              tabImage: UIImage(systemName: "clock") ?? UIImage(),
                                              path: nil)
        
        let allFilesView = router.makeItemList(role: .allFilesViewRole,
                                              tabImage: UIImage(systemName: "folder") ?? UIImage(),
                                               path: "disk:/")
        
        let accountView = router.makeAccount()
        
        let tabBar = UITabBarController()
        let tabs = [recentsView, allFilesView, accountView]
        tabBar.viewControllers = tabs
        tabBar.tabBar.isHidden = true

        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}
