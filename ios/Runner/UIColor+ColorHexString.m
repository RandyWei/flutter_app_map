//
//  UIColor+ColorHexString.m
//  Runner
//
//  Created by Wei on 2019/5/27.
//  Copyright © 2019年 The Chromium Authors. All rights reserved.
//

#import "UIColor+ColorHexString.h"

@implementation UIColor (ColorHexString)
+(UIColor *)colorWithHexString:(NSString *)hexColor{
    NSString * cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] == 6) {
        cString = [NSString stringWithFormat:@"FF%@",cString];
    }else if(([cString length] == 8)){
        
    }else{
        return [UIColor blackColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString * aString = [cString substringWithRange:range];
    
    range.location+=2;
    NSString * rString = [cString substringWithRange:range];
    
    range.location+=2;
    NSString * gString = [cString substringWithRange:range];
    
    range.location+=2;
    NSString * bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:((float)a / 255.0f)];
}
@end
