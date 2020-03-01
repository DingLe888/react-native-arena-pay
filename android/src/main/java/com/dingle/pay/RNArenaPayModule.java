
package com.dingle.pay;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;

import com.alipay.sdk.app.PayTask;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXMiniProgramObject;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;

import static com.tencent.mm.opensdk.modelbase.BaseResp.ErrCode.ERR_AUTH_DENIED;
import static com.tencent.mm.opensdk.modelbase.BaseResp.ErrCode.ERR_OK;
import static com.tencent.mm.opensdk.modelmsg.SendMessageToWX.Req.WXSceneSession;

public class RNArenaPayModule extends ReactContextBaseJavaModule implements IUiListener {

  private final ReactApplicationContext reactContext;

  private Handler mHandler ;

  public static RNArenaPayModule module;

  private Promise wxPayPromise;

  private Promise wxLoginPromise;

  //  QQ 登录回调
  private Promise QQLoginPromise;


  private IWXAPI wxApi;

  //  QQ 实例
  private Tencent mTencent;

  public RNArenaPayModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    RNArenaPayModule.module = this;
  }

  @Override
  public String getName() {
    return "RNArenaPay";
  }


  //  支付宝支付
  @ReactMethod
  public void aliPay(final ReadableMap data,final Promise promise){

    mHandler = new Handler() {
      public void handleMessage(Message msg) {
        Map<String,String> result = (Map<String,String>)msg.obj;
        String resultStatus = result.get("resultStatus");

        if(resultStatus == "9000"){
          promise.resolve(result.get("result"));
        }else {
          promise.reject("支付失败",result.get("result"));
        }
      };
    };


    Runnable payRunnable = new Runnable() {
      String payInfo = data.getString("payInfo");

      Activity activity = getCurrentActivity();
      @Override
      public void run() {
        PayTask alipay = new PayTask(activity);
        Map<String,String> result = alipay.payV2(payInfo,true);

        Message msg = new Message();
        msg.what = 12;
        msg.obj = result;
        mHandler.sendMessage(msg);
      }
    };
    // 必须异步调用
    Thread payThread = new Thread(payRunnable);
    payThread.start();
  }

  //  注册微信key
  @ReactMethod
  public void wechatRegister(final String appKey){

    final IWXAPI wxApi = WXAPIFactory.createWXAPI(this.reactContext, appKey,true);

    // 将该app注册到微信
    wxApi.registerApp(appKey);

    this.wxApi = wxApi;

  }

  //  QQ注册 appId
  @ReactMethod
  public void QQRegister(final String appId){
    mTencent = Tencent.createInstance(appId, reactContext);


  }


  //  QQ登录
  @ReactMethod
  public void QQLogin(Promise promise){

    this.QQLoginPromise = promise;
    Activity activity = getCurrentActivity();

    mTencent.login(activity,"all",this);
  }

  //  ======  QQ 回调方法 ==========
  @Override
  public void onComplete(Object o) {
    if(this.QQLoginPromise != null ){

      try{

        JSONObject resp = (JSONObject)o;
        WritableNativeMap map = new WritableNativeMap();
        map.putString("accessToken",resp.getString("access_token"));
        map.putString("openId",resp.getString("openid"));
        map.putString("expiresTime",resp.getLong("expires_time") + "");

        this.QQLoginPromise.resolve(map);
      }catch (Exception err){
        this.QQLoginPromise.reject("数据解释失败","数据解释失败");
      }

    }
  }

  @Override
  public void onError(UiError uiError) {
    this.QQLoginPromise.reject("QQ登录失败","QQ登录失败");

  }

  @Override
  public void onCancel() {
    this.QQLoginPromise.reject("用户取消登录","用户取消登录");

  }



  //  微信支付
  @ReactMethod
  public void wechatPay(ReadableMap data, Promise promise){
    if(wxApi == null){
      String str = "请先注册微信ID";
      promise.reject(str,str);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      promise.reject("未安装微信","未安装微信");
      return;
    }

    this.wxPayPromise = promise;
    String appid = data.getString("appid");

    PayReq request = new PayReq();
    request.appId = appid;//子商户appid
    request.partnerId = data.getString("partnerid");
    request.prepayId = data.getString("prepayid");
    request.packageValue = data.getString("package");
    request.nonceStr = data.getString("noncestr");
    request.timeStamp = data.getString("timestamp");
    request.sign = data.getString("sign");
    wxApi.sendReq(request);
  }

  /*微信支付结果 回调*/
  public void wxPayResuly(BaseResp resp){

    if (this.wxPayPromise == null){
      return;
    }

    int errCode = resp.errCode;

    if(errCode == 0){
      this.wxPayPromise.resolve("支付成功");
    }else {
      String error = errCode == -1 ? "支付错误" : "用户取消支付";
      this.wxPayPromise.reject(error,error);
    }
  }

  //  微信登录
  @ReactMethod
  public void wechatLogin(Promise promise){

    if(wxApi == null){
      String str = "请先注册微信ID";
      promise.reject(str,str);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      promise.reject("未安装微信","未安装微信");
      return;
    }


    this.wxLoginPromise = promise;

    final SendAuth.Req req = new SendAuth.Req();
    req.scope = "snsapi_userinfo";
    req.state = "wechat_sdk_demo_test";
    wxApi.sendReq(req);
  }


  /*微信登录结果 回调*/
  public void wxLoginResuly(SendAuth.Resp resp){

    if (this.wxLoginPromise == null){
      return;
    }
    int errCode = resp.errCode;

    if(errCode == ERR_OK){
      WritableNativeMap map = new WritableNativeMap();
      map.putString("code",resp.code);
      map.putString("state",resp.state);
      this.wxLoginPromise.resolve(map);
    }else {
      String error = errCode == -2 ? "用户取消" : "用户拒绝";
      this.wxLoginPromise.reject(error,error);
    }
  }



  //  分享文字
  @ReactMethod
  public void wxShareText(ReadableMap data,  Promise promise){

    if(wxApi == null){
      String str = "请先注册微信ID";
      promise.reject(str,str);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      promise.reject("未安装微信","未安装微信");
      return;
    }

    String text = data.getString("text");

    //初始化一个 WXTextObject 对象，填写分享的文本内容
    WXTextObject textObj = new WXTextObject();
    textObj.text = text;

    //用 WXTextObject 对象初始化一个 WXMediaMessage 对象
    WXMediaMessage msg = new WXMediaMessage();
    msg.mediaObject = textObj;
    msg.description = text;

    SendMessageToWX.Req req = new SendMessageToWX.Req();
    req.transaction = text;
    req.message = msg;
    req.scene = data.getInt("scene");
    //调用api接口，发送数据到微信
    wxApi.sendReq(req);
  }



  //  分享图片
  @ReactMethod
  public void wxShareImage(ReadableMap data,  Promise promise){

    if(wxApi == null){
      String str = "请先注册微信ID";
      promise.reject(str,str);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      promise.reject("未安装微信","未安装微信");
      return;
    }

    //初始化 WXImageObject 和 WXMediaMessage 对象
    WXImageObject imgObj = new WXImageObject();
    imgObj.imagePath = data.getString("imageFile");
    WXMediaMessage msg = new WXMediaMessage();
    msg.mediaObject = imgObj;

    //构造一个Req
    SendMessageToWX.Req req = new SendMessageToWX.Req();
    req.message = msg;
    req.scene = data.getInt("scene");
    //调用api接口，发送数据到微信
    wxApi.sendReq(req);
  }


  //  分享网页
  @ReactMethod
  public void wxShareUrl(ReadableMap data,  Promise promise){

    if(wxApi == null){
      String str = "请先注册微信ID";
      promise.reject(str,str);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      promise.reject("未安装微信","未安装微信");
      return;
    }

    //初始化一个WXWebpageObject，填写url
    WXWebpageObject webpage = new WXWebpageObject();
    webpage.webpageUrl = data.getString("webpageUrl");

    //用 WXWebpageObject 对象初始化一个 WXMediaMessage 对象
    WXMediaMessage msg = new WXMediaMessage(webpage);
    msg.title = data.getString("title");
    msg.description = data.getString("description");

    try{
      String url = data.getString("thumbImageUrl");
      msg.thumbData = loadRawDataFromURL(url);
    }catch (Exception e){
      System.out.println("缩略图地址有误");
    }

    //构造一个Req
    SendMessageToWX.Req req = new SendMessageToWX.Req();
    req.message = msg;
    req.scene = data.getInt("scene");

    //调用api接口，发送数据到微信
    wxApi.sendReq(req);
  }



  //  分享小程序
  @ReactMethod
  public void wxShareMiniProgram(ReadableMap data,  Promise promise){

    if(wxApi == null){
      String str = "请先注册微信ID";
      promise.reject(str,str);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      promise.reject("未安装微信","未安装微信");
      return;
    }

    WXMiniProgramObject miniProgramObj = new WXMiniProgramObject();
    miniProgramObj.webpageUrl = data.getString("webpageUrl"); // 兼容低版本的网页链接
    miniProgramObj.userName = data.getString("userName");     // 小程序原始id
    miniProgramObj.path = data.getString("path");            //小程序页面路径
    //    public static final int MINIPTOGRAM_TYPE_RELEASE = 0;
//    public static final int MINIPROGRAM_TYPE_TEST = 1;
//    public static final int MINIPROGRAM_TYPE_PREVIEW = 2;
    miniProgramObj.miniprogramType = data.getInt("miniProgramType");
    WXMediaMessage msg = new WXMediaMessage(miniProgramObj);
    msg.title = data.getString("title");                    // 小程序消息title
    msg.description = data.getString("description");               // 小程序消息desc
    try{
      String url = data.getString("thumbImageUrl");
      msg.thumbData = loadRawDataFromURL(url); // 小程序消息封面图片，小于128k
    }catch (Exception e){
      System.out.println("缩略图地址有误");
    }

    SendMessageToWX.Req req = new SendMessageToWX.Req();
    req.message = msg;
    req.scene = WXSceneSession; // 目前只支持会话
    wxApi.sendReq(req);
  }


  /*微信分享 回调*/
  public void wxShareResuly(BaseResp resp){

    if (this.wxPayPromise == null){
      return;
    }

    int errCode = resp.errCode;

    if(errCode == 0){
      this.wxPayPromise.resolve("分享成功");
    }else{
      String error = "分享成功";
      this.wxPayPromise.reject(error,error);
    }
  }



  /**
   * 根据图片的url路径获得Bitmap对象
   * @param url
   * @return
   */
  private Bitmap getBitmap(String url) {
    URL fileUrl = null;
    Bitmap bitmap = null;

    try {
      fileUrl = new URL(url);
    } catch (MalformedURLException e) {
      e.printStackTrace();
    }

    try {
      HttpURLConnection conn = (HttpURLConnection) fileUrl
              .openConnection();
      conn.setDoInput(true);
      conn.connect();
      InputStream is = conn.getInputStream();
      bitmap = BitmapFactory.decodeStream(is);
      is.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return bitmap;
  }

  /*
   * url 转 byte
   *
   * */
  public static byte[] loadRawDataFromURL(String u) throws Exception {
    URL url = new URL(u);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();

    InputStream is = conn.getInputStream();
    BufferedInputStream bis = new BufferedInputStream(is);

    ByteArrayOutputStream baos = new ByteArrayOutputStream();

    final int BUFFER_SIZE = 2048;
    final int EOF = -1;

    int c;
    byte[] buf = new byte[BUFFER_SIZE];

    while (true) {
      c = bis.read(buf);
      if (c == EOF)
        break;

      baos.write(buf, 0, c);
    }

    conn.disconnect();
    is.close();

    byte[] data = baos.toByteArray();
    baos.flush();

    return data;
  }



}