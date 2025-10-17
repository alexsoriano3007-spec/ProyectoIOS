//
//  AddPasswordView.swift
//  Ejemplo
//
//  Created by Dilson Abrego on 9/15/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import SwiftUI

struct AddPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var service = ""
    @State private var username = ""
    @State private var password = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Servicio")) {
                    TextField("Nombre del servicio", text: $service)
                    TextField("Usuario/Correo", text: $username)
                    SecureField("Contraseña", text: $password)
                }
                
                Section(header: Text("Notas")) {
                    TextField("Notas opcionales", text: $notes)
                }
            }
            .navigationBarTitle("Agregar Contraseña", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    self.presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(service.isEmpty || username.isEmpty || password.isEmpty)
            )
        }
    }
}

struct AddPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AddPasswordView()
    }
}
