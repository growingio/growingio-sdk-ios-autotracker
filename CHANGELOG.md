# [3.6.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.5.0...3.6.0) (2023-08-16)


### Features

* hybrid add enable/disable bridge APIs ([#272](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/272)) ([d273ca0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d273ca04f3b351192433376c244c4ceabcd9f21b))



# [3.5.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.4.8-hotfix.1...3.5.0) (2023-07-06)


### Features

* release 3.5.0 ([9166b0c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/9166b0c7698062ab0669eeb574bc8711df5bcbf2))



## [3.4.8-hotfix.1](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.4.7...3.4.8-hotfix.1) (2023-06-16)


### Bug Fixes

* add UICandidateViewController/UISystemKeyboardDockController/... to ignoredPrivateController ([0c5e7d8](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0c5e7d830d3c4df3a114b6bb6eb8bceba81d9e22))
* CTTelephonyNetworkInfo 偶现崩溃 ([#262](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/262)) ([8145225](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/81452255f24dda1597a930355e6962843df757a9))
* default server host change to napi prefix ([7342a8e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/7342a8eeba888760e77f4a0281978d7bb31f3b4d))
* duplicate codes ([55a5b78](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/55a5b78b487c4c62e9bc0913eea11541bdd7954b))
* flutter plugin trackFlutterPage 支持列表属性 ([4d780fa](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4d780faccc8841a8e6e9b7d13899c60fcfdcfa37))
* priority inversion issue by Xcode14 thread performance checker ([#249](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/249)) ([7283901](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/728390102226ea22d9107fb076e9d9c98bc559e2))
* priority inversion issue in GrowingSRWebSocket by Xcode14 ([#252](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/252)) ([d3201a0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d3201a0799440e7c5315ea20e01e9777268d484c))
* Remove usage of deprecated Endian with CFSwap ([b24956c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b24956c32e1a8e1c39b705cb0b83d56d0c53ceac))
* SPM 无法通过 exact version 集成 ([#269](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/269)) ([c007055](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c0070554b65550a2738ae2fe9627221db56cc661))
* swift project building error about 'Include of non-modular header inside framework module' ([#251](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/251)) ([4ad2838](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4ad2838fb4dd0c926d021d8350eb13688eb8b2c0))
* verify deep link host ([#255](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/255)) ([bc096a2](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bc096a267c54a6e20b16183354363d25218e0757))
* web circle bug ([f2a4b3f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f2a4b3ff608b1887f7329220cbcc86ba084560d7))
* 修复特殊场景下，每当初始化 SDK，ASAFetcher 都会 startFetch (Advert) ([#247](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/247)) ([df9c88b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/df9c88b04e1bdebaaf836d1ffe9d851b5b1eec30))
* 添加中间层 flutterWebCircleBridge，移除 __has_include 文件判断方式，避免 CI 失败 ([4b48868](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4b48868f65e4e4b73fec23e965036117c39712db))


### Features

* Flutter plugin ([855bd6e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/855bd6eed6bb1cd8197dad05060df855ca22c5b7))
* Protobuf 模块支持 SwiftPM 集成 ([#248](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/248)) ([a643854](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a6438543deec2c04059fa8f849f134edb016e770)), closes [#251](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/251)
* release 3.4.8 ([496d250](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/496d250f2eafe05175be7f82bcb28f8475687761))
* release 3.4.8-hotfix.1 ([#266](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/266)) ([b98ef28](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b98ef289a1962a0eb842eb05189a3799d596f3d6))
* support macOS ([#244](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/244)) ([c1a332a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/c1a332af6444a067830fab455ef3d0fe5b83e6d7))
* 无埋点支持 UISlider，且 UISlider/UISwitch 为 VIEW_CHANGE 事件 ([#258](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/258)) ([92bc335](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/92bc33522e1d8190349406d3fb62c1df0923683a))



## [3.4.7](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.4.6...3.4.7) (2023-03-06)


### Bug Fixes

* app 切后台超过 30s，其唤醒事件 SessionId 未刷新 ([fac9578](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fac9578774c9f80325e563fcc036f5829d199583))
* deep link bug ([b79f80b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/b79f80b1df967323fdbd0899af450e5272681a11))
* deeplink 获取自定义参数的请求去掉不必要的参数 ([db5e18e](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/db5e18e84448c330b37dc211d19b8cb639319d09))
* deepLinkHost 改为 NSString 类型 ([fbd26ff](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fbd26ff96a0c8f73ef4708e55dcb0fd03f524ef8))
* UIViewController add growingPageAttributes api ([54e8342](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/54e83426c8c888ff6722c5f8d188d776f1efa8b5))
* 仅 Universal Link 短链才去请求自定义参数，其余情况从 url.query 获取 ([832bc43](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/832bc4322c56473467aae1d54b568373cbd04301))
* 修改 advert 模块本地存储方式 ([fa4dc64](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/fa4dc64e99a205d39ba6a8deec23c0d5977014d4))


### Features

* deeplink ([71a010f](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/71a010f15fdc5fcd75a90a118fc27cd4bbd19bd7))
* deeplink setDeepLinkHost Api ([dcf9eca](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/dcf9ecad2a7435f76b283fd5e12a9b8a11b90a92))
* release 3.4.7 ([23fd0b0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/23fd0b03e8bc3887ba5bbfa518f2f09b4119a2c9))
* rename apm/track_timer attributes keys ([2898716](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2898716e43187d11047c4f90f55e12d6038196af))



## [3.4.6](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/3.4.5...3.4.6) (2022-12-15)


### Bug Fixes

* Web 端未集成圈选插件时，显示对应提示 ([944919a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/944919a5e9b3b0c6464a3ebe402b6e08cffc5e3e))


### Features

* page attributes ([acece74](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/acece749cbffe6358ac337655c95eccfee20f192))
* release 3.4.6 ([4e1fbcb](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4e1fbcbc24218d55b104e722579b5277e6a7718b))



