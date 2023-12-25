# [4.0.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.0.0-beta.2...4.0.0) (2023-12-25)


### Bug Fixes

* add generalProps APIs to swift exports ([401389d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/401389d95b53ae79f2692c37ca5d57edb9a909ea))
* CWE-789 vulnerability ([2a5c20a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2a5c20a92035e78050f57087c5a7ae0d0ce22287))
* default requestTimeout is 30.0 ([176b44a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/176b44af1a2a98c71db6741444d70fbe79711e0c))
* fetch network status at reachability init ([6c66cc6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6c66cc6bc08ef2dde7af0caa17c5273279a173f8))
* **MobileDebugger:** debugger_data with wrong url ([89dd416](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/89dd41633bbc74c2e8e4c0082bf8bcc36f2dce6d))
* networkConfig.requestTimeoutInSec change to requestTimeout ([dac2b77](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/dac2b77286e89e909c2d9d7323275dd958b4bf7c))
* remove codes about md5 (weak hash, not safe enough) ([6548bd9](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6548bd9211ecf71248eff17aab07df1ed4e52a3b))
* SDK 4.x 无埋点事件 index + 1 ([b6c0279](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b6c02790d8a3e1bb82b55c93713161a53bd1409b))
* target conditionals macro in deviceInfo ([533148a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/533148a1ecacb38afa1819bd7e25e385f97c8104))
* update logic of reachability check ([fdb93af](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fdb93af8d0bccba558cb54129a5c7e2546f5085a))
* **WebCircle:** remove viewContent of listView type ([5f9bb1c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/5f9bb1cc6a63c2446bb75acf6c7b88abd78715c9))


### Features

