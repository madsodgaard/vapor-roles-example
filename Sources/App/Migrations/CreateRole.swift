import Fluent

struct CreateRole: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.enum("role")
            .case("admin")
            .case("moderator")
            .create()
            .transform(to: ())
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.enum("role").delete()
    }
}
