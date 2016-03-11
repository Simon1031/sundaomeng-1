//
//  ColorConvert.m
//  Monitor
//
//  Created by 李伟 on 11-6-27.
//  Copyright 2011 中体彩科技发展有限公司. All rights reserved.
//

#import "UIColor+WebColor.h"


@implementation UIColor(WebColor)

/**
 web颜色
 
 @param  stringToConvert  #cfcfcf
 
 @return UIColor
 */
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert {
	
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// String should be 6 or 8 characters
	if ([cString length] < 6) return DEFAULT_VOID_COLOR;
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
	if ([cString length] != 6) return DEFAULT_VOID_COLOR;
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}

/**
 RGB颜色
 
 @param  r  
 @param  g
 @param  b
 @param  a
 
 @return UIColor
 */
+ (UIColor *)colorRGBWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a
{
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a];
}

@end
