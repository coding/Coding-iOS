//
//  UIButton+PPiAwesome.h
//  PPiAwesomeButton-Demo
//
//  Created by Pedro Piñera Buendía on 19/08/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

typedef enum {
    IconPositionRight,
    IconPositionLeft,
} IconPosition;

@interface UIButton (PPiAwesome)

+ (UIButton*)buttonWithType:(UIButtonType)type
                       text:(NSString*)text
                       icon:(NSString*)icon
             textAttributes:(NSDictionary*)attributes
            andIconPosition:(IconPosition)position;

- (id)initWithFrame:(CGRect)frame
               text:(NSString*)text
               icon:(NSString*)icon
     textAttributes:(NSDictionary*)attributes
    andIconPosition:(IconPosition)position;

- (id)initWithFrame:(CGRect)frame
               text:(NSString*)text
         iconString:(NSString*)iconString
     textAttributes:(NSDictionary*)attributes
    andIconPosition:(IconPosition)position;

+ (UIButton*)buttonWithType:(UIButtonType)type
                       text:(NSString*)text
                 iconString:(NSString*)iconString
             textAttributes:(NSDictionary*)attributes
            andIconPosition:(IconPosition)position;

- (void)setTextAttributes:(NSDictionary*)attributes
        forUIControlState:(UIControlState)state;

- (void)setBackgroundColor:(UIColor*)color
         forUIControlState:(UIControlState)state;

- (void)setIconPosition:(IconPosition)position;

- (void)setButtonText:(NSString*)text;

- (void)setButtonIcon:(NSString*)icon;

- (void)setButtonIconString:(NSString *)icon;

- (void)setRadius:(CGFloat)radius;

- (void)setBorderWidth:(CGFloat)width
           borderColor:(UIColor *)color;

- (void)setSeparation:(NSUInteger)separation;

- (void)setIsAwesome:(BOOL)isAwesome;

@end
