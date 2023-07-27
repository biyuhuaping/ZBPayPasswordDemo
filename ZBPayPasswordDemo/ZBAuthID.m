//
//  ZBAuthID.m
//  DeRong
//
//  Created by 周博 on 2018/11/10.
//  Copyright © 2018 周博. All rights reserved.
//

#import "ZBAuthID.h"

#define iPhoneX (UIScreen.mainScreen.bounds.size.width >= 375.f && UIScreen.mainScreen.bounds.size.height >= 812.f)

@implementation ZBAuthID

+ (instancetype)sharedInstance {
    static ZBAuthID *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZBAuthID alloc] init];
    });
    return instance;
}

/**
 使用canEvaluatePolicy 判断设备支持生物解锁类型
 @return biometryType
 */
- (NSInteger)checkBiometryType{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    int biometryType = 0;//0:不支持生物解锁    1:Touch ID  2:面容ID
    if ([context canEvaluatePolicy: LAPolicyDeviceOwnerAuthentication error:&error]) {
        if (!error){
            if (@available(iOS 11, *)) {
                if (context.biometryType == LABiometryTypeFaceID) {
                    biometryType = 2;
                    NSLog(@"FaceID");
                } else if (context.biometryType == LABiometryTypeTouchID) {
                    biometryType = 1;
                    NSLog(@"TouchID");
                } else {//不支持生物解锁
                    biometryType = 0;
                }
            } else {//iOS 11之前不需要判断 biometryType,只有TouchID
                biometryType = 1;
                NSLog(@"TouchID");
            }
        }
    }
    return biometryType;
}

- (void)showAuthIDWithDescribe:(NSString *)describe isShowPw:(BOOL)show block:(ZBAuthIDStateBlock)block {
    if(!describe) {
        if(iPhoneX){
            describe = @"验证已有面容";
        }else{
            describe = @"通过Home键验证已有指纹";
        }
    }
    
    LAContext *context = [[LAContext alloc] init];
    // 认证失败提示信息，为 @"" 则不提示
    context.localizedFallbackTitle = @"";//@"输入密码";
    
    NSError *error = nil;
    LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
    if (!show) {
        policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    }
    // LAPolicyDeviceOwnerAuthenticationWithBiometrics: 用TouchID/FaceID验证
    // LAPolicyDeviceOwnerAuthentication: 用TouchID/FaceID或密码验证, 默认是错误两次或锁定后, 弹出输入密码界面（本案例使用）
    if ([context canEvaluatePolicy:policy error:&error]) {
        [context evaluatePolicy:policy localizedReason:describe reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID/FaceID 验证成功");
                    block(ZBAuthIDStateSuccess, error);
                });
            }else if(error){
                if (@available(iOS 11.0, *)) {
                    switch (error.code) {
                        case LAErrorAuthenticationFailed:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 验证失败");
                                block(ZBAuthIDStateFail, error);
                            });
                            break;
                        }
                        case LAErrorUserCancel:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 被用户手动取消");
                                block(ZBAuthIDStateUserCancel, error);
                            });
                        }
                            break;
                        case LAErrorUserFallback:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"用户不使用TouchID/FaceID,选择手动输入密码");
                                block(ZBAuthIDStateInputPassword, error);
                            });
                        }
                            break;
                        case LAErrorSystemCancel:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                                block(ZBAuthIDStateSystemCancel, error);
                            });
                        }
                            break;
                        case LAErrorPasscodeNotSet:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置密码");
                                block(ZBAuthIDStatePasswordNotSet, error);
                            });
                        }
                            break;
                            //case LAErrorTouchIDNotEnrolled:{
                        case LAErrorBiometryNotEnrolled:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID");
                                block(ZBAuthIDStateTouchIDNotSet, error);
                            });
                        }
                            break;
                            //case LAErrorTouchIDNotAvailable:{
                        case LAErrorBiometryNotAvailable:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 无效");
                                block(ZBAuthIDStateTouchIDNotAvailable, error);
                            });
                        }
                            break;
                            //case LAErrorTouchIDLockout:{
                        case LAErrorBiometryLockout:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
                                block(ZBAuthIDStateTouchIDLockout, error);
                            });
                        }
                            break;
                        case LAErrorAppCancel:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                                block(ZBAuthIDStateAppCancel, error);
                            });
                        }
                            break;
                        case LAErrorInvalidContext:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                                block(ZBAuthIDStateInvalidContext, error);
                            });
                        }
                            break;
                        default:
                            break;
                    }
                } else {
                    // iOS 11.0以下的版本只有 TouchID 认证
                    switch (error.code) {
                        case LAErrorAuthenticationFailed:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 验证失败");
                                block(ZBAuthIDStateFail, error);
                            });
                            break;
                        }
                        case LAErrorUserCancel:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 被用户手动取消");
                                block(ZBAuthIDStateUserCancel, error);
                            });
                        }
                            break;
                        case LAErrorUserFallback:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"用户不使用TouchID,选择手动输入密码");
                                block(ZBAuthIDStateInputPassword, error);
                            });
                        }
                            break;
                        case LAErrorSystemCancel:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                                block(ZBAuthIDStateSystemCancel, error);
                            });
                        }
                            break;
                        case LAErrorPasscodeNotSet:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 无法启动,因为用户没有设置密码");
                                block(ZBAuthIDStatePasswordNotSet, error);
                            });
                        }
                            break;
                        case LAErrorTouchIDNotEnrolled:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                                block(ZBAuthIDStateTouchIDNotSet, error);
                            });
                        }
                            break;
                            //case :{
                        case LAErrorTouchIDNotAvailable:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 无效");
                                block(ZBAuthIDStateTouchIDNotAvailable, error);
                            });
                        }
                            break;
                        case LAErrorTouchIDLockout:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
                                block(ZBAuthIDStateTouchIDLockout, error);
                            });
                        }
                            break;
                        case LAErrorAppCancel:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                                block(ZBAuthIDStateAppCancel, error);
                            });
                        }
                            break;
                        case LAErrorInvalidContext:{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                                block(ZBAuthIDStateInvalidContext, error);
                            });
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"当前设备不支持TouchID/FaceID");
            block(ZBAuthIDStateNotSupport, error);
        });
    }
}

