//
//  ZBPayPasswordView.h
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBPayPasswordView : UIView

/// 输入变化
@property (nonatomic,copy) void(^textDidChangedBlock)(void);
/// 输入结束
@property (nonatomic,copy) void(^completionBlock)(NSString *password);

/// 更新输入框数据
- (void)updateLabelBoxWithText:(NSString *)text;

/// 抖动输入框
- (void)startShakeViewAnimation;

/// 输入错误
- (void)didInputPasswordError;

@end

NS_ASSUME_NONNULL_END
