import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    // Función de login (se mantiene igual)
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            } else {
                print("Inicio de sesión exitoso.")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) { // <--- VStack PRINCIPAL

            Text("Password Manager")
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(Color.blue)
                .padding(.top, 50)
            
            // Sección de Campos de Texto
            VStack(spacing: 15) {
                TextField("Correo electrónico", text: $email)
                    .modifier(CustomTextFieldModifier())
                
                SecureField("Contraseña", text: $password)
                    .modifier(CustomTextFieldModifier())
            }
            
            // Botón de Iniciar Sesión (El texto que sí se ve)
            Button(action: login) {
                Text("Iniciar Sesión") // <--- ESTE ES EL TEXTO QUE SE VE
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            
            // 🛑 El Spacer empuja todo el contenido hacia arriba.
            Spacer()

            // Link de Registro (debe estar abajo)
            NavigationLink(
                destination: RegisterView(isShowingRegisterView: $showingRegister),
                isActive: $showingRegister
            ) {
                Text("¿No tienes cuenta? Regístrate")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .isDetailLink(false)
        }
        .padding(30)
        .navigationBarHidden(true) // Oculta la barra de navegación en el login
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error de Inicio de Sesión"),
                  message: Text(errorMessage ?? "Credenciales inválidas."),
                  dismissButton: .default(Text("OK")))
        }
    }
}
// NOTA: Recuerda que CustomTextFieldModifier debe estar accesible.
