//
//  ViewController.m
//  WebView
//
//  Created by Nasheng Yu on 2017/12/29.
//  Copyright © 2017年 Nasheng Yu. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSAndOCTask.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDK/ShareSDK.h>
#import <WXApi.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <WXApiObject.h>

#import <AlipaySDK/AlipaySDK.h>
#import "APAuthInfo.h"
#import "APRSASigner.h"

#import <MapKit/MapKit.h>
#import "ScanningViewController.h"
#import "CustomAccount.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#define screenWigth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
@interface ViewController ()<UIWebViewDelegate,TestJSObjectProtocol>
@property (nonatomic,strong)UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[NSURLCache sharedURLCache]removeAllCachedResponses];

    if (@available(iOS 11.0, *)) {
        _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, -20, screenWigth, screenHeight+20)];
    } else {
        _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenWigth, screenHeight)];
    }

    
    NSArray *cookies =[[NSUserDefaults standardUserDefaults]  objectForKey:@"cookies"];
    if (cookies != nil) {
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:[cookies objectAtIndex:0] forKey:NSHTTPCookieName];
        [cookieProperties setObject:[cookies objectAtIndex:1] forKey:NSHTTPCookieValue];
        [cookieProperties setObject:[cookies objectAtIndex:3] forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:[cookies objectAtIndex:4] forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]  setCookie:cookieuser];
    }
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status ==AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"网络连接不上");
        }else{
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xqy.jianxinnet.com/dk"]]];
        }}];
    
    _webView.delegate =self;
    _webView.scalesPageToFit =YES;
    [_webView setMediaPlaybackRequiresUserAction:NO];
    [self.view addSubview:_webView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPaySuccess) name:@"paySuccess" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxPayFails) name:@"payFails" object:nil];
//
    
    
//    UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
//    but.backgroundColor = [UIColor redColor];
//    [but addTarget:self action:@selector(callWeChat) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:but];
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"结束调用了");
    
    NSArray *nCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in nCookies){
        if ([cookie isKindOfClass:[NSHTTPCookie class]]){

            if ([cookie.name isEqualToString:@"PHPSESSID"]) {
                NSNumber *sessionOnly =[NSNumber numberWithBool:cookie.sessionOnly];
                NSNumber *isSecure = [NSNumber numberWithBool:cookie.isSecure];
                NSArray *cookies = [NSArray arrayWithObjects:cookie.name, cookie.value, sessionOnly, cookie.domain, cookie.path, isSecure, nil];
                [[NSUserDefaults standardUserDefaults] setObject:cookies forKey:@"cookies"];
                break;
            }
        }
    }
    
    
    
    JSContext *context =[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSAndOCTask *testJO=[JSAndOCTask new];
    __weak __typeof(&*self)blockSelf = self;
  
    context[@"testobject"] =testJO;
    
    
    [self savePhoto];
}






//跳转到微信

- (void)callWeChat {
    if([self isWeChatInstalled]) {
        NSString* qqUrl = [NSString stringWithFormat:@"weixin://"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:qqUrl]];
    }
    
}

- (BOOL)isWeChatInstalled{
    
    NSString*urlStr = [NSString stringWithFormat:@"weixin://"];
    
    NSURL*url = [NSURL URLWithString:urlStr];
    
    if([[UIApplication sharedApplication]canOpenURL:url]){
        
        return YES;
    }
    else{
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"尚未安装微信，请安装微信后重试" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
        
    }
    
}

- (UIImage *)screenshot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 保存图片到相册功能，ALAssetsLibraryiOS9.0 以后用photoliabary 替代，
-(void)savePhoto
{
    UIImage * image = [self captureImageFromView:self.view];
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:nil];
}

//截图功能
-(UIImage *)captureImageFromView:(UIView *)view
{
    CGRect screenRect = [view bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
