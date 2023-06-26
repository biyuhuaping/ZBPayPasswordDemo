//
//  ZBPayHeader.h
//  ZBPayPasswordDemo
//
//  Created by ZB on 2023/6/26.
//

#ifndef ZBPayHeader_h
#define ZBPayHeader_h

#define isIPhoneXSeries ({\
    BOOL iPhoneXSeries = NO;\
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {\
        (iPhoneXSeries);\
    }\
    if (@available(iOS 11.0, *)) {\
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];\
        if (mainWindow.safeAreaInsets.bottom > 0.0) {\
            iPhoneXSeries = YES;\
        }\
    }\
    (iPhoneXSeries);\
})

#define ColorFromHex(hexValue)  [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define kScreenWidth    CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight   CGRectGetHeight([UIScreen mainScreen].bounds)

/// 底部安全区域远离高度
#define kBottomSafeHeight   (CGFloat)(isIPhoneXSeries?(34):(0))


#endif /* ZBPayHeader_h */
