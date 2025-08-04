//
//  AnyAction.swift
//  Coordinator
//
//  Created by kumatt on 2025/2/21.
//

import Combine

/// 路由遵循的协议，默认实现了注册和获取映射对象的方法
@MainActor
public protocol AnyAction {
    /// 发送事件
    static func send(context: ActionBus, _ action: Self, file: String, function: String, line: Int) async
    /// 响应事件
    static func sink(context: ActionBus, _ receiveValue: @escaping (Self) -> Void) async -> AnyCancellable
}

public extension AnyAction {
    static func send(context: ActionBus, _ action: Self, file: String = #file, function: String = #function, line: Int = #line) async where Self: Sendable {
        await context.send(action, file: file, function: function, line: line)
    }
    
    static func sink(context: ActionBus, _ receiveValue: @Sendable @escaping (Self) -> Void) async -> AnyCancellable where Self: Sendable  {
        context.sink(receiveValue: receiveValue)
    }
}
