// The Swift Programming Language
// https://docs.swift.org/swift-book

@MainActor
public final class EventCoordinator {
    
    public let actionBus = ActionBus()
    
    public let routeHub = RouterHub()
    
    public init() { }
}