- (void)fingerVerification {
    //IOS11之后如果支持faceId也是走同样的逻辑，faceId和TouchId只能选一个
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持 localizedReason为alert弹框的message内容
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请验证已有指纹" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"验证通过");
            } else {
                NSLog(@"验证失败:%@",error.description);
                switch (error.code) {
                    case LAErrorSystemCancel: {
                        NSLog(@"系统取消授权，如其他APP切入");
                        //系统取消授权，如其他APP切入
                        break;
                    }
                    case LAErrorUserCancel: {
                        //用户取消验证Touch ID
                        NSLog(@"用户取消验证Touch ID");
                        break;
                    }
                    case LAErrorAuthenticationFailed: {
                        //授权失败
                        NSLog(@"授权失败");
                        break;
                    }
                    case LAErrorPasscodeNotSet: {
                        //系统未设置密码
                        NSLog(@"系统未设置密码");
                        break;
                    }
                    case LAErrorBiometryNotAvailable: {
                        //设备Touch ID不可用，例如未打开
                        NSLog(@"设备Touch ID不可用，例如未打开");
                        break;
                    }
                    case LAErrorBiometryNotEnrolled: {
                        //设备Touch ID不可用，用户未录入
                        NSLog(@"设备Touch ID不可用，用户未录入");
                        break;
                    }
                    case LAErrorUserFallback: {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                            NSLog(@"用户选择输入密码，切换主线程处理");
                            
                        }];
                        break;
                    }
                    default: {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                            NSLog(@"其他情况，切换主线程处理");
                        }];
                        break;
                    }
                }
            }
        }];
    } else {
        NSLog(@"不支持指纹识别");
        NSLog(@"error : %@",error.localizedDescription);
    }
}


@end
