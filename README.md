# EventCoordinator

EventCoordinator 是一个轻量级的 Swift 事件总线和路由调度工具，专为 iOS 应用模块化开发设计。它提供了两个核心功能模块：

- **ActionBus** - 实现模块间的 1对多 事件通信
- **RouterHub** - 轻量级路由器，用于处理 1对1 的模块间导航

## 特性

- ✨ 轻量级自定义事件订阅机制
- 🔄 支持同步/异步路由
- 🎯 类型安全的API设计
- 🛡️ 线程安全（所有操作都在主线程执行）
- 🎨 简洁优雅的链式调用
- 💡 简单易用的API

## 设计思路

### ActionBus 设计

ActionBus 采用发布-订阅模式，主要包含以下核心组件：

1. `AnyAction` 协议：定义事件的基本行为
   - `send`: 发送事件
   - `publisher`: 订阅事件

2. `ActionBus` 类：
   - 使用 `[ObjectIdentifier: PassthroughSubject]` 管理事件订阅关系
   - 确保线程安全（@MainActor）
   - 基于 Combine 框架实现响应式编程
   - 支持类型安全的事件传递

### RouterHub 设计

RouterHub 采用类型映射模式，包含以下核心组件：

1. `AnyRouter` 协议：定义路由的基本行为
2. `RouterHub` 类：路由注册和解析中心
3. `AnyReducer` 协议：路由处理器的类型擦除

## 安装

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/kumatt/EventCoordinator.git", from: "1.0.0")
]
```

## 使用示例

### ActionBus 使用示例

#### 1. 定义事件：

```swift
import EventCoordinator

// 用户相关事件
enum UserAction: Sendable {
    case login(userId: String)
    case logout
    case profileUpdated(user: User)
}

// 购物车相关事件
enum CartAction: Sendable {
    case itemAdded(product: Product)
    case itemRemoved(productId: String)
    case checkout
}
```

#### 2. 订阅事件：

```swift
let coordinator = EventCoordinator()

// 在用户模块中订阅用户事件
coordinator.actionBus.publisher(for: UserAction.self)
    .sink { action in
        switch action {
        case .login(let userId):
            print("用户登录: \(userId)")
        case .logout:
            print("用户登出")
        case .profileUpdated(let user):
            print("用户信息更新: \(user)")
        }
    }
    .store(in: &cancellables)

// 在购物车模块中订阅购物车事件
coordinator.actionBus.publisher(for: CartAction.self)
    .sink { action in
        switch action {
        case .itemAdded(let product):
            print("商品添加到购物车: \(product)")
        case .itemRemoved(let productId):
            print("商品从购物车移除: \(productId)")
        case .checkout:
            print("开始结账")
        }
    }
    .store(in: &cancellables)
```

#### 3. 发送事件：

```swift
// 发送登录事件
let result = coordinator.actionBus.send(UserAction.login(userId: "123"))
if result {
    print("事件发送成功")
} else {
    print("没有订阅者")
}

// 发送购物车事件
coordinator.actionBus.send(CartAction.itemAdded(product: Product(id: "1", name: "商品")))
```

### RouterHub 使用示例

#### 1. 定义路由：

```swift
// 页面路由
enum PageRoute: Sendable {
    case home
    case productDetail(productId: String)
    case userProfile(userId: String)
    case checkout
}

// 功能路由
enum FeatureRoute: Sendable {
    case share(content: String)
    case openSettings
    case showAlert(message: String)
}
```

#### 2. 注册路由：

```swift
// 注册页面路由
await coordinator.routeHub.register { (route: PageRoute) async -> UIViewController? in
    switch route {
    case .home:
        return HomeViewController()
    case .productDetail(let productId):
        return ProductDetailViewController(productId: productId)
    case .userProfile(let userId):
        return UserProfileViewController(userId: userId)
    case .checkout:
        return CheckoutViewController()
    }
}

// 注册功能路由
await coordinator.routeHub.register { (route: FeatureRoute) async -> Bool? in
    switch route {
    case .share(let content):
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        // 显示分享界面
        return true
    case .openSettings:
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        return true
    case .showAlert(let message):
        // 显示警告
        return true
    }
}
```

#### 3. 使用路由：

```swift
// 导航到产品详情页
do {
    let viewController = try await coordinator.routeHub.resolve(PageRoute.productDetail(productId: "123"))
    navigationController.pushViewController(viewController, animated: true)
} catch {
    print("路由错误: \(error)")
}

// 执行分享功能
do {
    let _: Bool = try await coordinator.routeHub.resolve(FeatureRoute.share(content: "分享内容"))
} catch {
    print("功能执行错误: \(error)")
}
```

## 最佳实践

### 1. 职责分离

- **ActionBus**: 用于状态变化通知、数据同步等广播场景
- **RouterHub**: 用于页面跳转、功能调用等定向场景

### 2. 错误处理

```swift
// ActionBus 错误处理
let result = coordinator.actionBus.send(UserAction.login(userId: "123"))
if !result {
    print("警告：没有订阅者监听此事件")
}

// RouterHub 错误处理
do {
    let result: UIViewController = try await coordinator.routeHub.resolve(PageRoute.home)
} catch RouterHub.Reason.unRegisterEnumType {
    print("路由未注册")
} catch RouterHub.Reason.rawMaterialUnqualified {
    print("路由处理失败")
} catch RouterHub.Reason.valueTypeConversionError {
    print("类型转换失败")
} catch {
    print("未知错误: \(error)")
}
```

### 3. 性能优化

1. **避免过度订阅**: 及时取消不需要的订阅
2. **路由懒加载**: 在需要时才注册路由
3. **事件过滤**: 使用 Combine 的 `filter` 操作符过滤不需要的事件
4. **类型安全**: 充分利用 Swift 的类型系统，避免运行时错误

## 架构优势

- **解耦**: 模块间通过事件和路由通信，降低耦合度
- **可扩展**: 易于添加新的事件类型和路由
- **类型安全**: 编译时检查，减少运行时错误
- **高性能**: 使用 ObjectIdentifier 进行类型映射，提高查找效率
- **简洁**: API 设计简洁，易于理解和使用

## 许可证

MIT License 