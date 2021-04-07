#  (2021-04-07)


### Bug Fixes

* 修改头文件导入 ([2f759f1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2f759f150916bb99857ecee0affc28818f132c6c))


### Features

* 3.1.0正式版本发布 ([69bf27e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/69bf27ecf0f64b33dbdcd6a410146480aa4f2925))



# [3.1.0-beta](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.0.2...3.1.0-beta) (2021-04-06)


### Bug Fixes

* 添加队列出队，防止mobiledebugger无事件时队列数据无法读取 ([f7ddd92](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f7ddd92f1aec49635fdaf413401d60f11dc20898))
* 修改事件缓存机制，适配冷启动情况 ([a42ba83](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a42ba83b8f95d01fec307c389a58e6b0d76e055e))
* 修改网络配置去除多余代码，url路径使用属性 ([d821b6d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d821b6d362ce9b364d54bb1acda01428aadfbab2))
* log Level capitalization ([391d87d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/391d87d45ab8502696458a70929b50861e48f0eb))
* mobiledebugger ([daadd83](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/daadd830e4e68f62008eb8ca964b0dec41470be3))
* test: updata testcase ([25b586c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/25b586cf02b6b468c7cdd5ad99714f76da0eb92a))


### Features

* 防止数组遍历时增删操作，发布3.1.0-beta版本 ([2e7e70b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2e7e70bf8cc91645abc8bc7014a7ea006572f524))
* add mobiledebugger & mobileloggeradd ([6834cd4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6834cd458a4c6592298f9f7dc7fe4e2725361117))



## [3.0.2](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.0.1...3.0.2) (2021-02-19)


### Bug Fixes

* 添加数组插入nil判断，以及NSData数据解析保护 ([a958bf0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a958bf046da1f3aa992fd8e79512b4e736cef10a))
* v3.0.2 ([ed529dc](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ed529dc234e1ba4b90238e419834a1ad90fb1bf9))



## [3.0.1](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.0.1-beta...3.0.1) (2021-02-03)


### Bug Fixes

* 去掉xcodebuild test的os版本依赖,修改ThreadTest ([38510c4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/38510c4937b615f66e83167b4b808223268e19bd))
* 修复多线程下对数组读写不安全的问题 ([ebbeff7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ebbeff7f7e05e11a5bc3aaac4488258fe1a8e34d))
* statubar Mananger移至TrackerCore ([370c759](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/370c759ac7496794efbec27f8bdfccaa8129ede3))



## [3.0.1-beta](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.0.0...3.0.1-beta) (2020-12-31)


### Bug Fixes

* 去除demo的UIScene使用，适配demo的UIAlertView，修复get方法中的问题 ([5dc22ce](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/5dc22ce86f157d79ea7d6ab989e9064a1a94cbdf))
* 删除无用类 ([71a0401](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/71a0401c0946f34e6df9b1631c1f2309e447eca6))
* 修改现版本为beta版本 ([e6f3600](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/e6f360094de5c924b1fa8337da1b185c942a547d))
* 修改Event发送线程为自定义线程，创建常驻线程 ([1bb57be](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1bb57be1a3fd89eab2ce985d7bd26ac149202cc8))


### Features

* 修复iOS13上状态栏无法点击的bug ([6fb19c1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6fb19c1f30c48bc690d78712d5459f4090c3df01))



# [3.0.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/0.0.1...3.0.0) (2020-12-23)


### Bug Fixes

* 圈选无法选中UIAlertView问题处理 ([32cef9d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/32cef9df74edebf56324732afa8d77b92e12f78e))
* 添加滑动等事件touch的监听，处理圈选时滑动不刷新界面问题 ([ab7019d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ab7019de1f23ee702c745b242b08b71b7ec489a2))
* 修复view忽略后还能响应事件发送的bug ([2164401](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2164401480da0119731c98df50720416871f8366))
* 修改sessionid无值的问题，添加log ([c4d8126](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c4d812669ac117729198581b42303a88cbd0a059))
* 修改spec版本号，修改代码中版本号 ([bd21b0e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bd21b0e67323f2aa9491d98cdf2fd3d7163e89d1))
* 修改spec文件 ([025edb6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/025edb6c5ecaa76cfd9d57c15ceb89106a12e385))
* demo去除无用代码 ([c4c6417](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c4c6417026194987e17561c1f5b95fe430e8b6a1))



