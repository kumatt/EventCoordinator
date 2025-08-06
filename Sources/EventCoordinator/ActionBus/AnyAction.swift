//
//  AnyAction.swift
//  Coordinator
//
//  Created by kumatt on 2025/2/21.
//

import Combine

/// 路由遵循的协议，默认实现了注册和获取映射对象的方法
@MainActor
public protocol AnyAction: Sendable {
    /// 发送事件
    static func send(context: ActionBus, _ action: Self, file: String, function: String, line: Int)
    /// 发布事件
    static func publisher(context: ActionBus) -> AnyPublisher<Self, Never>
}

public extension AnyAction {
    static func send(context: ActionBus, _ action: Self, file: String = #file, function: String = #function, line: Int = #line) {
        context.send(action, file: file, function: function, line: line)
    }
    
    static func publisher(context: ActionBus) -> AnyPublisher<Self, Never> {
        context.publisher(for: Self.self)
    }
}
