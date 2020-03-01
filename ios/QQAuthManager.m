//
//  QQAuthManager.m
//  RNArenaPay
//
//  Created by 丁乐 on 2020/3/1.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "QQAuthManager.h"


@interface QQAuthManager ()<TencentSessionDelegate>

@property(nonatomic,strong)TencentOAuth * tencentOAuth;

//  成功的回调
@property (nonatomic,copy)RCTPromiseResolveBlock success;

//  失败的回调
@property (nonatomic,copy)RCTPromiseRejectBlock faild;

@end

@implementation QQAuthManager


static QQAuthManager *instance = nil;

+(instancetype)shareInstance{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[QQAuthManager alloc]init];
        }
    }
    return instance;
}

/// 设置QQ的ID
-(void)setQQAppId:(NSString *)key{
    TencentOAuth * tencentOAuth = [[TencentOAuth alloc] initWithAppId:key andDelegate:self ];
    [self setTencentOAuth:tencentOAuth];
}

/// qq登录
-(void)QQLogin:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild{
    
    self.success = success;
    self.faild = faild;
    
    NSArray *_permissions = [NSArray arrayWithObjects:@"get_user_info", nil] ;
    [self.tencentOAuth authorize:_permissions inSafari:NO];
}

///登录成功：
-(void)tencentDidLogin{
    
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length])
    {
        // 记录登录用户的OpenID、Token以及过期时间
        long inteval = [self.tencentOAuth.expirationDate timeIntervalSince1970] * 1000;
        NSString *expiresTime = [NSString stringWithFormat:@"%ld",inteval]; self.success(@{@"accessToken":self.tencentOAuth.accessToken,@"openId":self.tencentOAuth.openId,@"expiresTime":expiresTime});
    }
    else
    {
        self.faild(@"登录不成功 没有获取accesstoken", @"登录不成功 没有获取accesstoken", nil);
    }
}


///  非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        self.faild(@"用户取消登录", @"用户取消登录", nil);
    }
    else
    {
        self.faild(@"登录失败", @"登录失败", nil);
    }
}

//  网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    self.faild(@"无网络连接，请设置网络", @"无网络连接，请设置网络", nil);
}


@end
