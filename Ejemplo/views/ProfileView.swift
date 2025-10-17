import SwiftUI

struct PasswordDetailView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Servicio: Gmail")
                .font(.title)
            Text("Usuario: usuario@example.com")
            Text("Contraseña: ********")
            Text("Notas: Aquí puedes poner información extra.")
            
            Spacer()
            
            NavigationLink(destination: EditPasswordView()) {
                Text("Editar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationBarTitle("Detalle", displayMode: .inline) // ← así es correcto para iOS 13
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProfileView()
    }
}
