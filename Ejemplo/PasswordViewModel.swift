import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class PasswordViewModel: ObservableObject {
    @Published var passwords: [PasswordItem] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func fetchPasswords() {
        guard let user = Auth.auth().currentUser else {
            print("❌ DEBUG - No hay usuario autenticado")
            return
        }
        
        let userUID = user.uid
        let userEmail = user.email ?? "sin-email"
        
        print("🔍 DEBUG === INICIANDO FETCH ===")
        print("🔍 DEBUG - Email del usuario: \(userEmail)")
        print("🔍 DEBUG - UID del usuario: \(userUID)")
        
        // DEBUG TEMPORAL: Mostrar TODOS los documentos sin filtrar
        db.collection("passwords").getDocuments { snapshot, error in
            if let error = error {
                print("❌ DEBUG - Error al obtener todos los documentos: \(error)")
                return
            }
            
            if let documents = snapshot?.documents {
                print("🔍 DEBUG - TOTAL documentos en BD: \(documents.count)")
                if documents.count == 0 {
                    print("🔍 DEBUG - ⚠️ LA BASE DE DATOS ESTÁ VACÍA")
                } else {
                    print("🔍 DEBUG - 📊 CONTENIDO DE LA BASE DE DATOS:")
                    for doc in documents {
                        let data = doc.data()
                        let docEmail = data["userEmail"] as? String ?? "NO_EMAIL"
                        let docService = data["service"] as? String ?? "NO_SERVICE"
                        let docUserID = data["userId"] as? String ?? "NO_UID"
                        print("🔍 DEBUG - 📄 \(docService) | Email: \(docEmail) | UID: \(docUserID.prefix(8))...")
                    }
                }
            }
        }
        
        // Remover listener anterior si existe
        listener?.remove()
        
        print("🔍 DEBUG - 🔍 Buscando documentos con filtro: userId = \(userUID)")
        
        // CONSULTA CORREGIDA: Usar userId en lugar de userEmail
        listener = db.collection("passwords")
            .whereField("userId", isEqualTo: userUID) // ← CAMBIO CLAVE AQUÍ
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("❌ DEBUG - Error en fetch filtrado: \(error.localizedDescription)")
                    
                    // Si hay error de índice, intentar consulta alternativa
                    if error.localizedDescription.contains("index") {
                        print("🔍 DEBUG - ⚠️ Índice en construcción, usando consulta alternativa...")
                        self?.fetchPasswordsAlternative()
                    }
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("🔍 DEBUG - ❌ No se encontraron documentos para userId: \(userUID)")
                    self?.passwords = []
                    return
                }
                
                print("🔍 DEBUG - ✅ Documentos ENCONTRADOS con filtro: \(documents.count)")
                
                if documents.count == 0 {
                    print("🔍 DEBUG - ⚠️ NO HAY DOCUMENTOS CON EL USER_ID: \(userUID)")
                    print("🔍 DEBUG - 💡 Posibles soluciones:")
                    print("🔍 DEBUG -   1. Crear nueva contraseña desde la app")
                    print("🔍 DEBUG -   2. Verificar que userId coincida en los documentos")
                }
                
                self?.passwords = documents.compactMap { document in
                    let data = document.data()
                    let passwordItem = PasswordItem(
                        id: document.documentID,
                        service: data["service"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        password: data["password"] as? String ?? "",
                        notes: data["notes"] as? String ?? "",
                        userEmail: data["userEmail"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    print("🔍 DEBUG - 🎯 Password cargado: \(passwordItem.service)")
                    return passwordItem
                }
                
                print("🔍 DEBUG - 📱 passwords array actualizado con \(self?.passwords.count ?? 0) elementos")
                
                // Debug final del array
                if let passwords = self?.passwords, !passwords.isEmpty {
                    print("🔍 DEBUG - 🎉 CONTRASEÑAS CARGADAS EN LA APP:")
                    for (index, password) in passwords.enumerated() {
                        print("🔍 DEBUG -   \(index + 1). \(password.service) - \(password.username)")
                    }
                } else {
                    print("🔍 DEBUG - 😞 ARRAY DE CONTRASEÑAS VACÍO")
                }
            }
    }
    
    // CONSULTA ALTERNATIVA para cuando el índice está en construcción
    private func fetchPasswordsAlternative() {
        guard let user = Auth.auth().currentUser else { return }
        let userUID = user.uid
        
        print("🔍 DEBUG - 🔄 Usando consulta alternativa...")
        
        db.collection("passwords").getDocuments { [weak self] snapshot, error in
            if let documents = snapshot?.documents {
                // Filtrar manualmente en el cliente
                let filteredDocs = documents.filter { doc in
                    let docUserId = doc.data()["userId"] as? String
                    return docUserId == userUID
                }
                
                print("🔍 DEBUG - ✅ Documentos filtrados manualmente: \(filteredDocs.count)")
                
                self?.passwords = filteredDocs.compactMap { document in
                    let data = document.data()
                    return PasswordItem(
                        id: document.documentID,
                        service: data["service"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        password: data["password"] as? String ?? "",
                        notes: data["notes"] as? String ?? "",
                        userEmail: data["userEmail"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            }
        }
    }
    
    func savePassword(service: String, username: String, password: String, notes: String) {
        guard let user = Auth.auth().currentUser else {
            print("❌ No user logged in")
            return
        }
        
        let userUID = user.uid
        let userEmail = user.email ?? "sin-email"
        
        print("🔍 DEBUG - 💾 Guardando contraseña para userId: \(userUID)")
        
        let passwordData: [String: Any] = [
            "service": service,
            "username": username,
            "password": password,
            "notes": notes,
            "userEmail": userEmail,
            "userId": userUID, // ← SIEMPRE usar el UID correcto
            "createdAt": Timestamp(date: Date())
        ]
        
        print("🔍 DEBUG - 📊 Datos a guardar:")
        print("🔍 DEBUG -   Service: \(service)")
        print("🔍 DEBUG -   Username: \(username)")
        print("🔍 DEBUG -   Password: \(password)")
        print("🔍 DEBUG -   Notes: \(notes)")
        print("🔍 DEBUG -   userEmail: \(userEmail)")
        print("🔍 DEBUG -   userId: \(userUID)")
        
        db.collection("passwords").addDocument(data: passwordData) { [weak self] error in
            if let error = error {
                print("❌ Error guardando contraseña: \(error)")
            } else {
                print("✅ Contraseña guardada exitosamente para: \(service)")
                print("✅ userId asociado: \(userUID)")
                
                // FORZAR ACTUALIZACIÓN INMEDIATA
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("🔍 DEBUG - 🔄 Ejecutando refresh después de guardar...")
                    self?.fetchPasswords()
                }
            }
        }
    }
    
    func deletePassword(_ password: PasswordItem) {
        guard let id = password.id else { return }
        
        print("🔍 DEBUG - 🗑️ Eliminando contraseña: \(password.service)")
        
        db.collection("passwords").document(id).delete { [weak self] error in
            if let error = error {
                print("❌ Error eliminando contraseña: \(error)")
            } else {
                print("✅ Contraseña eliminada: \(password.service)")
                
                // FORZAR ACTUALIZACIÓN INMEDIATA
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.fetchPasswords()
                }
            }
        }
    }
    
    // FUNCIÓN: Forzar refresh manual
    func refreshPasswords() {
        print("🔍 DEBUG - 🔄 Refresh manual solicitado")
        fetchPasswords()
    }
    
    // FUNCIÓN: Borrar TODAS las contraseñas (solo para desarrollo)
    func deleteAllPasswords() {
        print("🔍 DEBUG - 🗑️ ELIMINANDO TODAS LAS CONTRASEÑAS")
        
        db.collection("passwords").getDocuments { [weak self] snapshot, error in
            if let documents = snapshot?.documents {
                print("🔍 DEBUG - 📝 Documentos a eliminar: \(documents.count)")
                
                for document in documents {
                    document.reference.delete()
                }
                
                print("🔍 DEBUG - ✅ Todos los documentos eliminados")
                
                // Recargar después de eliminar
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchPasswords()
                }
            }
        }
    }
}