## [0.0.1](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/e52cc936c8aaed5b9c70eb884e99edfe5ce18e3d...0.0.1) (2020-12-17)


### Bug Fixes

* 代码修改，注释整理 ([bbac12d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bbac12d7fb3fc079c367cd623aaf6803da18d544))
* 合并代码 ([2dc17c8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2dc17c84a4126e1c3024b472a538fa73ae19b704))
* 合并工程 ([2d04a2f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2d04a2fa7d93b6d0a584199fe82a8e7ea038631f))
* 解决iOS 11系统上面visit多发的问题 ([0c5946a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0c5946a053f8800572bb0113ed273397aa92f380))
* 可以在外修改trackConfiguration ([a04d6ab](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a04d6abbd7f4046885bf279608c4fb4f30949fb6))
* 去除多余文件，修改UITableWrapView时的xpath逻辑 ([88800af](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/88800af7ee52bd10d1e4e9956dd0e9c82fb588bc))
* 去掉bugly的引用部分 ([2317f49](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2317f499820093f222a545628cfa24b0c366d423))
* 删除不必要的Analytics文件夹 ([0cf5f7a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0cf5f7a10c76f5fda054352de2b4d4b7599d6c1d))
* 事件采集json log 能显示中文且格式化 ([d612f61](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d612f61c4075de6ce13b11f588644678488a8725))
* 添加注释，修复圈选无法选中多个子page的问题，迁移deeplink处理逻辑到trackerCore ([37e0a29](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/37e0a29c41a4a782a2a83a40a7acd2981709fdea))
* 添加注释内容 ([bbd340d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bbd340d99f5e46cab885aa1c8465b8eee6c72348))
* 添加json格式http header ([05b4256](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/05b4256325cc381a712b055d6dbe606840636c64))
* 添加specs仓库支持，去除pod的仓库拉取操作 ([d3afd45](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d3afd45acafc92091084ae7970401c02fc76e951))
* 修复拼写错误 growingPageIgnorePolicy ([9ca7823](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/9ca78236751d784013948a086dd8c6d8eb7fddb7))
* 修复圈选present滑动退出没有更新截图问题，修复流量时，无法发送event问题 ([59986f6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/59986f6ef28c814bc4a5af863701f6224b06ca5a))
* 修复设定location时，VISIT事件缺失位置信息bug ([871acb1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/871acb1c8154360b78e194626c8ad0f8f310b2d6))
* 修复数据流量阈值不生效问题，demo 添加地理位置权限，修复 alert 点击事件不采集 ([ce8df4c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ce8df4c9a173ce04b9c9112dd004da611ef0cb3b))
* 修复hybrid事件发送domain不正确问题，重命名文 ([b3ec9aa](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b3ec9aa6478968044fdcf8a792b528fb6cc6ab62))
* 修复ios11以下tableview的xpath不正确bug，修改page无法找到vc时，取当前vc ([cdac988](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/cdac98890b541ecc4011ff2f2e717f2af07bf73f))
* 修复setGrowingIMPTrackNumber unrecognized selector 和 不带attributes的半自动埋点接口 ([25a8e20](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/25a8e20c10852eff9f759c27289dc0f818bd9faf))
* 修复tracker的头文件引用到autotracker的问题，去除部分已经去掉的头文件引用 ([fe92a23](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fe92a23e192733b763a89e275d4ed996dd65b1b1))
* 修复VISIT事件在拦截者处理userId变化前发送导致的的gioId不正确问题 ([c420548](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c420548618013bcee9c65b945173a2966d6286c9))
* 修改不合理的地方 ([4ba71c4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4ba71c4af93f0b0a17426396857a4a89d17fa952))
* 修改部分单元测试字段匹配，暂时移除CI的TEST校验 ([efdfdf7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/efdfdf762217fa087acea0bb6976e61b8f89962a))
* 修改界面UI关键词以及同步修改TEST示例中的定义key ([d8e9e08](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d8e9e08ad2283d72993c86e31ee178115594d075))
* 修改进入 AttributeLabel 页面crash 问题 ([35405e3](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/35405e3dc4b462d55053e34a5c2b89b01db08795))
* 修改拦截者集合类型为有序，避免调用时序所导致的bug出现 ([7fbafd7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/7fbafd766762ff7b2c03adfdaf3d0c3e7b22b99f))
* 修改圈选第一次无法运行bug ([4de2ce5](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4de2ce52a177d0bb483337e35b95064b50af274b))
* 修改圈选事件发送间隔为200ms，添加visit事件的网络状态字段，同时去掉page事件的网络状态字段 ([69f1ce1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/69f1ce1ac8f968f54017d29d1d64c5b0f3dba87f))
* 修改圈选提示框显示版本号 ([ca12d2c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ca12d2cfeaf1ed6249847b2bef199ce20d00acab))
* 修改圈选消息发送频率为1s，心跳为30s，修改README的CI说明 ([dc63a40](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/dc63a40b30324c30d3bffe5499cf66dceb06dc50))
* 修改网络状态为UNKNOW的情况，去掉剩余的vst等关键词 ([1c306b3](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1c306b36be578142bf60945b5e5744a731822789))
* 修改优化逻辑 ([0fa706a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0fa706a38db6e2026a1bffc61d2eef81d4dfde1c))
* 修改字符空置判断条件 ([30d8dd2](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/30d8dd278cb2404404ba0edd857fbe7e59a54d27))
* 修改attributes关键字，修复pageAttributes事件不发送问题 ([d9557d6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d9557d655efb3178ca8377d339fed719a51e3472))
* 修改CI 报错 ([1852c1f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1852c1f24937efdea16bcee237dd896f6d5ba560))
* 修改ci错误 ([947560a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/947560a9f86c79d4afa777b0319cf6f7b5f6a1e0))
* 修改pod spec配置，另添加travis.yml的系统为max os ([b9244de](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b9244de7865faf09429030f7faec23745e1235ab))
* 修改SRWebSocket析构时delegate置nil ([3bd5c8f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/3bd5c8f55c8213a29cb91bb6098cf9712cb36a66))
* 修改window筛选逻辑，修正网络url地址，修正数据协议字段 ([40e2cba](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/40e2cbae27a4517e364ada29588b9ff07a54c43e))
* 修改xpath逻辑，去除ignored的分类属性绑定 ([6b2ce6a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6b2ce6a3d6e8492766e26807301e0b686f89a4df))
* 移除不必要的声明文件 ([7610d18](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/7610d18362669165c3487b1dc26cf0e59255eaa9))
* 优化 ([580affd](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/580affde2af8033609e7ebb83c055049e7b8d3ed))
* add growingTrackImpression ([0be75ae](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0be75aeb1f6f93a325ee7a5e91eb262f94ae137d))
* fix autotestcases ([1e4a3e0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1e4a3e0daf91c8771c0df00d5b7ffc5ab3365991))
* fix autotestcases ([1c49c5b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1c49c5bcdcc0374e45168773e478c08428e35d7b))
* fix demo code style ([13ca9b4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/13ca9b4e2ac81195ecc5d548ffd65e439d41b2c6))
* fix prject and reduce ci steps ([ee6f2c0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ee6f2c028520e570e5df176fb24a1c310f110c03))
* fix yml ([92a4458](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/92a4458fcb43adad42b01294c8ce67e38b996757))
* fix yml xcodebuild Example ([0122de4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0122de46a2e1aee7c16cdd86ca5d0e10bce969af))
* fix yml, add code sign required ([43e37fb](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/43e37fb5db1ad112d3f34f585bc36d9a578f0862))
* github action 添加pod install命令 ([4bbcf03](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4bbcf0398e9de7f539c3f52c22f376d12f32293f))
* pod file 移除bugly，增加ci编译速度 ([98743b8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/98743b8a1c030d816800b9c7f0fa4ddd59855485))
* pod file udpate ([3994b0f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/3994b0fa2cb65fb80d737fc4c5bee19775ed53bf))
* sdk测量协议3.0再次修整，去除不必要的注释以及修改命名规则，去掉部分无法使用的测试用例 ([2420589](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2420589ef992cb798b0cd7cc460b77392881672f))
* setDataCollectionEnabled API不生效 ([1dec10d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1dec10d30fec73b9d347284a638538dae604a2fb))
* vc.view不再加入xpath,修改spec版本号 ([99d093b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/99d093b9550be9152fcc31eb9768c392bb443ab8))
* **add autotestcases to ci:** add autotestcases to ci ([2543f7a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2543f7a243473ea9a8fe222e03c3016546533792))
* **codecheck:** add CI setting, fix code that not fit our rule ([1867580](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1867580fe99d379aae676f707529fb65622d2d3b))
* **format:** 修改字符常量命名 ([d44b1e8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d44b1e88ed09b7d27c6f42c2fb6ff2a3d473be71))
* yml and project setting ([3b3c8cc](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/3b3c8ccb56d7b33a71fc63a7f7b9dcd84473ea2b))
* yml file fix ([7654a29](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/7654a296896f5169654e4f7dca69a39b299c2c2b))


