import UIKit
import SwiftUI
import Firebase
// Si tu AuthViewModel está en un archivo separado dentro de tu Target,
// normalmente no necesitas un 'import models', pero SÍ necesitas asegurar
// que el archivo de AuthViewModel esté compilado.
// Para ser más seguro y explícito:

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 1. Crea la instancia del modelo de autenticación
        let authViewModel = AuthViewModel()
        
        // 2. Crea la vista principal (ContentView), pasándole el modelo.
        let contentView = ContentView(authViewModel: authViewModel)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            // 3. Asigna ContentView como el controlador raíz de la ventana.
            window.rootViewController = UIHostingController(rootView: contentView)
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    // ... (El resto de las funciones delegate)
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
