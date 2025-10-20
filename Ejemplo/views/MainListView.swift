import SwiftUI
import FirebaseAuth

struct MainListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var passwordViewModel = PasswordViewModel()
    
    @State private var searchText = ""
    @State private var showAddPassword = false
    @State private var showLogoutConfirmation = false
    @State private var isRefreshing = false
    
    // Color azul principal
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con título y botones
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mis Contraseñas")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(mainBlue)
                        
                        Text("\(passwordViewModel.passwords.count) contraseñas guardadas")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Botón de Refresh
                    Button(action: {
                        refreshPasswords()
                    }) {
                        VStack(spacing: 2) {
                            if isRefreshing {
                                Text("⟳")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(mainBlue)
                            } else {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(mainBlue)
                            }
                            Text("Actualizar")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(mainBlue)
                        }
                    }
                    .padding(.trailing, 10)
                    .disabled(isRefreshing)
                    
                    // Botón de Cerrar Sesión
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.red)
                            Text("Salir")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Botón de Agregar
                    Button(action: {
                        self.showAddPassword = true
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(mainBlue)
                            Text("Agregar")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(mainBlue)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 15)
            .background(lightBlue)
            
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(mainBlue)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Buscar servicios...", text: $searchText)
                    .font(.system(size: 16, design: .rounded))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 15)
            .padding(.bottom, 10)
            
            // Lista de contraseñas
            if passwordViewModel.passwords.isEmpty {
                // Vista cuando no hay contraseñas
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(mainBlue.opacity(0.5))
                    
                    VStack(spacing: 8) {
                        Text("No hay contraseñas")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(mainBlue)
                        
                        Text("Toca el botón Agregar para crear tu primera contraseña")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Botón de refresh en estado vacío
                    Button(action: {
                        refreshPasswords()
                    }) {
                        HStack(spacing: 8) {
                            if isRefreshing {
                                Text("⟳")
                                    .font(.system(size: 16, weight: .medium))
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            Text(isRefreshing ? "Actualizando..." : "Actualizar Lista")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(mainBlue)
                        .cornerRadius(10)
                    }
                    .disabled(isRefreshing)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 40)
            } else {
                List {
                    ForEach(passwordViewModel.passwords) { password in
                        NavigationLink(destination: PasswordDetailView(password: password)) {
                            HStack(spacing: 12) {
                                // Ícono del servicio
                                ZStack {
                                    Circle()
                                        .fill(mainBlue.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: getIconForService(password.service))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(mainBlue)
                                }
                                
                                // Información
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(password.service)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(mainBlue)
                                    
                                    Text(password.username)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                // Indicador de seguridad
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deletePassword)
                }
                .listStyle(PlainListStyle())
            }
            
            Spacer()
        }
        .background(lightBlue.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showAddPassword) {
            AddPasswordView(passwordViewModel: passwordViewModel)
        }
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text("Cerrar Sesión"),
                message: Text("¿Estás seguro de que quieres cerrar sesión?"),
                primaryButton: .destructive(Text("Cerrar Sesión")) {
                    authViewModel.signOut()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
        .onAppear {
            // ✅ DEBUG PARA VERIFICAR EL CAMBIO
            if let user = Auth.auth().currentUser {
                print("🔍 DEBUG - UID ACTUAL: \(user.uid)")
                print("🔍 DEBUG - EMAIL ACTUAL: \(user.email ?? "no email")")
            } else {
                print("❌ DEBUG - No hay usuario autenticado")
            }
            
            passwordViewModel.fetchPasswords()
        }
    }
    
    private func deletePassword(at offsets: IndexSet) {
        offsets.forEach { index in
            let password = passwordViewModel.passwords[index]
            passwordViewModel.deletePassword(password)
        }
    }
    
    private func refreshPasswords() {
        isRefreshing = true
        passwordViewModel.refreshPasswords()
        
        // Simular un pequeño delay para el feedback visual
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isRefreshing = false
        }
    }
    
    // Función para obtener ícono según el servicio - ACTUALIZADA CON MÁS REDES SOCIALES
    private func getIconForService(_ service: String) -> String {
        let lowercased = service.lowercased()
        
                if lowercased == "x" || lowercased.contains(" x ") || lowercased.hasSuffix(" x") || lowercased.hasPrefix("x ") {
                    return "x.circle.fill" // Ícono especial para X
                } else if lowercased.contains("twitter") || lowercased.contains("x.com") {
                    return "bird.fill"
                } else if lowercased.contains("gmail") || lowercased.contains("google") {
                    return "envelope.fill"
        } else if lowercased.contains("facebook") {
            return "f.circle.fill"
        } else if lowercased.contains("twitter") || lowercased.contains("x.com") || lowercased.contains("x ") {
            return "bird.fill"
        } else if lowercased.contains("instagram") {
            return "camera.fill"
        } else if lowercased.contains("netflix") {
            return "play.tv.fill"
        } else if lowercased.contains("apple") {
            return "applelogo"
        } else if lowercased.contains("amazon") {
            return "a.circle.fill"
        } else if lowercased.contains("microsoft") {
            return "m.circle.fill"
        } else if lowercased.contains("whatsapp") {
            return "message.fill"
        } else if lowercased.contains("spotify") {
            return "music.note"
        } else if lowercased.contains("youtube") {
            return "play.rectangle.fill"
        } else if lowercased.contains("linkedin") {
            return "l.circle.fill"
        } else if lowercased.contains("tiktok") {
            return "music.note.list"
        } else if lowercased.contains("discord") {
            return "bubble.left.fill"
        } else if lowercased.contains("telegram") {
            return "paperplane.fill"
        } else if lowercased.contains("snapchat") {
            return "camera.viewfinder"
        } else if lowercased.contains("pinterest") {
            return "pin.fill"
        } else if lowercased.contains("reddit") {
            return "r.circle.fill"
        } else if lowercased.contains("twitch") {
            return "gamecontroller.fill"
        } else if lowercased.contains("paypal") {
            return "dollarsign.circle.fill"
        } else if lowercased.contains("ebay") {
            return "cart.fill"
        } else if lowercased.contains("airbnb") {
            return "house.fill"
        } else if lowercased.contains("uber") {
            return "car.fill"
        } else if lowercased.contains("dropbox") {
            return "folder.fill"
        } else if lowercased.contains("github") {
            return "chevron.left.slash.chevron.right"
        } else if lowercased.contains("slack") {
            return "bubble.left.and.bubble.right.fill"
        } else if lowercased.contains("zoom") {
            return "video.fill"
        } else if lowercased.contains("skype") {
            return "video.circle.fill"
        } else if lowercased.contains("outlook") || lowercased.contains("hotmail") {
            return "envelope.open.fill"
        } else if lowercased.contains("yahoo") {
            return "y.circle.fill"
        } else if lowercased.contains("tumblr") {
            return "t.circle.fill"
        } else if lowercased.contains("flickr") {
            return "photo.fill"
        } else if lowercased.contains("vimeo") {
            return "play.circle.fill"
        } else if lowercased.contains("wordpress") {
            return "w.circle.fill"
        } else if lowercased.contains("blogger") {
            return "book.fill"
        } else if lowercased.contains("wechat") {
            return "message.circle.fill"
        } else if lowercased.contains("line") {
            return "line.diagonal"
        } else if lowercased.contains("bank") || lowercased.contains("banco") {
            return "banknote.fill"
        } else if lowercased.contains("email") || lowercased.contains("correo") {
            return "envelope.fill"
        } else if lowercased.contains("wifi") {
            return "wifi"
        } else if lowercased.contains("vpn") {
            return "network"
        } else {
            return "lock.fill"
        }
    }
}
