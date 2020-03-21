import Fluent

struct CreateUserOrganizationRole: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_organization_roles")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("organization_id", .uuid, .required, .references("organizations", "id"))
            .field("role", .custom("role"), .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_organization_roles").delete()
    }
}
