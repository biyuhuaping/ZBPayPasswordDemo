//
//  ZBPayPasswordView.m
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#import "ZBPayPasswordView.h"
#import "ZBPayHeader.h"

#define kZJPasswordBoxWidth 44 //输入框大小
#define kZJPasswordBoxSpace 10 //输入框间隔
#define kZJPasswordBoxNumber 6 //输入框个数

@interface ZBPayPasswordView ()<UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray <UILabel*> *labelBoxArray;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *currentText;

@end

@implementation ZBPayPasswordView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, kScreenWidth, 50);
        [self addSubview:self.textField];
        [self.textField becomeFirstResponder];
        [self initData];
    }
    return self;
}

- (void)initData {
    self.currentText = @"";
    CGFloat x = kScreenWidth - (kZJPasswordBoxWidth * kZJPasswordBoxNumber) - (kZJPasswordBoxSpace * (kZJPasswordBoxNumber-1));
    for (int i = 0; i < kZJPasswordBoxNumber; i ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x/2 + i * (kZJPasswordBoxWidth + kZJPasswordBoxSpace), 0, kZJPasswordBoxWidth, kZJPasswordBoxWidth)];
        label.backgroundColor = ColorFromHex(0xE9E9E9);
//        label.layer.borderWidth = 0.5f;
//        label.layer.borderColor = ColorFromHex(0xCCCCCC).CGColor;
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
        [self addSubview:label];
        
        [self.labelBoxArray addObject:label];
    }
}

//晃动动画
- (void)startShakeViewAnimation {
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    shake.values = @[@0,@-10,@10,@-10,@0];
    shake.additive = YES;
    shake.duration = 0.25;
    [self.layer addAnimation:shake forKey:@"shake"];
}

- (void)textDidChanged:(UITextField *)textField {
//    if (textField.text.length > kZJPasswordBoxNumber) {
//        textField.text = [textField.text substringToIndex:kZJPasswordBoxNumber];
//    }
    
    [self updateLabelBoxWithText:textField.text];
    if (self.textDidChangedBlock){
        self.textDidChangedBlock();
    }
    if (textField.text.length == kZJPasswordBoxNumber) {
        if (self.completionBlock) {
            self.completionBlock(self.textField.text);
        }
    }
}

#pragma mark - Public

- (void)updateLabelBoxWithText:(NSString *)text {
    //输入时
    if (text.length > self.currentText.length) {
        for (int i = 0; i < kZJPasswordBoxNumber; i++) {
            UILabel *label = self.labelBoxArray[i];
            if (i < text.length - 1) {
                //特殊字符不居中显示，设置文本向下偏移
                NSAttributedString * att1 = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSBaselineOffsetAttributeName:@(-3)}];
                label.attributedText = att1;
            }
            else if (i == text.length - 1) {
                label.text = [text substringWithRange:NSMakeRange(i, 1)];
                [self animationShowTextInLabel: label];
            } else {
                label.text = @"";
            }
        }
    }
    //删除时
    else {
        for (int i = 0; i < kZJPasswordBoxNumber; i++) {
            UILabel *label = self.labelBoxArray[i];
            if (i < text.length) {
                //特殊字符不居中显示，设置文本向下偏移
                NSAttributedString * att1 = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSBaselineOffsetAttributeName:@(-3)}];
                label.attributedText = att1;
            } else {
                label.text = @"";
            }
        }
    }
    self.textField.text = text;
    self.currentText = text;
}

- (void)animationShowTextInLabel:(UILabel *)label {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //特殊字符不居中显示，设置文本向下偏移
        NSAttributedString *att1 = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSBaselineOffsetAttributeName:@(-3)}];
        label.attributedText = att1;
//    });
}

//输入错误
- (void)didInputPasswordError {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startShakeViewAnimation];
        self.textField.text = @"";
        [self updateAllLabelTextToNone];
    });
}

- (void)updateAllLabelTextToNone {
    for (int i = 0; i < kZJPasswordBoxNumber; i++) {
        UILabel *label = self.labelBoxArray[i];
        label.text = @"";
    }
}

- (void)transformTextInTextField:(UITextField *)textField {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        textField.text = @"●";
//    });
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Getter/Setter
- (NSMutableArray *)labelBoxArray {
    if (!_labelBoxArray) {
        _labelBoxArray = [NSMutableArray array];
    }
    return _labelBoxArray;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        [_textField addTarget:self action:@selector(textDidChanged:) forControlEvents:UIControlEventEditingChanged];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.delegate = self;
    }
    return _textField;
}

@end
