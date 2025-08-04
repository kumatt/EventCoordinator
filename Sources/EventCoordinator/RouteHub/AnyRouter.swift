//
//  AnyRouter.swift
//  Coordinator
//
//  Created by kumatt on 2025/2/21.
//

/// 普通路由，直接获取目标值
@MainActor
public protocol AnyRouter {
    /// 注册路由
    static func register(context: RouterHub, _ gotoHandle: @escaping (Self) async -> Sendable?) async
    /// 注销路由
    static func unregister(context: RouterHub)
    /// 获取路由值对应的对象
    static func resolve<T: Sendable>(context: RouterHub, _ route: Self) async throws -> T
}

public extension AnyRouter {
    static func register(context: RouterHub, _ gotoHandle: @Sendable @escaping (Self) async -> Sendable?) async where Self: Sendable {
        context.register(gotoHandle)
    }
    
    static func unregister(context: RouterHub) {
        context.unregister(Self.self)
    }
    
    static func resolve<T: Sendable>(context: RouterHub, _ route: Self) async throws -> T where Self: Sendable {
        try await context.resolve(route)
    }
}
