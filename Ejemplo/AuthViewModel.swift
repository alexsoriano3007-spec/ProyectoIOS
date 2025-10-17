import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    // 🛑 @Published es la clave: notifica a SwiftUI si el usuario ha cambiado
    @Published var isAuthenticated: Bool = false
    
    init() {
        // Observa los cambios de estado de Firebase Auth
        Auth.auth().addStateDidChangeListener { auth, user in
            // Si user no es nil, significa que hay un usuario logeado
            self.isAuthenticated = user != nil
        }
    }
    
    // Función para cerrar sesión (la necesitaremos después)
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error al cerrar sesión: \(signOutError)")
        }
    }
}
