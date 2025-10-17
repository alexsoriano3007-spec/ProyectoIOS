//
//  SettingsView.swift
//  Ejemplo
//
//  Created by Dilson Abrego on 9/15/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import SwiftUI


struct SettingsView: View {
    @State private var useBiometrics = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Seguridad")) {
                    Toggle("Usar FaceID/TouchID", isOn: $useBiometrics)
                    
                    NavigationLink(destination: ChangeMasterPasswordView()) {
                        Text("Cambiar contraseña maestra")
                    }
                }
                
                Section(header: Text("Datos")) {
                    Button("Exportar datos") {
                        // Exportar
                    }
                    
                    Button("Importar datos") {
                        // Importar
                    }
                }
                
                Section(header: Text("Información")) {
                    NavigationLink(destination: SecurityPolicyView()) {
                        Text("Políticas de seguridad")
                    }
                }
            }
            .navigationBarTitle("Ajustes", displayMode: .inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
