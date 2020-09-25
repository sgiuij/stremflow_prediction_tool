# streamflow_prediction

## 最终要实现的目的
https://esri.maps.arcgis.com/home/webmap/viewer.html?useExisting=1&layers=5c2e6d2137bb4d2187db387979db2f31

#### 功能要点
1. 点击地图上任意一点，弹窗显示详细信息
2. 动画播放河流演变

## 资料
- [SDK](https://github.com/Esri/arcgis-runtime-samples-ios/tree/master/arcgis-ios-sdk-samples)
- [Map Server](https://livefeeds2.arcgis.com/arcgis/rest/services/GEOGLOWS/GlobalWaterModel_Medium/MapServer)
- [API Helper](https://livefeeds2.arcgis.com/arcgis/sdk/rest/index.html#//02ss00000057000000)
- [Time Aware Layer](https://developers.arcgis.com/ios/latest/swift/guide/visualize-and-compare-data-over-time.htm)
- [Tool Kit](https://github.com/Esri/arcgis-runtime-toolkit-ios)
- [Time Slider](https://github.com/Esri/arcgis-runtime-toolkit-ios/tree/master/Documentation/TimeSlider)
- [Charts](https://github.com/danielgindi/Charts)

## 兼容性
IOS 13.0

## SVProgressHUD 在IOS13中的bug
https://github.com/SVProgressHUD/SVProgressHUD/issues/1002

执行 pod install 之后, 在Pods/SVProgressHUD/SVProgressHUD.m  L689改成

```swift
CGRect orientationFrame = [[UIScreen mainScreen] bounds];
```