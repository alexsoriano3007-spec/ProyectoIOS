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
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ DEBUG - No hay usuario autenticado para fetchPasswords")
            return
        }
        
        print("🔍 DEBUG - Fetching passwords para user: \(userId)")
        
        // Remover listener anterior si existe
        listener?.remove()
        
        listener = db.collection("passwords")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("❌ DEBUG - Error en fetch: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("🔍 DEBUG - No se encontraron documentos")
                    self?.passwords = []
                    return
                }
                
                print("🔍 DEBUG - Se encontraron \(documents.count) documentos")
                
                self?.passwords = documents.compactMap { document in
                    let data = document.data()
                    let passwordItem = PasswordItem(
                        id: document.documentID,
                        service: data["service"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        password: data["password"] as? String ?? "",
                        notes: data["notes"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    print("🔍 DEBUG - Password cargado: \(passwordItem.service)")
                    return passwordItem
                }
                
                print("🔍 DEBUG - passwords array actualizado con \(self?.passwords.count ?? 0) elementos")
            }
    }
    
    func savePassword(service: String, username: String, password: String, notes: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user ID available")
            return
        }
        
        let passwordData: [String: Any] = [
            "service": service,
            "username": username,
            "password": password,
            "notes": notes,
            "userId": userId,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("passwords").addDocument(data: passwordData) { [weak self] error in
            if let error = error {
                print("❌ Error guardando contraseña: \(error)")
            } else {
                print("✅ Contraseña guardada exitosamente para: \(service)")
                // ✅ FORZAR ACTUALIZACIÓN INMEDIATA
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.fetchPasswords()
                }
            }
        }
    }
    
    func deletePassword(_ password: PasswordItem) {
        guard let id = password.id else { return }
        
        db.collection("passwords").document(id).delete { [weak self] error in
            if let error = error {
                print("❌ Error eliminando contraseña: \(error)")
            } else {
                print("✅ Contraseña eliminada: \(password.service)")
                // ✅ FORZAR ACTUALIZACIÓN INMEDIATA
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.fetchPasswords()
                }
            }
        }
    }
    
    // ✅ NUEVA FUNCIÓN: Forzar refresh manual
    func refreshPasswords() {
        fetchPasswords()
    }
}
