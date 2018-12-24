//
//  JSAndOCTask.h
//  WebView
//
//  Created by 俞乃胜 on 2017/12/29.
//  Copyright © 2017年 Nasheng Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <MapKit/MapKit.h>
@protocol TestJSObjectProtocol <JSExport>

//微信分享
- (void)share:(NSString *)link AndImg:(NSString *)img AndDesc:(NSString *)desc AndTitle:(NSString *)title;

//支付宝支付
- (void)webapp_alipay:(NSString *)url;

//微信支付
- (void)wxpay:(NSString *)ID;

//微信分享
- (void)wxshare:(NSString *)ID;

- (void)scan;

- (void)startLocation;

- (void)dhmap:(NSString *)lacation;

@end
@interface JSAndOCTask : NSObject <TestJSObjectProtocol>

@property (nonatomic,copy)void (^wxshare)(NSString *txt);

@property (nonatomic,copy)void (^apiPayBlock)(NSString *url);

@property (nonatomic,copy)void (^wxPayBlok)(NSString *oid);

@property (nonatomic,copy)void (^scanBlok)(void);

@property (nonatomic,copy)void (^startLocationBlok)(void);

@property (nonatomic,copy)void (^dhmap)(CLLocationCoordinate2D location);
@end
