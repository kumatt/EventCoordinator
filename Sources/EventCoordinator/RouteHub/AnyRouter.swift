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
    static func register<R>(context: R, _ gotoHandle: @escaping (Self) -> Any?)
    /// 注销路由
    static func unregister<R>(context: R)
    /// 获取路由值对应的对象
    static func resolve<T, R>(context: R, _ route: Self) throws -> T
}

public extension AnyRouter {
    static func register<R>(context: R, _ gotoHandle: @escaping (Self) -> Any?) where R: RouterHub {
        context.register(gotoHandle)
    }
    
    static func unregister<R>(context: R) where R: RouterHub {
        context.unregister(Self.self)
    }
    
    static func resolve<T, R>(context: R, _ route: Self) throws -> T where R: RouterHub {
        try context.resolve(route)
    }
}

public extension AnyRouter {
    /// 注册路由
    static func register<R>(context: R, _ gotoHandle: @escaping (Self) -> Any?) where R: Coordinator {
        context.routeHub.register(gotoHandle)
    }
    /// 注销路由
    static func unregister<R>(context: R) where R: Coordinator {
        context.routeHub.unregister(Self.self)
    }
    /// 获取路由值对应的对象
    static func resolve<T, R>(context: R, _ route: Self) throws -> T where R: Coordinator {
        try context.routeHub.resolve(route)
    }
}
