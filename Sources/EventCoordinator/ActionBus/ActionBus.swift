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
    /// 目标对象
    public typealias Object = Any

    /// 默认的事件管线（单例）
    /// note：也可自定义 独属于某个模块的ActionBus
    public static let `default` = ActionBus()
    
    /// 事件的订阅
    private var actionCancellables: [String: Set<Reducer>] = [:]
    
    public var cancellables = Set<AnyCancellable>()
    
    /// 初始化方法
    public init() { }
}

// MARK: - send action
public extension ActionBus {
    /// 发送事件
    /// 当前事件存在Reducer订阅时，事件才会发送
    @discardableResult
    func send<Action: Sendable>(_ action: Action, object: Sendable? = nil, file: String = #file, function: String = #function, line: Int = #line) async -> Bool {
        
        /// 记录事件为verbose，debug环境下
//        Log.log(action, level: .verbose, file: file, function: function, line: line)

        
        guard let reducers = actionCancellables[String(reflecting: Action.self)],
            !reducers.isEmpty else {
            return false
        }
        for reducer in reducers {
            await reducer(action)
        }
        return true
    }
}

// MARK: - sink action
public extension ActionBus {

    /// 处理事件
    /// - Parameter receiveValue: 事件的回调
    /// - Returns: 订阅的生命周期
    func sink<Action: Sendable>(receiveValue:@Sendable @escaping (Action) -> Void) -> AnyCancellable {
        sink(with: Action.self, reducer: Reducer({ value in
            guard let action = value as? Action else { return }
            receiveValue(action)
        }))
    }
}

// MARK: - sink的最终实现
private extension ActionBus {
    /// 处理事件
    /// 订阅某个事件，进行响应
    private func sink<Action: Sendable>(with actionType: Action.Type, reducer: Reducer) -> AnyCancellable {
        let hashable = String(reflecting: actionType)
        var reducers = actionCancellables[hashable] ?? Set()
        reducers.insert(reducer)
        actionCancellables[hashable] = reducers
        /// AnyCancellable被释放时，移除监听
        return AnyCancellable {[weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                var reducers = self.actionCancellables[hashable]
                reducers?.remove(reducer)
                self.actionCancellables[hashable] = reducers
            }
        }
    }
}

// MARK: - 事件监听的封装
extension ActionBus {
    struct Reducer: Sendable {
        /// hash tag
        private let id = UUID()
        /// do anything
        let block: @Sendable (Sendable) async -> Void
        
        @inline(__always)
        init(_ block: @Sendable @escaping (Sendable) async -> Void) {
            self.block = block
        }
        
        @inline(__always)
        func callAsFunction(_ action: Sendable) async {
            await block(action)
        }
    }
}

// MARK: - Reducer is Hashable
extension ActionBus.Reducer: Hashable {
    // 实现 Hashable 协议
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
