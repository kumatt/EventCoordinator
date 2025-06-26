// RouterHub.Swift
// https://github.com/kumatt/EventCoordinator
// RouterHub is a lightweight routing tool designed for inter-module communication and navigation in modular Swift applications. It aims to decouple dependencies between modules, enhancing the scalability and maintainability of projects. By enabling route registration, path mapping, and dynamic parameter passing, it provides an efficient and intuitive approach to modular development.
// MARK: - 路由集线器，1对1的绑定

import Foundation

/// 路由的命名空间 RouterNavigator
public enum RouterNavigator { }

/// 路由集线器
@MainActor
public final class RouterHub {
    
    public static let `default` = RouterHub()
    /// 路由映射，返回goto的对象
    /// Note: 所有访问都必须在主线程进行，由 @MainActor 保证线程安全
    private var gotoMappings: [ObjectIdentifier: any AnyReducer] = [:]
    
    /// 初始化方法
    public init() { }
}

// MARK: - Direct goto
extension RouterHub {
    /// 注册路由，绑定和重定向
    /// 将路由与对应的目标（页面、控制器、回调等）绑定。
    /// - Parameter gotoHandles: 路由响应
    func register<R>(_ gotoHandles: @escaping (R) -> Any?) {
        gotoMappings[ObjectIdentifier(R.self)] = Reducer(block: gotoHandles)
    }
    
    /// 获取目标对象
    /// - Parameter rawValue: 类型
    /// - Returns: 指定类型的返回值
    func resolve<R, T>(_ route: R) throws -> T {
        guard let reducer = gotoMappings[ObjectIdentifier(R.self)] as? RouterHub.Reducer<R> else {
            throw Reason.unRegisterEnumType
        }
        guard let value = reducer(route) else {
            throw Reason.rawMaterialUnqualified
        }
        guard let result = value as? T else {
            throw Reason.valueTypeConversionError
        }
        return result
    }
}

// MARK: - unregister
extension RouterHub {
    /// 注销路由
    /// - Parameter type: 数据类型
    func unregister<R>(_ type: R.Type) {
        gotoMappings[ObjectIdentifier(type)] = nil
    }
}

// MARK: - RouterHub.Reason
extension RouterHub {
    /// 失败原因
    public enum Reason: Error {
        /// 类型没有注册
        case unRegisterEnumType
        /// 值未做处理
        case rawMaterialUnqualified
        /// 值的类型不是指定返回类型
        case valueTypeConversionError
    }
}

// MARK: - RouterHub.DirectReducer
extension RouterHub {
    struct Reducer<R>: AnyReducer {
        
        let block: (R) -> Any?
        
        @inline(__always)
        init(block: @escaping (R) -> Any?) {
            self.block = block
        }
        
        @inline(__always)
        func callAsFunction(_ rawValue: R) -> Any? {
            block(rawValue)
        }
    }
}
