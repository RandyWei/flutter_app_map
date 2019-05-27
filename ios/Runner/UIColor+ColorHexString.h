//
//  UIColor+ColorHexString.h
//  Runner
//
//  Created by Wei on 2019/5/27.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ColorHexString)
/**
 16进制颜色转换为UIColor
 @param hexColor 16进制字符串（可以以0x开头，可以以#开头，也可以就是6位的16进制）
 @return 16进制字符串对应的颜色
 */
+(UIColor *)colorWithHexString:(NSString *)hexColor;
@end

NS_ASSUME_NONNULL_END
