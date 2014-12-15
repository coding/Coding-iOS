//
//  UIAwesomeButton.h
//  PPiAwesomeButton-Demo
//
//  Created by Pedro Piñera Buendia on 30/12/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"
#import "UIButton+PPiAwesome.h"

typedef void (^block)();
@interface UIAwesomeButton : UIControl

@property (nonatomic) IconPosition iconPosition;
@property (nonatomic, strong) NSDictionary *textAttributes;
@property (copy) void (^actionBlock)(UIAwesomeButton *button);

// Initializers
+ (UIAwesomeButton*)buttonWithType:(UIButtonType)type
                              text:(NSString *)text
                              icon:(NSString *)icon
                        attributes:(NSDictionary *)attributes
                   andIconPosition:(IconPosition)position;

+ (UIAwesomeButton*)buttonWithType:(UIButtonType)type
                              text:(NSString *)text
                         iconImage:(UIImage *)icon
                        attributes:(NSDictionary *)attributes
                   andIconPosition:(IconPosition)position;

- (id)initWithFrame:(CGRect)frame
               text:(NSString *)text
               icon:(NSString *)icon
         attributes:(NSDictionary *)attributes
    andIconPosition:(IconPosition)position;

- (id)initWithFrame:(CGRect)frame
               text:(NSString *)text
          iconImage:(UIImage *)icon
         attributes:(NSDictionary *)attributes
    andIconPosition:(IconPosition)position;

// Setters
- (void)setButtonText:(NSString *)buttonText;

- (void)setIcon:(NSString *)icon;

- (void)setIconImage:(UIImage *)icon;

- (void)setAttributes:(NSDictionary*)attributes
   forUIControlState:(UIControlState)state;

- (void)setBackgroundColor:(UIColor*)color
         forUIControlState:(UIControlState)state;

- (void)setRadius:(CGFloat)radius;

- (void)setBorderWidth:(CGFloat)width
           borderColor:(UIColor *)color;

- (void)setControlState:(UIControlState)controlState;

- (void)setSeparation:(CGFloat)separation;

- (void)setTextAlignment:(NSTextAlignment)alignment;

- (void)setHorizontalMargin:(CGFloat)margin;

- (void)setIconImageView:(UIImageView *)iconImageView;

//Getters
-(NSString*)getButtonText;
-(NSString*)getIcon;
-(UIImage*)getIconImage;
-(CGFloat)getRadius;
-(CGFloat)getSeparation;
-(NSTextAlignment)getTextAlignment;
-(CGFloat)getHorizontalMargin;
-(UIImageView*)getIconImageView;

@end
