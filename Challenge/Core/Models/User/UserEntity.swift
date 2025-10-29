import Foundation

// MARK: - User Entity
struct UserEntity: Codable, Equatable, Hashable {
    let gender: String
    let name: NameEntity
    let location: LocationEntity
    let email: String
    let login: LoginEntity
    let dob: DateOfBirthEntity
    let registered: DateOfBirthEntity
    let phone: String
    let cell: String
    let id: IDEntity
    let picture: PictureEntity
    let nat: String
    
    // MARK: - Computed Properties
    var fullName: String {
        return "\(name.title) \(name.first) \(name.last)"
    }
    
    var fullAddress: String {
        return "\(location.street.number) \(location.street.name), \(location.city), \(location.state), \(location.country), \(location.postcode)"
    }
    
    var age: Int {
        return dob.age
    }
    
    // Unique identifier for the user (using a combination of fields)
    var uniqueID: String {
        return "\(email)_\(login.username)"
    }
    
    static func == (lhs: UserEntity, rhs: UserEntity) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueID)
    }
}
