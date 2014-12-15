//
//  UIAwesomeButton.m
//  PPiAwesomeButton-Demo
//
//  Created by Pedro Piñera Buendia on 30/12/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "UIAwesomeButton.h"
@interface UIAwesomeButton ()
@property (nonatomic) CGFloat separation;
@property (nonatomic) NSTextAlignment textAligment;
@property (nonatomic) UIControlState controlState;
@property (nonatomic,strong) NSMutableDictionary *attributes;
@property (nonatomic,strong) NSMutableDictionary *backgroundColors;
@property (nonatomic,strong) NSNumber *horizontalmargin;
@property (nonatomic,strong) NSString *buttonText;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) UIImage *iconImage;
@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *iconLabel, *textLabel;
@end

@implementation UIAwesomeButton
@synthesize iconImageView = _iconImageView;

+(UIAwesomeButton*)buttonWithType:(UIButtonType)type text:(NSString *)text iconImage:(UIImage *)icon attributes:(NSDictionary *)attributes andIconPosition:(IconPosition)position
{
    UIAwesomeButton *button = [[UIAwesomeButton alloc] initWithFrame:CGRectZero text:text iconImage:icon attributes:attributes andIconPosition:position];
    return button;
}

+(UIAwesomeButton*)buttonWithType:(UIButtonType)type text:(NSString *)text icon:(NSString *)icon attributes:(NSDictionary *)attributes andIconPosition:(IconPosition)position
{
    UIAwesomeButton *button = [[UIAwesomeButton alloc] initWithFrame:CGRectZero text:text icon:icon attributes:attributes andIconPosition:position];
    return button;
}

-(id)initWithFrame:(CGRect)frame text:(NSString *)text icon:(NSString *)icon attributes:(NSDictionary *)attributes andIconPosition:(IconPosition)position
{
    self=[super initWithFrame:frame];
    if(self){
        [self setIcon:icon andButtonText:text];
        [self setAttributes:attributes forUIControlState:UIControlStateNormal];
        [self setIconPosition:position];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setControlState:UIControlStateNormal];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame text:(NSString *)text iconImage:(UIImage *)icon attributes:(NSDictionary *)attributes andIconPosition:(IconPosition)position
{
    self=[super initWithFrame:frame];
    if(self){
        [self setIconImage:icon andButtonText:text];
        [self setAttributes:attributes forUIControlState:UIControlStateNormal];
        [self setIconPosition:position];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setControlState:UIControlStateNormal];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateButtonContent];
}


-(void)updateButtonContent{
    // Removing from superView
    [self.textLabel removeFromSuperview];
    [self.iconLabel removeFromSuperview];
    [self.iconImageView removeFromSuperview];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    //Setting labels
    [self updateSubviewsContent];
    
    // Horizontal layout
    [self addSubview:self.textLabel];
    if (self.icon) {
        [self addSubview:self.iconLabel];
    }
    if (self.iconImageView.image) {
        [self addSubview:self.iconImageView];
    }
    
    // Elements order ICON/TEXT
    UIView *iconElement = self.icon? self.iconLabel : self.iconImageView.image ? self.iconImageView : nil;
    UIView *element1 = iconElement;
    UIView *element2 = self.textLabel;
    if(self.iconPosition == IconPositionRight){
        element1 = self.textLabel;
        element2 = iconElement;
    }
    
    //Horizontal layout
    [self centerHorizontally:element1 element2:element2];
    
    // Vertical layout
    float margin  = self.frame.size.height*0.10;
    [self centerVertically:element1 element2:element2 margin:margin];
}


- (void)centerHorizontally:(UIView *)element1 element2:(UIView *)element2
{
    //Set aligment of subviews
    if([element1 isKindOfClass:[UILabel class]])
    {
        [(UILabel*)element1 setTextAlignment:NSTextAlignmentLeft];
    }
    if([element2 isKindOfClass:[UILabel class]])
    {
        [(UILabel*)element2 setTextAlignment:NSTextAlignmentLeft];
    }
    
    [self ditributeHorizontally:element1 element2:element2];
}


- (void)centerVertically:(UIView *)element1 element2:(UIView *)element2 margin:(float)margin
{
    if ([element1 isKindOfClass:[UILabel class]]) {
        [element1 setFrame:CGRectMake(element1.frame.origin.x, 0, element1.frame.size.width, self.frame.size.height)];
        
    }
    else if ([element1 isKindOfClass:[UIImageView class]]) {
        [element1 setFrame:CGRectMake(element1.frame.origin.x, self.frame.size.height/2 - element1.frame.size.height/2, element1.frame.size.width, element1.frame.size.height)];
    }
    if ([element2 isKindOfClass:[UILabel class]]) {
        [element2 setFrame:CGRectMake(element2.frame.origin.x, 0, element2.frame.size.width, self.frame.size.height)];
        
    }
    else if ([element2 isKindOfClass:[UIImageView class]]) {
        [element2 setFrame:CGRectMake(element2.frame.origin.x, self.frame.size.height/2 - element2.frame.size.height/2, element2.frame.size.width, element2.frame.size.height)];
    }
}


