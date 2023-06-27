//
//  ZBPayPopupView.h
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZBPayPopupView;
@protocol ZBPayPopupViewDelegate <NSObject>

/// 忘记密码
- (void)didClickForgetPasswordButton;

/// 输入结束
- (void)payPopupView:(ZBPayPopupView *)payView didPasswordInputFinished:(NSString *)password;

@end

@interface ZBPayPopupView : UIView

@property (nonatomic, weak) id <ZBPayPopupViewDelegate> delegate;

//+ (instancetype)showPayView;
- (void)showPayView;
- (void)hidePayView;
- (void)didInputPayPasswordError;

@end

NS_ASSUME_NONNULL_END
