// ActionBus.Swift
// https://github.com/kumatt/EventCoordinator
// MARK: - 事件总线，1对多的绑定

import Combine
import Foundation

/// 模块间通用事件的命名空间 ActionCenter
public enum ActionCenter { }

/// 事件的中心处理
@MainActor
public final class ActionBus {
    /// 默认的事件管线（单例）
    /// note：也可自定义 独属于某个模块的ActionBus
    public static let `default` = ActionBus()
    
    /// 事件订阅的信号量集合
    private var subjects: [String: Any] = [:]
    
    /// 初始化方法
    public init() { }
}

// MARK: - send action
public extension ActionBus {
    /// 发送事件
    /// 当前事件存在Reducer订阅时，事件才会发送
    @discardableResult
    func send<Action: Sendable>(_ action: Action, object: Sendable? = nil, file: String = #file, function: String = #function, line: Int = #line) -> Bool {
        
        let key = String(reflecting: Action.self)

        if let subject = subjects[key] as? PassthroughSubject<Action, Never> {
            subject.send(action)
            return true
        }
        return false
    }
}

// MARK: - sink action
public extension ActionBus {
    func publisher<Action: Sendable>(for actionType: Action.Type) -> AnyPublisher<Action, Never> {
        let key = String(reflecting: Action.self)
        if let subject = subjects[key] as? PassthroughSubject<Action, Never> {
            return subject.eraseToAnyPublisher()
        } else {
            let subject = PassthroughSubject<Action, Never>()
            subjects[key] = subject
            return subject.eraseToAnyPublisher()
        }
    }
}