- (void)ditributeHorizontally:(UIView *)element1 element2:(UIView *)element2
{
    CGFloat element1Width = 0;
    CGFloat element2Width = 0;
    if([element1 isKindOfClass:[UILabel class]])
    {
        [(UILabel*)element1 setTextAlignment:NSTextAlignmentRight];
        element1Width = [((UILabel*)element1).text sizeWithAttributes:@{NSFontAttributeName:((UILabel*)element1).font}].width;
    }
    else if([element1 isKindOfClass:[UIImageView class]])
    {
        if (self.iconImageView.frame.size.width) {
            element1Width = self.iconImageView.frame.size.width;
        }
        else {
            element1Width = self.iconImage.size.width;
        }
    }
    if([element2 isKindOfClass:[UILabel class]])
    {
        [(UILabel*)element2 setTextAlignment:NSTextAlignmentLeft];
        element2Width = [((UILabel*)element2).text sizeWithAttributes:@{NSFontAttributeName:((UILabel*)element2).font}].width;
        
    }
    else if([element2 isKindOfClass:[UIImageView class]])
    {
        if (self.iconImageView.frame.size.width) {
            element1Width = self.iconImageView.frame.size.width;
        }
        else {
            element1Width = self.iconImage.size.width;
        }
    }
    
    if(self.textAligment == NSTextAlignmentCenter){
        CGFloat originX = (self.frame.size.width - (element1Width+ self.separation +element2Width))/2;
        [element1 setFrame:CGRectMake(originX, element1.frame.origin.y, element1Width, element1.frame.size.height)];
        [element2 setFrame:CGRectMake(originX + element1Width + self.separation, element2.frame.origin.y, element2Width, element2.frame.size.height)];
    }
    else if (self.textAligment == NSTextAlignmentLeft){
        [element1 setFrame:CGRectMake(self.horizontalmargin.intValue, element1.frame.origin.y, element1Width, element1.frame.size.height)];
        [element2 setFrame:CGRectMake(self.horizontalmargin.intValue + element1Width + self.separation, element2.frame.origin.y, element2Width, element2.frame.size.height)];
    }
    else if (self.textAligment == NSTextAlignmentRight){
        [element1 setFrame:CGRectMake(self.frame.size.width-self.horizontalmargin.intValue-element2Width-self.separation-element1Width, element1.frame.origin.y, element1Width, element1.frame.size.height)];
        [element2 setFrame:CGRectMake(element1.frame.origin.x + element1Width + self.separation, element2.frame.origin.y, element2Width, element2.frame.size.height)];
    }
}


-(void)updateButtonFormat
{
    [self setBackgroundColor:[self backgroundColorForState:self.controlState]];
    [self updateSubviewsContent];
}

-(void)updateSubviewsContent
{
    // Setting the constraints
    if(self.buttonText) {
        [self.textLabel setAttributedText:[[NSAttributedString alloc] initWithString:self.buttonText attributes:[self textAttributesForState:self.controlState]]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [self.textLabel setText:@""];
    }
    
    if(self.icon){
        [self.iconLabel setAttributedText:[[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:self.icon] attributes:[self iconAttributesForState:self.controlState]]];
        [self.iconLabel setBackgroundColor:[UIColor clearColor]];
    }
    else{
        [self.iconLabel setText:@""];
    }
    
    if (self.iconImage) {
        [self.iconImageView setImage:self.iconImage];
    }
}


#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setControlState:UIControlStateHighlighted];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setControlState:UIControlStateNormal];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setControlState:UIControlStateNormal];
    
    // Calling action block if it exists
    if(self.actionBlock){
        self.actionBlock(self);
    }
}


#pragma mark - Lazy Instantiation

-(NSMutableDictionary*)attributes
{
    if(!_attributes) _attributes = [NSMutableDictionary new];
    return _attributes;
}

-(NSMutableDictionary*)backgroundColors
{
    if(!_backgroundColors) _backgroundColors = [NSMutableDictionary new];
    return _backgroundColors;
}

