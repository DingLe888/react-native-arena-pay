package net.sourceforge.simcpux.wxapi;

import com.dingle.pay.RNArenaPayModule;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import static com.tencent.mm.opensdk.constants.ConstantsAPI.COMMAND_LAUNCH_BY_WX;
import static com.tencent.mm.opensdk.constants.ConstantsAPI.COMMAND_PAY_BY_WX;
import static com.tencent.mm.opensdk.constants.ConstantsAPI.COMMAND_SENDAUTH;
import static com.tencent.mm.opensdk.constants.ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler {
	
	private static final String TAG = "MicroMsg.SDKSample.WXPayEntryActivity";

    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

//    	api = WXAPIFactory.createWXAPI(this, Constants.APP_ID);
//        api.handleIntent(getIntent(), this);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
//        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
	}

	@Override
	public void onResp(BaseResp resp) {

		if(resp.getType()==COMMAND_PAY_BY_WX){
			//			支付
			RNArenaPayModule.module.wxPayResuly(resp);

		}else if(resp.getType()==COMMAND_SENDAUTH){

			SendAuth.Resp s = (SendAuth.Resp)resp;
			//			登录
			RNArenaPayModule.module.wxLoginResuly(s);

		}if(resp.getType()==COMMAND_SENDMESSAGE_TO_WX){
			//			分享
			RNArenaPayModule.module.wxPayResuly(resp);

		}

	}
}