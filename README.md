
# react-native-arena-pay

## Getting started

`$ npm install react-native-arena-pay --save`

### Mostly automatic installation

`$ react-native link react-native-arena-pay`

### Manual installation

### 配置
###### iOS
1. 将ios工程下的framework文件夹和source文件夹导入主工程。
2. 在buildSetting中配置
	
	1、Framework Search Paths  添加 “$(SRCROOT)/../node_modules/react-native-arena-pay/ios/framework”
	
	2、Header Search Paths  添加 “$(SRCROOT)/../node_modules/react-native-arena-pay/ios/framework”
	
	3、Library Search Paths 添加 “$(SRCROOT)/../node_modules/react-native-arena-pay/ios/framework/WeChatSDK1.8.3”

3. 在info -> URL Types中配置微信key 
4. 在主工程中添加支付宝/微信支付库的依赖
	SystemConfiguration.framework, libz.dylib, libsqlite3.0.dylib, libc++.dylib, Security.framework, CoreTelephony.framework, CFNetwork.framework,
QuartzCore.framework,CoreText.framework,CoreGraphics.framework,CoreMotion.framework
	
5. 在你的工程文件中选择Build Setting，在"Other Linker Flags"中加入"-Objc" 和 "-all_load"
	
6. 在AppDelegate中添加跳转微信/支付宝的代理方法。
 
```

//  应用间跳转的代理方法
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
  
  NSString *optionKey = options[UIApplicationOpenURLOptionsSourceApplicationKey];
  NSString *absolute = url.absoluteString;
  
//  支付宝支付
  if ([url.host isEqualToString:@"safepay"]) {
    return [AliPayManager applicationOpenUrl:url];
  }
  
//  微信支付或者微信登录
  if ([optionKey isEqualToString:@"com.tencent.xin"] && ([absolute containsString:@"pay"] || [absolute containsString:@"oauth"])) {
    return [WXPayManager applicationOpenUrl:url];
  }
  
  return YES;
}
```


###### Android
1、把source文件夹下的wxapi文件夹导入根包（两个回调Activity对象）
2、在Manifest.xml文件中加入这两个Activity

```
  <activity android:name=".wxapi.WXEntryActivity"
            android:label="@string/app_name"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:exported="true"
            android:taskAffinity="net.sourceforge.simcpux"
            android:launchMode="singleTask"/>

        <activity android:name=".wxapi.WXPayEntryActivity"
            android:label="@string/app_name"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:exported="true"
            android:taskAffinity="net.sourceforge.simcpux"
            android:launchMode="singleTask"/>
            
```



#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-arena-pay` and add `RNArenaPay.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNArenaPay.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.dingle.pay.RNArenaPayPackage;` to the imports at the top of the file
  - Add `new RNArenaPayPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-arena-pay'
  	project(':react-native-arena-pay').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-arena-pay/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-arena-pay')
  	```


## Usage
```javascript
import RNArenaPay from 'react-native-arena-pay';

   // 苹果内购
    RNArenaPay.appPay({数据}).then((data)=>{
      console.log('支付成功，拿到支付秘钥，需要后台验证')
    },(error)=>{
      console.log('支付失败' + error.code)
    })

    // 支付宝支付
    RNArenaPay.aliPay({数据}).then((data)=>{
      console.log('支付成功')
    },(error)=>{
      console.log('支付失败' + error.code)
    })

    // 微信支付
      RNArenaPay.wechatPay({数据}).then((data)=>{
      console.log('支付成功')
    },(error)=>{
      console.log('支付失败' + error.code)
    })
    
    <!--微信登录-->
    RNArenaPay.wechatLogin().then((data) => {

            // Tips.showTips(JSON.stringify(data))
        }, (error) => {
            Tips.showTips(JSON.stringify(error))

            // console.log('支付失败' + error.code)
        })
```
  