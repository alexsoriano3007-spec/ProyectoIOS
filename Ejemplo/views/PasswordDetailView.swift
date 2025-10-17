//
//  PasswordDetailView.swift
//  Ejemplo
//
//  Created by Dilson Abrego on 9/15/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import SwiftUI

import LocalAuthentication

struct PasswordDetailView: View {
    let service: String
    let username: String
    @State private var showPassword = false
    @State private var showEdit = false
    
    var body: some View {
        Form {
            Section(header: Text("Información")) {
                HStack {
                    Text("Servicio")
                    Spacer()
                    Text(service)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Usuario")
                    Spacer()
                    Text(username)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Contraseña")
                    Spacer()
                    if showPassword {
                        Text("contraseña123") // Ejemplo temporal
                            .foregroundColor(.gray)
                    } else {
                        Text("••••••••")
                            .foregroundColor(.gray)
                    }
                    Button(action: togglePasswordVisibility) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                    }
                }
            }
            
            Section {
                Button("Editar") {
                    self.showEdit = true
                }
                
                Button("Eliminar") {
                    // Eliminar
                }
                .foregroundColor(.red)
            }
        }
        .navigationBarTitle("Detalles", displayMode: .inline)
        .sheet(isPresented: $showEdit) {
            EditPasswordView(service: self.service, username: self.username)
        }
    }
    
    func togglePasswordVisibility() {
        authenticateForPassword()
    }
    
    func authenticateForPassword() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Autentícate para ver la contraseña"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.showPassword.toggle()
                    }
                }
            }
        }
    }
}


struct PasswordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Proporcionamos valores de ejemplo para service y username
        NavigationView {
            PasswordDetailView(
                service: "Gmail",  // ← Valor de ejemplo para service
                username: "usuario@gmail.com"  // ← Valor de ejemplo para username
            )
        }
    }
}
