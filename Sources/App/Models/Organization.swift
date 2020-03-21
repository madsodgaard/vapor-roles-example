import Vapor
import Fluent

final class Organization: Model {
    static let schema = "organizations"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() { }
}
