import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }
    
    app.grouped(UserRoleMiddleware(roles: [.admin])).get(":organizationID/admin") { req -> String in
        return "You have access as an admin!"
    }
}

struct UserRoleMiddleware: Middleware {
    let roles: [Role]
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // A better method would being able to supply how to get the org ID through the middleware
        let orgID = UUID(uuidString: request.parameters.get("organizationID")!)!
        
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
