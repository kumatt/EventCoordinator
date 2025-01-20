//
//  Reducer.swift

import Foundation

/// AnyReducer协议，用于对RouterHub.Reducer进行类型擦除
protocol AnyReducer {
    associatedtype R
}
