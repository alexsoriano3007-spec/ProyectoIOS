import Foundation

struct PasswordItem: Identifiable, Codable {
    var id: String? = nil
    let service: String
    let username: String
    let password: String
    let notes: String
    let userEmail: String // ✅ CAMBIO: userEmail en lugar de userId
    let userId: String    // ✅ Mantener por compatibilidad
    let createdAt: Date
    
    // Inicializador principal
    init(service: String, username: String, password: String, notes: String, userEmail: String) {
        self.service = service
        self.username = username
        self.password = password
        self.notes = notes
        self.userEmail = userEmail
        self.userId = "" // Temporal
        self.createdAt = Date()
    }
    
    // Inicializador completo para Firestore
    init(id: String?, service: String, username: String, password: String, notes: String, userEmail: String, userId: String, createdAt: Date) {
        self.id = id
        self.service = service
        self.username = username
        self.password = password
        self.notes = notes
        self.userEmail = userEmail // ✅ CAMBIO
        self.userId = userId
        self.createdAt = createdAt
    }
}
