
# react-native-arena-pay

## Getting started

`$ npm install react-native-arena-pay --save`

### Mostly automatic installation

`$ react-native link react-native-arena-pay`

### Manual installation

### 配置
###### iOS
1. 将ios工程下的framework文件夹和source文件夹导入主工程。

3. 在info -> URL Types中配置微信key 。
		QQ的话scheme是 tencent + 我的AppId
		
使用QQ登录需要在info.plist中添加 LSApplicationQueriesSchemes
		
4. 在主工程中添加支付宝/微信支付/QQ 库的依赖
	SystemConfiguration.framework, libz.dylib, libsqlite3.0.dylib, libc++.dylib, Security.framework, CoreTelephony.framework, CFNetwork.framework,
QuartzCore.framework,CoreText.framework,CoreGraphics.framework,CoreMotion.framework,libiconv.dylib,“libsqlite3.dylib”、“libstdc++.dylib”
	
5. 在你的工程文件中选择Build Setting，在"Other Linker Flags"中加入"-Objc" 和 "-all_load"
	
6. 在AppDelegate中添加跳转微信/支付宝的代理方法。
7. QQ集成文档：https://wiki.connect.qq.com/ios_sdk%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA
 
```

//  应用间跳转的代理方法
#import <RNArenaPay/RNArenaPay.h>


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
  
//  QQ 授权回调
  if([absolute hasPrefix:@"tencent"]){
    return [TencentOAuth HandleOpenURL:url];
  }
  
  
  return YES;
}
```


###### Android
1.把source文件夹下的wxapi文件夹导入根包（两个回调Activity对象）
2.在Manifest.xml文件中加入这两个Activity，wxapi文件夹一定要在包名文件夹下

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
3. 替换WXEntryActivity、WXPayEntryActivity中的微信AppKey。

4. 替换 库里的Manifest中的QQ的AppId data android:scheme="tencent101845112"

5. 在主工程中 MainActivity 中加入以下代码 ,否则没有回调
```
 @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == Constants.REQUEST_LOGIN) {
            Tencent.onActivityResultData(requestCode,resultCode,data, RNArenaPayModule.module);
        }
        super.onActivityResult(requestCode, resultCode, data);
    }
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

// 注册微信appid
    RNArenaPay.wechatRegister('wx4da13368004666f5');

    // 注册QQ的AppId
    RNArenaPay.QQRegister('101845112')
    
    

   // 苹果内购
    RNArenaPay.appPay({数据}).then((data)=>{
      console.log('支付成功，拿到支付秘钥，需要后台验证')
    },(error)=>{
      console.log('支付失败' + error.code)
    })
    
    
    
    
    

    // 支付宝支付
    RNArenaPay.aliPay({payInfo:订单字符串}).then((data)=>{
      console.log('支付成功')
    },(error)=>{
      console.log('支付失败' + error.code)
    })




    // 微信支付
      let payData = {
      partnerid: '',
      prepayid: '',
      noncestr: '',
      timestamp: '',
      package: '',
      sign: ''
    }
    RNArenaPay.wechatPay(payData).then((data: any) => {
      tips.showTips('支付成功');

    }, (error: any) => {
      tips.showTips(error.code);
    })
    
    
    
    
    
    
    <!--微信登录-->
    RNArenaPay.wechatLogin().then((data: any) => {
//        data.code 用于后端从微信获取用户信息 
        console.log(data.code);
  
      }, (error: any) => {
        console.log(JSON.stringify(error));
        tips.showTips('微信登录失败')
      })
      
      
      
      
      
      
      
      <!--QQ登录-->
      RNArenaPay.QQLogin().then((res:any)=>{
            console.log(res);
           // res 有3个属性，accessToken、openId、expiresTime
            
        },(err:any)=>{
            console.log(err)
        })
```
  