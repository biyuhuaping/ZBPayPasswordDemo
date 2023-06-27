//
//  ViewController.m
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import "ViewController.h"
#import "ZBPayHeader.h"
#import "ZBPayPopupView.h"

@interface ViewController ()<ZBPayPopupViewDelegate>

@property (nonatomic, strong) UIButton *button;
//@property(nonatomic, strong) ZBPayPopupView *payView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.button];
}

- (void)buttonAction:(UIButton *)sender {
    //防止短时间重复点击
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    
    ZBPayPopupView *payView = [[ZBPayPopupView alloc]init];
    payView.delegate = self;
    [payView showPayView];
}

#pragma mark - ZBPayPopupViewDelegate
- (void)didClickForgetPasswordButton {
    NSLog(@"点击了忘记密码");
}

- (void)payPopupView:(ZBPayPopupView *)payView didPasswordInputFinished:(NSString *)password {
    if ([password isEqualToString:@"456789"]) {
        NSLog(@"输入的密码正确");
    } else {
        NSLog(@"输入错误:%@",password);
        [payView didInputPayPasswordError];
    }
}

#pragma mark - Getter/Setter

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        _button.frame = CGRectMake(100, 200, kScreenWidth - 2 * 100, 50);
        [_button setTitle:@"点击显示交易密码输入" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end
