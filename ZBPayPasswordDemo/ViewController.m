//
//  ViewController.m
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import "ViewController.h"
#import "ZBPayHeader.h"
#import "ZBPayPopupView.h"
#import "ZBCodeInputView.h"
#import "ZBAuthID.h"

@interface ViewController ()<ZBPayPopupViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UILabel *logLab;
@property (strong, nonatomic) IBOutlet UISwitch *mySwitch;
@property (nonatomic, assign) BOOL isSwitching;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"isUsedAuthID"];
}

- (void)configLockView{
    // 生物识别
    BOOL isAuthID = [[NSUserDefaults standardUserDefaults] boolForKey:@"isUsedAuthID"];
    if (isAuthID) {//如果开启了生物识别：就优先用生物识别验证
        [self authIDVerificationSwitchState:isAuthID];
    }
    
    //判断设备支持生物解锁类型
    NSInteger biometryType = [[ZBAuthID sharedInstance] checkBiometryType];
    if (!isAuthID) {//如果未开启生物识别，button1：忘记密码
        [self.button1 setTitle:@"密码解锁" forState:UIControlStateNormal];
    }else if (biometryType == 1){//根据生物类型，显示button1：1 Touch ID指纹、2面部解锁
        [self.button1 setTitle:@"指纹解锁" forState:UIControlStateNormal];
    }else if (biometryType == 2){//2面部解锁
        [self.button1 setTitle:@"面容解锁" forState:UIControlStateNormal];
    }
}

- (IBAction)buttonAction:(UIButton *)sender {
//    [self.view endEditing:YES];
    //防止短时间重复点击
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    
    ZBPayPopupView *payView = [[ZBPayPopupView alloc]init];
    payView.delegate = self;
    [payView showPayView];
}

- (IBAction)button1Action:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"密码解锁"]) {
        [self buttonAction:self.button];
    }else{//指纹解锁、面容解锁
        self.logLab.text = @"";
        [self authIDVerificationSwitchState:YES];
    }
}

- (IBAction)switchChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"isUsedAuthID"];
    self.isSwitching = YES;
    [self configLockView];
}

//生物解锁
- (void)authIDVerificationSwitchState:(BOOL)gestureState {
    [[ZBAuthID sharedInstance]showAuthIDWithDescribe:nil isShowPw:NO block:^(ZBAuthIDState state, NSError * _Nonnull error) {
        if (state == ZBAuthIDStateNotSupport) { // 不支持TouchID/FaceID
            NSLog(@"对不起，当前设备不支持指纹/面容ID");
            self.logLab.text = @"当前设备不支持指纹/面容ID";
        } else if(state == ZBAuthIDStateFail) { // 认证失败
            NSLog(@"验证失败");
            self.logLab.text = @"验证失败";
            if (self.isSwitching){
                self.mySwitch.on = NO;
                [self.button1 setTitle:@"密码解锁" forState:UIControlStateNormal];
            }
        } else if(state == ZBAuthIDStateUserCancel) {//被用户取消
            self.logLab.text = @"被用户取消";
            if (self.isSwitching){
                self.mySwitch.on = NO;
                [self.button1 setTitle:@"密码解锁" forState:UIControlStateNormal];
            }
        } else if (state == ZBAuthIDStateSuccess) { // TouchID/FaceID验证成功
            NSLog(@"验证成功");
            self.logLab.text = @"验证成功";
            //开启生物识别
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUsedAuthID"];
            NSInteger biometryType = [[ZBAuthID sharedInstance] checkBiometryType];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((biometryType-1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
            });
        }
    }];
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

@end
