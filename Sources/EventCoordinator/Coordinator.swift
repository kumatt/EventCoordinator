// The Swift Programming Language
// https://docs.swift.org/swift-book

@MainActor
public final class Coordinator {
    
    public let actionBus = ActionBus()
    
    public let routeHub =  RouterHub()
    
    public init() { }
}
