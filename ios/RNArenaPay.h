
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import "AppPayManager.h"
#import "AliPayManager.h"
#import "WXPayManager.h"

@interface RNArenaPay : NSObject <RCTBridgeModule>

@end
  
