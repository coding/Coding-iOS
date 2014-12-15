//
//  UIButton+PPiAwesome.m
//  PPiAwesomeButton-Demo
//
//  Created by Pedro Piñera Buendía on 19/08/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "UIButton+PPiAwesome.h"

static char buttonTextKey;
static char buttonIconKey;
static char buttonIconStringKey;
static char iconPositionKey;
static char backgroundColorsKey;
static char textAttributesKey;
static char isAwesomeKey;
static char separationKey;


@implementation UIButton (PPiAwesome)

+(UIButton*)buttonWithType:(UIButtonType)type text:(NSString*)text icon:(NSString*)icon textAttributes:(NSDictionary*)attributes andIconPosition:(IconPosition)position{
    UIButton *button =[UIButton buttonWithType:type];
    [button setIsAwesome:YES];
    [button setButtonText:text];
    [button setButtonIcon:icon];
    [button setTextAttributes:attributes forUIControlState:UIControlStateNormal];
    [button setIconPosition:position];
    [button setIsAwesome:YES];

    return button;
}
-(id)initWithFrame:(CGRect)frame text:(NSString*)text icon:(NSString*)icon textAttributes:(NSDictionary*)attributes andIconPosition:(IconPosition)position{
    self=[super initWithFrame:frame];
    if(self){
        [self setIsAwesome:YES];

        [self setButtonText:text];
        [self setButtonIcon:icon];
        [self setTextAttributes:attributes forUIControlState:UIControlStateNormal];
        [self setIconPosition:position];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame text:(NSString*)text iconString:(NSString*)iconString textAttributes:(NSDictionary*)attributes andIconPosition:(IconPosition)position{
    self=[super initWithFrame:frame];
    if(self){
        [self setIsAwesome:YES];

        [self setButtonText:text];
        [self setButtonIconString:iconString];
        [self setTextAttributes:attributes forUIControlState:UIControlStateNormal];
        [self setIconPosition:position];
    }
    return self;
}
+(UIButton*)buttonWithType:(UIButtonType)type text:(NSString*)text iconString:(NSString*)iconString textAttributes:(NSDictionary*)attributes andIconPosition:(IconPosition)position{
    UIButton *button =[UIButton buttonWithType:type];
    [button setIsAwesome:YES];
    [button setButtonText:text];
    [button setButtonIconString:iconString];
    [button setTextAttributes:attributes forUIControlState:UIControlStateNormal];
    [button setIconPosition:position];
    [button setIsAwesome:YES];

    return button;

}

-(void)updateButtonFormatForUIControlState:(UIControlState)state{
    if([self isAwesome]){
        //Mutable String to set to the button
        NSMutableAttributedString *mutableString=[[NSMutableAttributedString alloc] init];

        //Mutable String of text
        NSMutableAttributedString *mutableStringText=[[NSMutableAttributedString alloc] initWithString:@""];
        if([self buttonText])
            [mutableStringText appendAttributedString:[[NSAttributedString alloc] initWithString:[self buttonText]]];

        //Mutable String of icon
        NSMutableAttributedString *mutableStringIcon=[[NSMutableAttributedString alloc] initWithString:@""];
        if([self buttonIconString]){
            [mutableStringIcon appendAttributedString:[[NSAttributedString alloc] initWithString:[self buttonIconString]]];
        }
        else if([self buttonIcon]){
            [mutableStringIcon appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:[self buttonIcon]]]];
        }

        //Setting color
        UIColor *color=[self backgroundColors][@(state)];
        if(!color)
            color=[self backgroundColors][@(UIControlStateNormal)];

        if(color){
            [self setBackgroundColor:color];
        }

        //Setting attributes
        NSMutableDictionary *textAttributes=[[self textAttributes][@(state)] mutableCopy];
        if(!textAttributes)
            textAttributes=[[self textAttributes][@(UIControlStateNormal)] mutableCopy];
        if(textAttributes){
            //Setting attributes to text
            [mutableStringText setAttributes:textAttributes range:NSMakeRange(0, [[self buttonText] length])];

            //Setting attributes to icon
            if([self buttonIcon] || [self buttonIconString]){
                UIFont *textFont=(UIFont*)textAttributes[NSFontAttributeName];
                NSMutableDictionary *iconAttributes=[textAttributes mutableCopy];
                if ([textAttributes objectForKey:@"IconFont"]) {
                    iconAttributes[NSFontAttributeName] = textAttributes[@"IconFont"];
                }else{
                    iconAttributes[NSFontAttributeName]=[UIFont fontWithName:@"fontawesome" size:textFont.pointSize];
                }
                [mutableStringIcon setAttributes:iconAttributes range:NSMakeRange(0, [mutableStringIcon length])];
            }
        }

        //Separation
        NSMutableString *separationString=[NSMutableString stringWithFormat:@""];
        if([self separation]){
            int separationInt=[[self separation] intValue];
            for(int i=0;i<separationInt;i++){
                [separationString appendString:@" "];
            }
        }

        //Concatenating
        if([self iconPosition]==IconPositionLeft){
            [mutableString appendAttributedString:mutableStringIcon];
            [mutableString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
            [mutableString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:separationString]];
            [mutableString appendAttributedString:mutableStringText];
        }else{
            [mutableString appendAttributedString:mutableStringText];
            [mutableString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
            [mutableString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:separationString]];
            [mutableString appendAttributedString:mutableStringIcon];
        }


        //Setting to the button
        [self setAttributedTitle:mutableString forState:UIControlStateNormal];
    }
}
-(void)setRadius:(CGFloat)radius{
    self.layer.cornerRadius=radius;
}

