//
//  ZBCodeInputView.m
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/29.
//

#import "ZBCodeInputView.h"

@interface ZBCodeInputView () <UITextFieldDelegate>

@property(nonatomic, strong) UIStackView *stackView;
@property(nonatomic, strong) UITextField *textField;

@end


@implementation ZBCodeInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateInputIndicator];
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self updateInputIndicator];
    if (self.textField.isEditing && textField.text.length == self.length) {
        if (self.didInputCompletionBlock) {
            self.didInputCompletionBlock(textField.text);
        }
        // 收起键盘并回调block
        [self.textField resignFirstResponder];
    }
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField.text.length == self.length && self.didInputCompletionBlock) {
//        self.didInputCompletionBlock(textField.text);
//    }
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length == 0) { // Add.
        if (textField.text.length == self.length) {
            return NO;
        }
        NSString *regexp = @"^[A-Za-z0-9]{1}$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];
        return [predicate evaluateWithObject:string];
    }
    return YES;
}

#pragma mark - Private
- (void)setup {
    [self addSubviewToFill:self.stackView];
    [self addSubviewToFill:self.textField];
        
    [self.textField becomeFirstResponder];
    [self setLength:6];
}

/// 更新输入指示器状态
- (void)updateInputIndicator {
    NSString *text = self.textField.text;
    for (NSInteger idx = 0; idx < self.length; idx++) {
        UILabel *label = (UILabel *)self.stackView.arrangedSubviews[idx];
        if (text.length && idx < text.length) {
            label.text = [NSString stringWithFormat:@"%C", [text characterAtIndex:idx]];
        } else {
            label.text = nil;
            label.backgroundColor = ColorFromHex(0xE9E9E9);
        }
        if (idx == text.length) {
            label.layer.borderColor = ColorFromHex(0x00B377).CGColor;;
            label.backgroundColor = UIColor.whiteColor;
        } else {
            label.layer.borderColor = [UIColor clearColor].CGColor;
            label.backgroundColor = ColorFromHex(0xE9E9E9);
        }
    }
}

- (void)addSubviewToFill:(UIView *)subview {
    [self addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [subview.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [subview.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [subview.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [subview.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

#pragma mark - setter & getter
- (void)setLength:(NSInteger)length {
    [self.stackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger idx = 0; idx < length; idx++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = ColorFromHex(0xE9E9E9);
        label.font = self.textField.font;
        label.layer.borderWidth = 0.5;
        label.layer.borderColor = ColorFromHex(0xE9E9E9).CGColor;
        label.layer.cornerRadius = 4.0;
        label.layer.masksToBounds = YES;
        [self.stackView addArrangedSubview:label];
    }
}

- (NSInteger)length {
    return self.stackView.arrangedSubviews.count;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    self.textField.keyboardType = keyboardType;
}

- (UIKeyboardType)keyboardType {
    return self.textField.keyboardType;
}

- (NSString *)verifycode {
    return self.textField.text;
}

#pragma mark - lazy
- (UIStackView *)stackView{
    if (!_stackView){
        UIStackView *view = [[UIStackView alloc] init];
        view.axis = UILayoutConstraintAxisHorizontal;
        view.distribution = UIStackViewDistributionFillEqually;
        view.spacing = 10.0;
        _stackView = view;
    }
    return _stackView;
}

- (UITextField *)textField{
    if (!_textField){
        UITextField *tf = [[UITextField alloc] init];
        tf.borderStyle = UITextBorderStyleNone;
        tf.backgroundColor = [UIColor clearColor];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.autocorrectionType = UITextAutocorrectionTypeNo; // 禁用自动联想功能
        tf.tintColor = [UIColor clearColor]; // 清除光标颜色
        tf.textColor = [UIColor clearColor]; // 清除文字颜色
        tf.font = [UIFont boldSystemFontOfSize:24];
        tf.delegate = self;
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        _textField = tf;
    }
    return _textField;
}

@end
