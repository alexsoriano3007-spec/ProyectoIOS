import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    // Variable para manejar la presentación de la vista (soluciona el error de @Environment)
    // NOTA: Esta variable debe ser pasada desde la vista anterior (LoginView).
    @Binding var isShowingRegisterView: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    // Función de registro de Firebase Auth
    func register() {
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            showAlert = true
            return
        }
        
        // Llamada a la API de Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                print("Usuario registrado exitosamente: \(result?.user.uid ?? "N/A")")
                // Vuelve a la pantalla de Login usando la variable de Binding
                self.isShowingRegisterView = false
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Crear Nueva Cuenta")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(Color.blue)
            
            // Sección de Campos de Texto
            VStack(spacing: 15) {
                TextField("Correo electrónico", text: $email)
                    .modifier(CustomTextFieldModifier())
                
                SecureField("Contraseña", text: $password)
                    .modifier(CustomTextFieldModifier())
                
                SecureField("Confirmar Contraseña", text: $confirmPassword)
                    .modifier(CustomTextFieldModifier())
            }
            
            // Botón de Registro
            Button(action: register) {
                Text("Registrarse")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            
            Spacer()
        }
        .padding(30)
        // SOLUCIÓN para navigationTitle y navigationBarTitleDisplayMode (usamos el modificador antiguo)
        .navigationBarTitle(Text("Registro"), displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error de Registro"), message: Text(errorMessage ?? "Ocurrió un error desconocido."), dismissButton: .default(Text("OK")))
        }
    }
}

// Modificador para el estilo del TextField (Mantener igual)
struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
    }
}
