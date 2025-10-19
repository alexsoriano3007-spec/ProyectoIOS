import Foundation

struct PasswordItem: Identifiable, Codable {
    var id: String? = nil
    let service: String
    let username: String
    let password: String
    let notes: String
    let userId: String
    let createdAt: Date
    
    // Inicializador principal
    init(service: String, username: String, password: String, notes: String, userId: String) {
        self.service = service
        self.username = username
        self.password = password
        self.notes = notes
        self.userId = userId
        self.createdAt = Date()
    }
    
    // ✅ AÑADIDO: Inicializador completo para Firestore
    init(id: String?, service: String, username: String, password: String, notes: String, userId: String, createdAt: Date) {
        self.id = id
        self.service = service
        self.username = username
        self.password = password
        self.notes = notes
        self.userId = userId
        self.createdAt = createdAt
    }
}
