import SwiftUI

struct MainListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var searchText = ""
    @State private var showAddPassword = false
    
    // Datos de ejemplo y lógica de filtro... (SE MANTIENE IGUAL)
    let samplePasswords = [
        (id: 1, service: "Gmail", username: "usuario@gmail.com"),
        (id: 2, service: "Facebook", username: "usuario@facebook.com"),
        (id: 3, service: "Twitter", username: "usuario@twitter.com")
    ]
    
    var filteredPasswords: [(id: Int, service: String, username: String)] {
        if searchText.isEmpty {
            return samplePasswords
        } else {
            return samplePasswords.filter {
                $0.service.lowercased().contains(searchText.lowercased()) ||
                $0.username.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // --------------------------------------------------------------------------
    
    var body: some View {
        VStack {
            // ... (Barra de búsqueda: se mantiene igual)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Buscar servicios...", text: $searchText)
            }
            .padding(10)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .padding([.top, .horizontal])
            
            List {
                ForEach(filteredPasswords, id: \.id) { item in
                    NavigationLink(destination: PasswordDetailView(service: item.service, username: item.username)) {
                        VStack(alignment: .leading) {
                            Text(item.service)
                                .font(.system(.headline, design: .rounded))
                            Text(item.username)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        
        // 🛑 CORRECCIÓN CLAVE: Usamos .inline para forzar la visibilidad de los botones
        .navigationBarTitle(Text("Mis Contraseñas"), displayMode: .inline)
        
        .navigationBarItems(
            // Botón CERRAR SESIÓN (Leading)
            leading: Button(action: {
                authViewModel.signOut()
            }) {
                Text("Cerrar Sesión")
                    .foregroundColor(.red) // Destacamos la acción de salir
            },
            
            // Botón AÑADIR (Trailing)
            trailing: Button(action: {
                self.showAddPassword = true
            }) {
                // 🛑 CORRECCIÓN: Usamos un ícono básico compatible con iOS 13
                Image(systemName: "plus.circle")
                    .font(.title)
            }
        )
        .sheet(isPresented: $showAddPassword) {
            // Asegúrate de que AddPasswordView esté implementada
            AddPasswordView()
        }
    }
}
