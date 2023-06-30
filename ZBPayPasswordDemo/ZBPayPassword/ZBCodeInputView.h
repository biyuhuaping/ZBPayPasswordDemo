//
//  ZBCodeInputView.h
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBCodeInputView : UIView

/// 验证码长度,默认`6`
@property (nonatomic, assign) NSInteger length;
/// 键盘类型,默认`UIKeyboardTypeNumberPad`
@property (nonatomic, assign) UIKeyboardType keyboardType;
/// 验证码输入完毕后的回调
@property (nonatomic, copy) void(^didInputCompletionBlock)(NSString *verifycode);
/// 文本框高亮颜色,默认(30,144,255)
@property (nonatomic, strong) UIColor *focusColor;
/// 获取用户输入的验证码
@property (nonatomic, copy, readonly) NSString *verifycode;


@end

NS_ASSUME_NONNULL_END
