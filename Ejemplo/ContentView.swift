import SwiftUI
import Firebase

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // ✅ CORRECCIÓN: Envuelve la vista principal en un NavigationView
                NavigationView {
                    MainListView()
                }
                .environmentObject(authViewModel)
                
            } else {
                NavigationView {
                    LoginView()
                }
            }
        }
    }
}
