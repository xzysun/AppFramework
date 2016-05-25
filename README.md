# AppFramework
An empty iPhone app framework


提供基本的应用框架内容
* 包含ViewControllers，CustomViews，Services，Models，Utils，Libs目录
* Model层使用Mantle提供序列化支持
* 提供了一个网络请求类，封装了AFNetwork
* 提供了一个简单崩溃异常栈捕获机制（复杂需求建议可以使用BugHUB）
* 提供了ZBar扫码和QRCode生成的类库
* 提供了一个KeyChain的帮助类
* 提供了一个越狱检测的工具类
* 提供了APNS注册的相关代码，如不需要请注释掉
* 设备唯一标识使用IDFA，如果不想使用请自行替换AppService类中的相关方法