-(UILabel*)textLabel
{
    if(!_textLabel){
        _textLabel = [UILabel new];
        [_textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _textLabel;
}

-(UILabel*)iconLabel
{
    if(!_iconLabel){
        _iconLabel = [UILabel new];
        [_iconLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_iconLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _iconLabel;
}

-(UIImageView*)iconImageView
{
    if(!_iconImageView) {
        _iconImageView = [UIImageView new];
        [_iconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_iconImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_iconImageView setContentMode:UIViewContentModeCenter];
    }
    return _iconImageView;
}


#pragma mark - Custom getters

-(NSDictionary*)iconAttributesForState:(UIControlState)state
{
    NSMutableDictionary *iconAttributes = [[self textAttributesForState:state] mutableCopy];
    if ([iconAttributes objectForKey:@"IconFont"]) {
        iconAttributes[NSFontAttributeName] = iconAttributes[@"IconFont"];
    }else{
        UIFont *textFont = ((UIFont*)iconAttributes[NSFontAttributeName]);
        iconAttributes[NSFontAttributeName]=[UIFont fontWithName:@"fontawesome" size:textFont.pointSize];
    }
    return iconAttributes;
}

-(NSDictionary*)textAttributesForState:(UIControlState)state
{
    if(self.attributes[@(state)]) return self.attributes[@(state)];
    else return self.attributes[@(UIControlStateNormal)];
}

-(UIColor*)backgroundColorForState:(UIControlState)state
{
    if(self.backgroundColors[@(state)]) return self.backgroundColors[@(state)];
    else return self.backgroundColors[@(UIControlStateNormal)];
    
}

-(NSNumber*)horizontalmargin
{
    if(!_horizontalmargin) _horizontalmargin = @(5);
    return _horizontalmargin;
}


#pragma  mark - Setters

-(void)setHorizontalMargin:(CGFloat)margin
{
    _horizontalmargin = @(margin);
    [self updateButtonContent];
}

-(void)setTextAlignment:(NSTextAlignment)alignment
{
    _textAligment=alignment;
    [self updateButtonContent];
}

-(void)setRadius:(CGFloat)radius
{
    self.layer.cornerRadius=radius;
}

- (void)setBorderWidth:(CGFloat)width
           borderColor:(UIColor *)color
{
    [self.layer setBorderWidth:width];
    [self.layer setBorderColor:color.CGColor];
}

-(void)setSeparation:(CGFloat)separation
{
    _separation = separation;
    [self updateButtonContent];
}

-(void)setAttributes:(NSDictionary*)attributes forUIControlState:(UIControlState)state
{
    //Setting attributes
    self.attributes[@(state)]=attributes;
    [self updateButtonFormat];
    [self updateButtonContent];
}

-(void)setBackgroundColor:(UIColor*)color forUIControlState:(UIControlState)state
{
    self.backgroundColors[@(state)]=color;
    [self updateButtonFormat];
}

-(void)setControlState:(UIControlState)controlState
{
    _controlState = controlState;
    [self updateButtonFormat];
}

-(void)setIcon:(NSString *)icon andButtonText:(NSString*)text
{
    _buttonText = text;
    _icon = icon;
    _iconImage = nil;
    [self updateButtonContent];
}

-(void)setIconImage:(UIImage *)iconImage andButtonText:(NSString*)text
{
    _buttonText = text;
    _iconImage = iconImage;
    _icon = nil;
    [self updateButtonContent];
}

-(void)setButtonText:(NSString *)buttonText
{
    _buttonText = buttonText;
    [self updateButtonContent];
}

-(void)setIconImage:(UIImage *)icon
{
    _icon = nil;
    _iconImage = icon;
    [self updateButtonContent];
}

-(void)setIcon:(NSString *)icon
{
    _icon = icon;
    _iconImage = nil;
    [self updateButtonContent];
}
-(void)setIconPosition:(IconPosition)iconPosition
{
    _iconPosition = iconPosition;
}

-(void)setIconImageView:(UIImageView *)iconImageView
{
    _iconImageView = iconImageView;
    _iconImage = nil;
    [self updateButtonContent];
}


#pragma mark - Getters

-(NSString*)getButtonText
{
    return _buttonText;
}

-(NSString*)getIcon
{
    return _icon;
}

-(UIImage*)getIconImage
{
    return _iconImage;
}

-(UIImageView*)getIconImageView
{
    return _iconImageView;
}

-(CGFloat)getRadius
{
    return self.layer.cornerRadius;
}

-(CGFloat)getSeparation
{
    return _separation;
}

-(NSTextAlignment)getTextAlignment
{
    return _textAligment;
}

-(CGFloat)getHorizontalMargin
{
    return _horizontalmargin.intValue;
}

@end
