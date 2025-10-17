//
//  EditPasswordView.swift
//  Ejemplo
//
//  Created by Dilson Abrego on 9/15/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import SwiftUI

struct EditPasswordView: View {
    let service: String
    let username: String
    @Environment(\.presentationMode) var presentationMode
    @State private var editedService: String
    @State private var editedUsername: String
    @State private var editedPassword: String = "contraseña123"
    @State private var editedNotes: String = ""
    
    init(service: String, username: String) {
        self.service = service
        self.username = username
        _editedService = State(initialValue: service)
        _editedUsername = State(initialValue: username)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Servicio")) {
                    TextField("Nombre del servicio", text: $editedService)
                    TextField("Usuario/Correo", text: $editedUsername)
                    SecureField("Contraseña", text: $editedPassword)
                }
                
                Section(header: Text("Notas")) {
                    TextField("Notas opcionales", text: $editedNotes)
                }
            }
            .navigationBarTitle("Editar Contraseña", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    self.presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(editedService.isEmpty || editedUsername.isEmpty || editedPassword.isEmpty)
            )
        }
    }
}

struct EditPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EditPasswordView(service: "Gmail", username: "usuario@gmail.com")
    }
}
