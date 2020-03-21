import Vapor
import Fluent

final class UserOrganizationRole: Model {
    static let schema = "user_organization_roles"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "organization_id")
    var organization: Organization
    
    @Enum(key: "role")
    var role: Role
    
    init() { }
}
