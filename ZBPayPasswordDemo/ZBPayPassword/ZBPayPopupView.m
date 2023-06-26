//
//  ZBPayPopupView.m
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import "ZBPayPopupView.h"
#import "ZBPayPasswordView.h"
#import "ZBPayHeader.h"
#import "Masonry.h"

#define kZJAnimationTimeInterval 0.25
#define kErrorCount 5 //最大错误次数

@interface ZBPayPopupView ()
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIView *payPopupView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *errorLab;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *forgetPasswordBtn;
@property(nonatomic, assign) int errorCount;//错误次数

@property (nonatomic, strong) ZBPayPasswordView *payPasswordView;

@end

@implementation ZBPayPopupView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self keyboardListen];
        self.backgroundColor = UIColor.whiteColor;
        [self createUI];
        self.errorCount = kErrorCount;
    }
    return self;
}

- (void)createUI {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.superView];
    [self.superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(window);
    }];

    [self.superView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.superView);
//        make.top.equalTo(self.superView.mas_bottom).offset(-200 -200 -kBottomSafeHeight);
        make.top.equalTo(self.superView.mas_bottom);
    }];
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(15);
        make.centerX.equalTo(self);
    }];
    
    [self addSubview:self.errorLab];
    [self.errorLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLab.mas_bottom).offset(15);
        make.left.right.centerX.equalTo(self);
    }];
    
    [self addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.centerY.equalTo(self.titleLab);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
    
    [self addSubview:self.payPasswordView];
    [self.payPasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.mas_top).offset(100);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    [self addSubview:self.forgetPasswordBtn];
    [self.forgetPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.centerY.equalTo(self.titleLab.mas_centerY);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
}

- (void)keyboardListen{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;   //height 就是键盘的高度
    NSLog(@"键盘高度：%d",height);
    
    [UIView animateWithDuration:kZJAnimationTimeInterval animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.superView.mas_bottom).offset(-200 -height);
        }];
        [self layoutIfNeeded];
        [self.superView layoutIfNeeded];//没有此句可能没有动画效果
    }];
}
 
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    
}

#pragma mark - Private
- (void)forgetPasswordAction {
    [self hidePayView];
    if ([self.delegate respondsToSelector:@selector(didClickForgetPasswordButton)]) {
        [self.delegate didClickForgetPasswordButton];
    }
}

#pragma mark - Public
//+ (instancetype)showPayView{
//    ZJPayPopupView *view = [[ZJPayPopupView alloc]init];
//    [view showPayView];
//    return view;
//}

- (void)showPayView {
    [UIView animateWithDuration:kZJAnimationTimeInterval animations:^{
        self.superView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    } completion:nil];
}

- (void)hidePayView {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [UIView animateWithDuration:kZJAnimationTimeInterval animations:^{
        self.superView.alpha = 0.0;
        self.frame = CGRectMake(self.frame.origin.x, kScreenHeight, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.superView removeFromSuperview];
        self.superView = nil;
    }];
}

- (void)didInputPayPasswordError {
    [self.payPasswordView didInputPasswordError];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.errorCount --;
        self.errorLab.hidden = NO;
        if (self.errorCount <= 0){
            self.errorLab.text = @"密码频繁错误已被锁定，请10分钟后重试或立即找回密码";
        }else{
            self.errorLab.text = [NSString stringWithFormat:@"支付密码错误，还有%d次机会",self.errorCount];
        }
//    });
}

#pragma mark -Setter/Getter

- (ZBPayPasswordView *)payPasswordView {
    if (!_payPasswordView) {
        _payPasswordView = [[ZBPayPasswordView alloc] init];
        __weak typeof(self) weakSelf = self;
        _payPasswordView.textDidChangedBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.errorLab.hidden = YES;
        };
        _payPasswordView.completionBlock = ^(NSString *password) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.delegate respondsToSelector:@selector(didPasswordInputFinished:)]) {
                [strongSelf.delegate didPasswordInputFinished:password];
            }
        };
    }
    return _payPasswordView;
}

- (UIView *)superView {
    if (!_superView) {
        _superView = [[UIView alloc] init];
        _superView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    return _superView;
}

- (UIView *)payPopupView {
    if (!_payPopupView) {
        _payPopupView = [[UIView alloc] init];
        _payPopupView.backgroundColor = UIColor.whiteColor;
    }
    return _payPopupView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.text = @"验证支付密码";
    }
    return _titleLab;
}

- (UILabel *)errorLab{
    if (!_errorLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = @"支付密码错误，还有4次机会";
        lab.textColor = UIColor.redColor;
        lab.hidden = YES;
        lab.numberOfLines = 0;
        _errorLab = lab;
    }
    return _errorLab;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(hidePayView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)forgetPasswordBtn {
    if (!_forgetPasswordBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [btn setTitleColor:ColorFromHex(0x00B377) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(forgetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
        _forgetPasswordBtn = btn;
    }
    return _forgetPasswordBtn;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
