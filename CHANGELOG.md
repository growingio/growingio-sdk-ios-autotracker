# [4.4.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.3.0...4.4.0) (2024-05-30)


### Bug Fixes

* visionOS support via Cocoapods ([#317](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/317)) ([9ab87ec](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/9ab87ec8fc3710e2d7574afd84aa8ccd214a1116))


### Features

* release 4.3.1 ([8841a35](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/8841a3535af21570885f7f203b85cac87e7ab5e7))



# [4.3.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.2.0...4.3.0) (2024-05-07)


### Bug Fixes

* add limit of events data length when query from db ([#304](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/304)) ([d54bef0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/d54bef0b7a7646973f2730fe84efc9ac41353367))
* add privacy manifest for watchOS/tvOS/visionOS platform ([#303](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/303)) ([3ce88fc](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/3ce88fc237eb13a4ec90432dba27899d2a836115))
* **autotrack:** ignore pages in GioKit by moving autotrackAllPages logic to viewDidLoad ([#302](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/302)) ([59e5cdd](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/59e5cdd29b1decaf0ce229a72066f06ee053f1d6))
* **perf:** func growingHelper_beautifulJsonString waste a lot of cpu time ([#312](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/312)) ([f8150cb](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f8150cb4955f0b015c6bb5f17e4d81a1170f66f2))
* UICollectionView/UITableView swizzle bug ([#316](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/316)) ([0ec1ab0](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0ec1ab088dfcaf4e8ade23a096d1934c432cad46))
* **v2Adapter:** 兼容更多老 SaaS 的属性值的类型 ([#307](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/307)) ([f2f032b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f2f032bdd1569454378abac615a65b61815b496a))


### Features

* add set dynamic generalProps generator ([#308](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/308)) ([bec7290](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/bec729034d12467fa97fa101e5bb3e32cb133021))
* data validity period ([#310](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/310)) ([a52fefa](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a52fefa7a7bf7a3590c49c501f193449aa94f631))
* release 4.3.0 ([da7c57c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/da7c57cc69c6c6d89ab5e9eda1cd6bf88b8e63e1))
* watchOS/tvOS/visionOS/SwiftUI support ([#300](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/300)) ([0ef1b26](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/0ef1b260915febb12b080edac0f5b13e08b1e592))



# [4.2.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.1.0...4.2.0) (2024-03-14)


### Features

* **autotrack:** autotrack-page white list ([#301](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/301)) ([5cb409b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/5cb409b7fbabf6256a91670a1bd5db4843f8b1ac))
* release 4.2.0 ([4fad445](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4fad4457f46e3525f0b46a1e437e2b826708eaba))



# [4.1.0](https://github.com/growingio/growingio-sdk-ios-autotracker/compare/4.0.0...4.1.0) (2024-01-25)


### Features

* app extension support ([#296](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/296)) ([4a9d038](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/4a9d038323b68393dd62f9edffd39955a3d85e45))
* flutter module to v4 logic ([#295](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/295)) ([a52bc94](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a52bc94c31048920ce701edfc13f177e4aa1f14b))
* release 4.1.0 ([11ae897](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/11ae897c407aafb2bd183e9a71c5fbf995fa689c))



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
* release 4.0.0 ([eef790a](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/eef790a247576dd2a1fb746e992a1d13183f187a))
* release 4.0.0 ([#294](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/294)) ([a2dbf1c](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/a2dbf1ca5bc12ad368eb015bea1da497a26808fe))
* release 4.0.0-beta.3 ([f73a58b](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/f73a58ba26b7bb7022d13bca6f8ac020ea410058))
* request timeout config (merge [#293](https://github.com/growingio/growingio-sdk-ios-autotracker/issues/293)) ([2e599ec](https://github.com/growingio/growingio-sdk-ios-autotracker/commit/2e599ec62dfa099733c5fb97f0a4f4e262d9eb40))



