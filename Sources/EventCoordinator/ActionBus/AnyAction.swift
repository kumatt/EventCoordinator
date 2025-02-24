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
    static func send(context: ActionBus, _ action: Self, object: Any?, file: String, function: String, line: Int)
    /// 响应事件
    static func sink(context: ActionBus, _ receiveValue: @escaping (Self) -> Void) -> AnyCancellable
    /// 响应事件
    static func sink(context: ActionBus, _ receiveValue: @escaping (Self, Any?) -> Void) -> AnyCancellable
}

public extension AnyAction {
    static func send(context: ActionBus, _ action: Self, object: Any? = nil, file: String = #file, function: String = #function, line: Int = #line) where Self: Sendable {
        context.send(action, object: object, file: file, function: function, line: line)
    }
    
    static func sink(context: ActionBus, _ receiveValue: @escaping (Self) -> Void) -> AnyCancellable where Self: Sendable  {
        context.sink(receiveValue: receiveValue)
    }
    
    static func sink(context: ActionBus, _ receiveValue: @escaping (Self, Any?) -> Void) -> AnyCancellable where Self: Sendable  {
        context.sink(receiveValue: receiveValue)
    }
}
