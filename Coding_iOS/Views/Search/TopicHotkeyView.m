//
//  TopicHotkeyView.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TopicHotkeyView.h"

#define kFirst_Hotkey_Color         @"0x3bbd79"
#define kOther_Hotkey_Text_Color    @"0x222222"
#define kOther_HotKey_Border_Color  @"0xb5b5b5"

@implementation TopicHotkeyView

- (id)initWithHotkeys:(NSArray *)hotkeys withFrame:(CGRect)frame {
    
    if(self = [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        
        if(hotkeys.count) {
            
            UILabel *lblHotKey = nil;
            CGFloat currentWidth = 10.0f;
            CGFloat currentHeight = 0.0f;
            CGSize currentSize = CGSizeZero;
            CGFloat maxWidth = kScreen_Width - 20.0f;
            UIFont *hotkeyFont = [UIFont systemFontOfSize:12.0f];
            NSString *displayHotkey = nil;
            
            for (int i = 0; i < hotkeys.count; i++) {
                
                displayHotkey = [NSString stringWithFormat:@"   #%@#   ", hotkeys[i]];
                lblHotKey = [[UILabel alloc] init];
                [lblHotKey setText:displayHotkey];
                [lblHotKey setFont:hotkeyFont];
                lblHotKey.layer.borderWidth = 1.0f;
                lblHotKey.layer.cornerRadius = 12.0f;
                
                if(i == 0) {
                    
                    lblHotKey.textColor = [UIColor colorWithHexString:kFirst_Hotkey_Color];
                    lblHotKey.layer.borderColor = [[UIColor colorWithHexString:kFirst_Hotkey_Color] CGColor];
                }else {
                    
                    lblHotKey.textColor = [UIColor colorWithHexString:kOther_Hotkey_Text_Color];
                    lblHotKey.layer.borderColor = [[UIColor colorWithHexString:kOther_HotKey_Border_Color] CGColor];
                }
                
                currentSize = [self computeSizeFromString:displayHotkey];
                currentSize = CGSizeMake(currentSize.width, currentSize.height + 10.0f);
                if (currentSize.width >= maxWidth) {
                    
                    CGFloat height = ((int)currentSize.width % (int)maxWidth ? currentSize.width / maxWidth : currentSize.width / maxWidth + 1) * currentSize.height;
                    lblHotKey.frame = CGRectMake(currentWidth, currentHeight, maxWidth, height);
                    currentHeight = currentHeight + height + 10.0f;
                    currentWidth = 10.0f;
                }else {
                
                    if(currentSize.width + currentWidth < maxWidth) {
                    
                        lblHotKey.frame = CGRectMake(currentWidth, currentHeight, currentSize.width, currentSize.height);
                        currentWidth = currentWidth + currentSize.width + 5.0f;
                    }else if (currentSize.width + currentWidth == maxWidth) {
                    
                        lblHotKey.frame = CGRectMake(currentWidth, currentHeight, currentSize.width, currentSize.height);
                        currentWidth = 10.0f;
                        currentHeight = currentHeight + currentSize.height + 10.0f;
                    }else if(currentSize.width + currentWidth > maxWidth ) {
                    
                        currentWidth = 10.0f;
                        currentHeight = currentHeight + currentSize.height + 10.0f;
                        lblHotKey.frame = CGRectMake(currentWidth, currentHeight, currentSize.width, currentSize.height);
                        currentWidth = currentWidth + currentSize.width + 5.0f;
                    }
                }
                
                [self addSubview:lblHotKey];
                currentSize = CGSizeZero;
                lblHotKey = nil;
            }
            
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreen_Width, currentHeight);
        }
    }
    
    return self;
}

- (CGSize)computeSizeFromString:(NSString *)string {

    CGSize size = [string sizeWithAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:12.0f] }];
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return adjustedSize;
}

@end
