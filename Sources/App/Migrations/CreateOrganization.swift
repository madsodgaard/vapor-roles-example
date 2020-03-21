import Fluent

struct CreateOrganization: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("organizations")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("organzations").delete()
    }
}
