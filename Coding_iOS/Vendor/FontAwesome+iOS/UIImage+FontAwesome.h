//
//  UIImage+UIImage_FontAwesome.h
//  FontAwesome-iOS Demo
//
//  Created by Pedro Piñera Buendía on 22/08/13.
//  Copyright (c) 2013 Alex Usbergo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FontAwesome)
+(UIImage*)imageWithIcon:(NSString*)identifier backgroundColor:(UIColor*)bgColor iconColor:(UIColor*)iconColor iconScale:(CGFloat)scale andSize:(CGSize)size;
@end
