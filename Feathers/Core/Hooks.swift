//
//  Hooks.swift
//  Feathers
//
//  Created by Brendan Conron on 5/13/17.
//  Copyright © 2017 Swoopy Studios. All rights reserved.
//

import Foundation

/// Hook object that gets passed through hook functions
public struct HookObject {

    /// Represents the kind of hook.
    ///
    /// - before: Hook is run before the request is made.
    /// - after: Hook is run after the request is made.
    /// - error: Runs when there's an error.
    public enum Kind {
        case before, after, error
    }

    /// The kind of hook.
    public let type: Kind

    /// Feathers application, used to retrieve other services.
    public let app: Feathers

    /// The service this hook currently runs on.
    public let service: Service

    /// The service method.
    public let method: Service.Method

    /// The service method parameters.
    public var parameters: [String: Any]?

    /// The request data.
    public var data: [String: Any]?

    /// The id (for get, remove, update and patch).
    public var id: String?

    /// Error that can be set which will stop the hook processing chain and run a special chain of error hooks.
    public var error: Error?

    /// Result of a successful method call, only in after hooks.
    public var result: Response?

    public init(
        type: Kind,
        app: Feathers,
        service: Service,
        method: Service.Method) {
        self.type = type
        self.app = app
        self.service = service
        self.method = method
    }

}

public extension HookObject {

    /// Modify the hook object by adding a result.
    ///
    /// - Parameter result: Result to add.
    /// - Returns: Modified hook object.
    public func objectByAdding(result: Response) -> HookObject {
        var object = self
        object.result = result
        return object
    }

    /// Modify the hook object by attaching an error.
    ///
    /// - Parameter error: Error to attach.
    /// - Returns: Modified hook object.
    public func objectByAdding(error: Error) -> HookObject {
        var object = self
        object.error = error
        return object
    }

    /// Create a new hook object with a new type.
    ///
    /// - Parameter type: New type.
    /// - Returns: A new hook object with copied over properties.
    func object(with type: Kind) -> HookObject {
        var object = HookObject(type: type, app: app, service: service, method: method)
        object.parameters = parameters
        object.data = data
        object.id = id
        object.error = error
        object.result = result
        return object
    }

}

public typealias HookNext = (HookObject) -> ()

/// Hook protocol.
public protocol Hook {

    /// Function that's called by the middleware system to run the hook.
    ///
    /// In order to modify the hook, a copy of it has to be made because
    /// Swift function parameters are `let` by default. If `next` is not called,
    /// unexpected behavior will happen as the hook system will never finish processing the
    /// rest of the chain.
    ///
    /// - Warning: `next` *MUST* be called.
    /// - Parameters:
    ///   - hookObject: Hook object.
    ///   - next: Next function.
    func run(with hookObject: HookObject, _ next: @escaping (HookObject) -> ())
}