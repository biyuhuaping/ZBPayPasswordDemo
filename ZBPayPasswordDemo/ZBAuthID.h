//
//  ZBAuthID.h
//  DeRong
//
//  Created by 周博 on 2018/11/10.
//  Copyright © 2018 周博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

typedef NS_ENUM(NSUInteger, ZBAuthIDState){
    /// 当前设备不支持TouchID/FaceID
    ZBAuthIDStateNotSupport = 0,
    /// TouchID/FaceID 验证成功
    ZBAuthIDStateSuccess = 1,
    /// TouchID/FaceID 验证失败
    ZBAuthIDStateFail = 2,
    /// TouchID/FaceID 被用户手动取消
    ZBAuthIDStateUserCancel = 3,
    /// 用户不使用TouchID/FaceID,选择手动输入密码
    ZBAuthIDStateInputPassword = 4,
    /// TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)
    ZBAuthIDStateSystemCancel = 5,
    /// TouchID/FaceID 无法启动,因为用户没有设置密码
    ZBAuthIDStatePasswordNotSet = 6,
    /// TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID
    ZBAuthIDStateTouchIDNotSet = 7,
    /// TouchID/FaceID 无效
    ZBAuthIDStateTouchIDNotAvailable = 8,
    /// TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)
    ZBAuthIDStateTouchIDLockout = 9,
    /// 当前软件被挂起并取消了授权 (如App进入了后台等)
    ZBAuthIDStateAppCancel = 10,
    /// 当前软件被挂起并取消了授权 (LAContext对象无效)
    ZBAuthIDStateInvalidContext = 11,
    /// 系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)
    ZBAuthIDStateVersionNotSupport = 12
};

@interface ZBAuthID : LAContext

typedef void (^ZBAuthIDStateBlock)(ZBAuthIDState state, NSError *error);

+ (instancetype)sharedInstance;

/// 使用canEvaluatePolicy 判断设备支持生物解锁类型
/// @return biometryType
- (NSInteger)checkBiometryType;

/// 启动TouchID/FaceID进行验证
/// @param describe TouchID/FaceID显示的描述
/// @param show 错误两次或锁定后, 是否弹出输入密码界面
/// @param block 回调状态的block
- (void)showAuthIDWithDescribe:(NSString *)describe isShowPw:(BOOL)show block:(ZBAuthIDStateBlock)block;

@end