### Features

* 测量协议3.0字段修改 ([c6d68e6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c6d68e6e4219be6a5992128bee315683449c384f))
* 工程整理，添加travis code check校验 ([ce710b8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ce710b8b682f0570ea82b610dd75523ff823e2e0))
* 将工程拆分为Core层和门面层 ([ff308f1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ff308f106b4f52c469b9b9fe0bbc1a7c37f71a46))
* 将项目结构拆分为Core层和门面层，方便后续兼容CDP ([b62450c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b62450c3fff66a61fdd158f4ffa7151cc482b644))
* 圈选扫码模块完成 ([cbabcb8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/cbabcb858fbf7395c7e6072a9701a29ccd05738a))
* 删除 GrowingMenu 以及相关的 Menu 视图，添加系统自带的 UIAlertControler ([a4c77f1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a4c77f14d7db8d68331f8e00914e674584923881))
* 删除广告相关事件以及相关的接口 ([4afd853](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4afd853999617f2039e05a8e74cc9f07cd1778f9))
* 删除GrowingBaseModel 重构 LoginModel ([258d55e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/258d55eeac294706ec2c26677f150d92b26a1bf7))
* 设置延迟采集时，初始化不会调用敏感API ([4892df3](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4892df3271d57cb1544e88e8a0b3c5e2e6d658ce))
* 适配圈选hybird，修改xpath逻辑 ([60cf244](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/60cf244aba740af71890d0fb803041129d7ebd06))
* 替换CI为github action,并修改xpath中ignored的逻辑 ([b720d6b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b720d6be3f9980d15a3938b33a8c80fbe48334a5))
* 添加 VCStructure 相关的 demo ([f36875f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f36875f353ae675e6cb0b5387c0a4062499b0d94))
* 添加动态代理对象，私有化分类接口防止重复声明,适配Cdp ([92e1e7d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/92e1e7db0168eecc81f9964021dffb585d738143))
* 添加和完善pvar 测试页面，调整Request 目录名称 ([1dea1a0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1dea1a044bbd68d8eb13a50beb965627c0f7f5a4))
* 添加脚本文件，CHANGLOG文件、.gitignore ([144c6b7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/144c6b72ecdee21b31cfebd1273401c3e3269e83))
* 添加圈选文件变动，修改SRWebSocket命名 ([f89c4d5](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f89c4d5956ea5221798455aededf02617d168c2f))
* 添加事件触发拦截，避免event发送和圈选逻辑关联，去除不必要的代码 ([b975d69](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b975d69a841a85573cdba406c91a2fe953da51f5))
* 添加setDataTrackEnabled 和 setDataUploadEnabled 接口，完善demo ([84ce669](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/84ce6699d922f1f711d3c33f6cc4adff3589a1d9))
* 完善Session的逻辑 ([f88944b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f88944b74e394e11a6f6c81376712882eeb4eb3b))
* 无埋点和埋点版本号统一，每次发布时需要手动更新（podspec 和 kGrowingVersion）的版本号。 ([d5865aa](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d5865aa3fd3bc50f1bab12e4b100444fc9026daf))
* 协议3.0的修改，同步修改测试案列中的字段匹配 ([c7be8eb](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c7be8eb8da552f6d5c4c4b301d0aef96d08c0c3d))
* 修复编译警告，删除不必要的import ([d757ff8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d757ff81f57bbaa3e7edf40f9f6f3330b5517cfb))
* 修复一些警告 ([53ff76a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/53ff76a44b08de0f8b2058e1a539d0785e2ffdb6))
* 修改 podspec 文件 public header ,  添加 TODO 防止 crash ([df1d7b5](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/df1d7b5c7beca7128acabca4a52dfadfe2f41c80))
* 修改工程结构，添加ci测试的证书验证 ([f1ed93c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f1ed93c76437c4327942933b515314e7ae8db220))
* 修改圈选和实际xpath不匹配问题，修改xpath获取逻辑 ([19c966f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/19c966ff094f075e73918b0d6cb2cd5a5766b703))
* 修改自动化测试报错问题，支持 xcodebuild test ([75301ae](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/75301aecd0dbaf87da0e318b771b192d64ee4fc1))
* 增加urlscheme打开debug ([788694f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/788694fef96fe584e3b917530b43af84eb5a29d2))
* 整合2.x 的bug 修复代码到3.0 ([8971181](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/897118105db1f45839d830051b445d91dfc33e82))
* add testcases ([1b6eede](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1b6eedeecc2a99630004f08eb2f9e07c1e3b3a7a))
* autotracker门面层封装 ([0444dcf](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0444dcf5eef2124dfc9660ec2034cc5bfa5b8485))
* event事件重构 ([05d084e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/05d084ec8c0764966a936bad22b9f6bd8e5b8330))
* event重构，工程逻辑调整 ([c8cd59f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c8cd59fd692bca7bdc82c8f6e0b42f08da0aaa25))
* javascriptBridgeConfiguration 补充必要信息 ([97be6f1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/97be6f1be7e803d8537c1d4e2c1202450a58de25))
* mobileDebugger and Log ([f55ff6c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f55ff6cf65f5441e760c14ae507c064866e885ac))
* mobileDebugger Log ([ea6c625](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ea6c6252485c262c7c6f8364b85af34c91b4a500))
* mobileDebugger Log ([4075638](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/40756384e0eefd7edb0eb0b79c63afc01afcff27))
* mobileDebugger Log ([b82ad9b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b82ad9b022d18c03c0c53ea006ea972dfad74d4e))
* mobileDebugger Log ([0add990](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0add9904f4de8355b0625405b22e4e6df098132c))
* xpath逻辑圈选和事件发送一致的处理 ([3893fb3](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/3893fb3b5a46d77a9420492148de610d7238f1e1))
* **circle:** web圈选适配以及hook添加 ([fc93c32](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fc93c32e446b1ef3aebe73fed935ce007cecc626))
* xpath逻辑修改根视图为/Page/...，page事件的page路径仅遍历3层 ([f4305c9](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f4305c974227a0a446ab7ed53d56617b5e83d4ca))
* **sdk3.0:** 工程第一次提交，版本SDK3.0 ([e52cc93](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/e52cc936c8aaed5b9c70eb884e99edfe5ce18e3d))
* **webcircle:** 添加圈选代码,添加代码检测以及代码格式化工具target ([854d14e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/854d14ed98b7c407dbac46b513524c676445b2a1))


### Performance Improvements

* 删除一些冗余代码 ([608e960](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/608e960920e91c5de27b8df08eb47fa0c7fa208d))



