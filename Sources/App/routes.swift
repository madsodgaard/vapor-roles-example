import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }
    
    app.grouped(UserRoleMiddleware(through: .parameter("organizationID"), roles: [.admin])).get(":organizationID/admin") { req -> String in
        return "You have access as an admin!"
    }
}

enum OrganizationIDObtainer {
    case parameter(String)
    
    func value(for req: Request) -> UUID? {
        switch self {
        case .parameter(let parameter):
            guard let parameterValue = req.parameters.get(parameter) else {
                return nil
            }
            
            return UUID(uuidString: parameterValue)
        }
    }
}

struct UserRoleMiddleware: Middleware {
    let roles: [Role]
    let obtainer: OrganizationIDObtainer
    
    init(through obtainer: OrganizationIDObtainer, roles: [Role]) {
        self.obtainer = obtainer
        self.roles = roles
    }
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // A better method would being able to supply how to get the org ID through the middleware
        guard let orgID = obtainer.value(for: request) else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Organization ID not found..."))
        }
        
        // in real life app, get the user via. authentication...
        let user = User()
        
        return UserOrganizationRole.query(on: request.db)
            .filter(\.$organization.$id == orgID)
            .filter(\.$user.$id == user.id!)
            .filter(\.$role ~~ roles)
            .first()
            .unwrap(or: Abort(.forbidden, reason: "You do not have access to this..."))
            .flatMap { _ in next.respond(to: request) }
    }
}