- (void)setBorderWidth:(CGFloat)width
           borderColor:(UIColor *)color{
    [self.layer setBorderWidth:width];
    [self.layer setBorderColor:color.CGColor];
}

#pragma mark -
#pragma mark Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self isAwesome])
        [self updateButtonFormatForUIControlState:UIControlStateHighlighted];
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self isAwesome])
        [self updateButtonFormatForUIControlState:UIControlStateNormal];
    [super touchesCancelled:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self isAwesome])
        [self updateButtonFormatForUIControlState:UIControlStateNormal];
    [super touchesEnded:touches withEvent:event];
}


#pragma mark -
#pragma  mark - Category properties
-(void)setTextAttributes:(NSDictionary*)attributes forUIControlState:(UIControlState)state{
    NSMutableDictionary *textAttributes=[self textAttributes];
    if(!textAttributes){
        textAttributes=[[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &textAttributesKey,textAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    //Setting attributes
    if(attributes)
        textAttributes[@(state)]=attributes;

    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (NSMutableDictionary*) textAttributes {
    return objc_getAssociatedObject(self, &textAttributesKey);
}

-(void)setBackgroundColor:(UIColor*)color forUIControlState:(UIControlState)state{
    NSMutableDictionary *backgroundColors=[self backgroundColors];
    if(!backgroundColors){
        backgroundColors=[[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &backgroundColorsKey,backgroundColors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    //Setting attributes
    if(color)
        backgroundColors[@(state)]=color;

    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (NSMutableDictionary*) backgroundColors {
    return objc_getAssociatedObject(self, &backgroundColorsKey);
}


-(void)setButtonText:(NSString*)text{
    objc_setAssociatedObject(self, &buttonTextKey,text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (NSString*) buttonText {
    return objc_getAssociatedObject(self, &buttonTextKey);
}
-(void)setButtonIcon:(NSString*)icon{
    objc_setAssociatedObject(self, &buttonIconKey,icon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}

- (NSString*) buttonIcon {
    return objc_getAssociatedObject(self, &buttonIconKey);
}
-(void)setButtonIconString:(NSString *)icon{
    objc_setAssociatedObject(self, &buttonIconStringKey,icon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (NSString*) buttonIconString {
    return objc_getAssociatedObject(self, &buttonIconStringKey);
}
-(void)setSeparation:(NSUInteger)separation{
    objc_setAssociatedObject(self, &separationKey,@(separation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (NSNumber*) separation {
    return objc_getAssociatedObject(self, &separationKey);
}

-(void)setIconPosition:(IconPosition)position{
    objc_setAssociatedObject(self, &iconPositionKey,@(position), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (IconPosition) iconPosition {
    return [objc_getAssociatedObject(self, &iconPositionKey) intValue];
}

-(void)setIsAwesome:(BOOL)awesome{
    objc_setAssociatedObject(self, &isAwesomeKey,@(awesome), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateButtonFormatForUIControlState:UIControlStateNormal];
}
- (BOOL) isAwesome {
    return objc_getAssociatedObject(self, &isAwesomeKey)?YES:NO;
}

// override enabled
-(void)swizzle_setEnabled:(BOOL)enabled {
    [self swizzle_setEnabled:enabled];
    if (enabled) {
        [self updateButtonFormatForUIControlState:UIControlStateNormal];
    } else {
        [self updateButtonFormatForUIControlState:UIControlStateDisabled];
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(setEnabled:);
        SEL swizzledSelector = @selector(swizzle_setEnabled:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

@end
