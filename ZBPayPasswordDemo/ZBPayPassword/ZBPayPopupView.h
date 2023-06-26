//
//  ZBPayPopupView.h
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZBPayPopupViewDelegate <NSObject>

- (void)didClickForgetPasswordButton;

- (void)didPasswordInputFinished:(NSString *)password;

@end

@interface ZBPayPopupView : UIView

@property (nonatomic, weak) id <ZBPayPopupViewDelegate> delegate;

//+ (instancetype)showPayView;
- (void)showPayView;
- (void)hidePayView;
- (void)didInputPayPasswordError;

@end

NS_ASSUME_NONNULL_END
