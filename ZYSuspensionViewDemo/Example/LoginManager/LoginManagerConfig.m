//
//  LoginManagerConfig.m
//  ZYSuspensionViewDemo
//
//  GitHub https://github.com/ripperhe
//  Created by ripper on 2017/3/7.
//  Copyright © 2017年 ripper. All rights reserved.
//

#import "LoginManagerConfig.h"

@interface LoginManagerConfig ()<ZYLoginManagerDelegate>

@end

@implementation LoginManagerConfig

static LoginManagerConfig *_instance;

+ (instancetype)shareInstance
{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[LoginManagerConfig alloc] init];
        });
    }
    return _instance;
}

+ (void)setupLoginManager
{
    // delegate (required)
    [ZYLoginManager shareInstance].delegate = [LoginManagerConfig shareInstance];
    
    //You should check if you are logged in, and you don't need to show this view if you have logged in.
    BOOL isLoggedIn = NO;
    if (!isLoggedIn) {
        [ZYLoginManager showSuspensionView];
    }
    
    // permanet account info
    // beta
    NSDictionary *betaAccountDic = @{
                                     @"h1-beta":@"11111-beta",
                                     @"h2-beta":@"22222-beta",
                                     @"h3-beta":@"33333-beta",
                                     @"h4-beta":@"44444-beta",
                                     @"h5-beta":@"55555-beta",
                                     };
    [ZYLoginManager setupPermanentAccountInfoDic:betaAccountDic isBeta:YES];
    
    // official
    NSDictionary *officialAccountDic = @{
                                         @"h1-official":@"11111-official",
                                         @"h2-official":@"22222-official",
                                         @"h3-official":@"33333-official",
                                         @"h4-official":@"44444-official",
                                         @"h5-official":@"55555-official",
                                         };
    [ZYLoginManager setupPermanentAccountInfoDic:officialAccountDic isBeta:NO];
    
    // permanet account infos won't write in the sandbox
    NSLog(@"sandbox cache path : \n%@", [ZYLoginManager accountInfoPlistPath]);
}

#pragma mark - ZYLoginManagerDelegate
- (void)loginManager:(ZYLoginManager *)loginManager loginWithAccout:(NSString *)account password:(NSString *)password
{
//    NSLog(@"LoginManagerConfig  accout : %@   password : %@", account, password);
    
    // write the method to login.
    
    UIViewController *currentVC = [ZYLoginManager currentViewControllerWithWindow:nil];
    
    Class VC3Class = NSClassFromString(@"ViewController3");
    Class LoginVCClass = NSClassFromString(@"LoginViewController");
    
    if (VC3Class && [currentVC isKindOfClass:VC3Class]) {
        
        // go to login vc
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [currentVC performSelector:@selector(goToTestLogin:) withObject:nil];
#pragma clang diagnostic pop
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // run login method
            UIViewController *vc = [ZYLoginManager currentViewControllerWithWindow:nil];
            if ([vc isKindOfClass:LoginVCClass]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                [vc performSelector:@selector(sendLoginRequestWithAccount:password:) withObject:account withObject:password];
#pragma clang diagnostic pop
            }
        });
        
    }else if (LoginVCClass && [currentVC isKindOfClass:LoginVCClass]) {
        
        // run login method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [currentVC performSelector:@selector(sendLoginRequestWithAccount:password:) withObject:account withObject:password];
#pragma clang diagnostic pop
        
    }else{
        NSLog(@"can't login at here.");
    }
}

//- (UIView *)loginManagerLoginTableHeaderView:(ZYLoginManager *)loginManager
//{
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    v.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.6];
//    return v;
//}

//- (BOOL)loginManagerIsGetBetaAccountInfos:(ZYLoginManager *)loginManager
//{
//    return NO;
//}

@end
