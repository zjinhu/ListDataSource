# ListDataSource
TableViewDataSource、CollectionViewDataSource数据源封装。

此项目是基于对[DiffableDataSources](https://github.com/ra1028/DiffableDataSources)源码的精读，熟悉了解每一处作用后进行的仿写。
第一个版本仿写未加Differ算法框架，采用的是直接数据源总体的Reload（这个方案不会出错，也没啥所谓的优化性能）。后来自己写Differ算法的时候感觉循环Hash匹配执行效率不高（可在`Diff.swift`这个类看到原始diff思路），因为没有仔细研究**Paul Heckel**的算法（不跟着写一遍完全不知道到底是啥思路）。然后经过多方对比还是那位老兄的[DifferenceKit](https://github.com/ra1028/DifferenceKit) 比较高效。所以又回到了和DiffableDataSources同样的用法上。

我的扩充主要包括TableViewDataSource，CollectionViewDataSource对代理的回调，和对核心数据的处理上。
喜欢原生风格的可以和iOS 13 中 Apple 引入了新的 API Diffable Data Source用法一致（一毛一样），也可以使用封装好的链式编程（省心）。DiffableDataSources主要存在的问题就是有几个代理方法未作处理，需要你自己重写，如果忘了可能会导致崩溃。

DiffableDataSources和API Diffable Data Source的在搭建VC的用法我这里都做了详细的注释并实现了用法（一看就会的那种），不用再到处找资料了（因为是iOS13之后才开始支持的也没啥详细的资料，大家都没开始用呢）。所以：

用法详见Demo。

## 安装
### cocoapods
1.在 Podfile 中添加 pod ‘ListDataSource’
2.执行 pod install 或 pod update
3.导入 import ListDataSource
### Swift Package Manager
从 Xcode 11 开始，集成了 Swift Package Manager，使用起来非常方便。ListDataSource 也支持通过 Swift Package Manager 集成。
在 Xcode 的菜单栏中选择 File > Swift Packages > Add Pacakage Dependency，然后在搜索栏输入
https://github.com/jackiehu/ListDataSource，即可完成集成
### 手动集成
ListDataSource 也支持手动集成，只需把Sources文件夹中的ListDataSource文件夹拖进需要集成的项目即可
## 更多砖块工具加速APP开发

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftBrick&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftBrick)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftMediator&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftMediator)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftShow&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftShow)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftyForm&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftyForm)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftEmptyData&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftEmptyData)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftPageView&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftPageView)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=JHTabBarController&theme=radical&locale=cn)](https://github.com/jackiehu/JHTabBarController)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftMesh&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftMesh)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNotification&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNotification)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNetSwitch&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNetSwitch)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftButton&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftButton)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftDatePicker&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftDatePicker)