* add abtesting module ([#281](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/281)) ([2d3950f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2d3950f0844fde3af1dc26862392bb825c299bef))
* release 4.0.0 ([#294](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/294)) ([a2dbf1c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a2dbf1ca5bc12ad368eb015bea1da497a26808fe))
* release 4.0.0-beta.3 ([f73a58b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f73a58ba26b7bb7022d13bca6f8ac020ea410058))
* request timeout config (merge [#293](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/293)) ([2e599ec](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2e599ec62dfa099733c5fb97f0a4f4e262d9eb40))



# [4.0.0-beta.2](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.0.0-beta.1...4.0.0-beta.2) (2023-10-26)


### Bug Fixes

* rename advert to ads ([#289](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/289)) ([0627a3a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0627a3a0b19a24c774c3a5153facf16bdc11fe6c))



# [4.0.0-beta.1](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.0.0-beta...4.0.0-beta.1) (2023-10-26)


### Bug Fixes

* xcontent in list ([#287](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/287)) ([569f7ca](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/569f7ca7287a6800b9f89254a97cd4202f93756e))


### Features

* add generalProps APIs ([#286](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/286)) ([e60f1fa](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/e60f1faaf9e50920c5cf5524d4e900fc54d90b3f))



# [4.0.0-beta](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.7.0...4.0.0-beta) (2023-10-20)


### Bug Fixes

* 3 to 4 (<=3.4.5)  如果有未上报的 PAGE_ATTRIBUTES 事件会造成崩溃 ([f807243](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f80724336db8fd829d9e5d70a231a46f105d47c7))
* 3 to 4 (<=3.4.5)  如果有未上报的 PAGE_ATTRIBUTES 事件会造成崩溃 ([ece63cd](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ece63cdf5514242e58b87659208796c6a1633e6a))
* 3to4 过滤不兼容的 v3 无埋点事件 ([2777412](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/277741296a2b64fa5d39203dcd2d7a8a8cecaa61))
* add initSuccess api to spm ([42e0901](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/42e09011d5ed11c8e4906d314a8c0ba406020295))
* bug ([bb62845](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bb628455816b01a8d7f08c2e83972df35a7c68d0))
* delete unused codes ([c1137e6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c1137e6005a842f36d9e8bf62039cc6bb09ab2cb))
* delete unused codes ([72142c7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/72142c71269159e0ca724cdf1307ce1f9a18bd3c))
* delete unused codes ([bdcba48](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bdcba48fdb7140bd5540f58b8dbe8d3e2cceb4e7))
* generate framework bug ([5d246ec](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/5d246ec865a36a725d7ce7358eb2e35e0509cb27))
* growingUniqueTag logic ([4a7c9b7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4a7c9b70d0ec07c76a5c31e6dd41477aa413a228))
* growingUniqueTag logic ([72ada7a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/72ada7a9235d228e0709a7bf1103c9f85d8acff7))
* hybrid 圈选时，元素位置不准确 ([5d278ae](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/5d278ae5a6e60297f9e2695eb739bc392c4f9c9d))
* mobileDebugger bug fix ([50f30ad](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/50f30ad4cfb3ade3ea0b3a8d8a59dde94a081e6c))
* page.path 前加斜杆 / ([da5492e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/da5492efc5732c9c98480c794d9886c85255b575))
* privacy manifest 适配 macOS ([a34b441](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a34b441d11eea0ceb92c633024140e20aed3d7d5))
* remove NoIDFA file/config ([06ad8ba](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/06ad8bab5f4b834524b01aae1d2c9ba78db71006))
* rename modules apis by using NS_SWIFT_NAME ([fa61778](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fa6177836f69c7a3abbd5eb37298ac4511cdd06d))
* rename projectId to accountId ([#285](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/285)) ([0de68d1](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0de68d194d58d2025ea137edcfa7c7bab753d391))
* sequenceId for event type ([e4c6411](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/e4c6411b535afae376e35e72fe2d199e9201ab4f))
* sonar quality bugs ([feec096](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/feec0960d4e30526519f38b16dc7d5ef78b90ff9))
* sonar quality bugs ([1cbbd72](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/1cbbd728ddce74d702e793e6ec13fd9daac17544))
* swift protobuf 中 timezoneOffset 数据类型为 String ([ed7751b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ed7751bcc78db497fbfdf1d8dc744890dff0b446))
* swift protobuf 中 toJson 后 timestamp 应为 Number 类型 ([613f325](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/613f325e4836f252e8ad3b5da60cd973dd9c7ce4))
* swiftProtobuf func parseFromJsonObject bug ([#282](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/282)) ([32e8aae](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/32e8aae18b9d3ad62c1bbff0ffc61ce135057d37))
* swiftProtobuf parse jsonObject ([3c3d4a9](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/3c3d4a9fc152cd7735e456600fb09a12db79c2a0))
* swiftProtobuf toJsonObject VISIT eventType ([b225d8e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b225d8e1e2ff7119852a93aa8cc888d4097f329e))
* swizzle bug  ([#279](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/279)) ([a231653](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a231653ad82ac23dfd2545361b578d6321b83de9))
* timezoneOffset 在运行期间仅获取一次 ([d521017](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d5210175482fc9548b3f677ece90bb87ec47dac8))
* timezoneOffset 改成 string 类型 ([b3f9ef0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b3f9ef070103da94023ea2ce7ecd836e33a73940))
* UIAlertController/UISegment swizzle 延迟到初始化时 ([28b82ab](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/28b82ab182386b91bdc4aeb75615738ae0cb8ea2))
* update GrowingUtils to 0.0.6 ([2e885ec](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2e885ec8915239e846267093cfae971bc4d207ab))
* update Package.swift ([8e797d0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/8e797d0db10d3f392a2974c7f40f05c0797a9107))
* update spm dependency version ([#280](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/280)) ([31eeaa7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/31eeaa722655232ca5529046b7e7f5dc4ac9146e))
* **WebCircle:** element.page 前增加斜杆 / ([2851195](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/28511956c1e6c3a4022c064a855753189403619d))
* **WebCircle:** page.path 前增加斜杆 / ([#283](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/283)) ([6676770](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6676770700263ccfb03db9bfbda0acdee22ca0dd))
* xindex -> xcontent ([a8f632d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a8f632d0c42b7bb5aeb29affcc49dafcf95ba073))
* 优化手动集成下的 privacy manifest 导入 ([f812823](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f8128235286e7d41d0293d4ad3aa6ab52d3a2b9a))
* 去掉奇怪且无用的 SwiftPM wrapper ([3662253](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/366225333bda2ccc344871cd631d3e098c0ab253))
* 参考 facebook，用更 swift 化的方式编写 Package.swift ([01a6b38](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/01a6b38de8c93277ac6155c3cc04eb4a96bbcd1a))
* 圈选结束状态栏未隐藏 ([78ab9e4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/78ab9e439321990f50d6bae443e05129f7b0c18e))
* 多线程下调用 autotrackPage ([b9d7517](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b9d7517b8819d8bfac0782f211254eea086a5ae7))
* 将 GrowingAnalytics.xcworkspace 移到 Example/ 目录下，其在根目录会影响 xcodebuild -list 的执行 ([25ef674](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/25ef674c6d9d814170e50ba93e8599557fb0987a))
* 支持 UITableViewHeaderFooterView 圈选 ([c2fa558](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c2fa558268a7d81e17c2cc31e409594c2318db7b))
* 更符合 Swift 规范的 swift interface (在 SPM 下) ([57b2195](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/57b21951f6dc337a2a54ee46c300b721b31b486d))
* 更符合 Swift 规范的 swift interface (在 SPM 下) ([6c50f8a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6c50f8aea3d0ed78bc10b6be72849e548493904e))
* 统一 GrowingPageEvent 对象中的 pageName 为 path ([d19c472](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d19c472f8e4076b3f178111f37eeda1709c4999c))


### Features

* add autotrackEnabled/ignoreViewClass/ignoreViewClasses ([dfc9285](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/dfc9285d203b01e921ce836edc67c398671b1104))
* add privacy manifest support ([85d56a7](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/85d56a72bf72796b8db5f09a26e086ea287616e6))
* event add timezoneOffset property ([6886d49](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/6886d4908fa92d9842bb1c8f3e2bfe035335e48d))
* protobuf 上报兼容 xcontent、xindex ([bdb318c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bdb318c93c47a59d1abbc3753e1f2108f7c0bcf2))
* release 4.0.0-beta ([5769db9](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/5769db9bc20fc11ad90cb025395881181cea35b5))
* 无埋点事件属性添加 page attributes ([ee2cb28](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ee2cb28dc086e917e28cc7e1c80f466127a1ef66))
* 添加返回是否成功初始化的 api，与安卓一致 ([bb0b288](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bb0b2887193c0b9e983a09895620f502bafdf922))


### Reverts

* 恢复 SwiftPM wrapper，其作用在于区分 platform ([f68d25c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f68d25cf8449f49ef0f74551cd3e8a967132a02a))
* 移除 FORM_SUBMIT 事件类型 ([30b3c34](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/30b3c3468a48e89bd917c70899db2f76d3bbf776))



# [3.7.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.6.0...3.7.0) (2023-09-19)


### Bug Fixes

* delete unused codes ([c837491](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c8374915290d74e0a11cd754612d3ef59b6ab6c0))
* generate framework bug ([26815b8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/26815b8afe786e837d9f29d64590e98133792468))
* hybrid 移除无效 log message ([f7919b9](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f7919b93f2fabbeef38e58a6c1e92184afa04ca9))
* macOS 使用 swiftPM 集成报错 ([868523d](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/868523d7d9531f8a5dc92c2fcf84383d7b5cb0de))
* mobile debugger bug ([efc8462](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/efc846233ebad77da2fbf34228a74c020fe6ac57))
* mobile debugger bug ([dc32df4](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/dc32df49e87cac99d60f011cc4bcc0fd2eac6bc6))
* privacy manifest 适配 macOS ([ea7497c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/ea7497c802cf7a224e8c7ac91b9e6da2285007ad))
* UIAlertController/UISegment swizzle 延迟到初始化时 ([2e0fde6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2e0fde67d4ef6de87ac9d6cb574553b6b9ca6c92))
* 将 GrowingAnalytics.xcworkspace 移到 Example/ 目录下，其在根目录会影响 xcodebuild -list 的执行 ([7d22f57](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/7d22f5725b607a7a8f87b659b230a01bedcfbeaf))


### Features

* add privacy manifest support ([c715fde](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c715fdee94d3d5ae44efb1ff098cde9cf2295d4a))
* release 3.7.0 ([47735c6](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/47735c681be9f027be941e5337cc9471b7d604b7))
* v2 to v3+ adapter ([#270](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/270)) ([8dcd2bf](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/8dcd2bf870b76688bff1a3588f6d8f87814acd78))


### Reverts

* UISwitch 改回 VIEW_CLICK 事件 ([09ab399](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/09ab3997e7bf9025f34c00715053f94bda00c5cf))



