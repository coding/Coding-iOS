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

@interface TopicHotkeyView ()

- (CGSize)computeSizeFromString:(NSString *)string;
- (void)didClickButton:(id)sender;

@end

@implementation TopicHotkeyView

- (void)setHotkeys:(NSArray *)hotkeys {
    
    if(hotkeys.count) {
        
        UIButton *btnHotkey = nil;
        CGFloat currentWidth = 10.0f;
        CGFloat currentHeight = 0.0f;
        CGSize currentSize = CGSizeZero;
        CGFloat maxWidth = kScreen_Width - 20.0f;
        UIFont *hotkeyFont = [UIFont systemFontOfSize:12.0f];
        NSString *displayHotkey = nil;
        
        for (int i = 0; i < hotkeys.count; i++) {
            
            displayHotkey = [NSString stringWithFormat:@"   #%@#   ", hotkeys[i]];
            btnHotkey = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnHotkey setTag:i];
            [btnHotkey setTitle:displayHotkey forState:UIControlStateNormal];
            [btnHotkey.titleLabel setFont:hotkeyFont];
            btnHotkey.layer.borderWidth = 1.0f;
            btnHotkey.layer.cornerRadius = 12.0f;
            [btnHotkey addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
            
            if(i == 0) {
                
                [btnHotkey setTitleColor:[UIColor colorWithHexString:kFirst_Hotkey_Color] forState:UIControlStateNormal];
                [btnHotkey setTitleColor:[UIColor colorWithHexString:kFirst_Hotkey_Color andAlpha:0.3] forState:UIControlStateHighlighted];
                btnHotkey.layer.borderColor = [[UIColor colorWithHexString:kFirst_Hotkey_Color] CGColor];
            }else {
                
                [btnHotkey setTitleColor:[UIColor colorWithHexString:kOther_Hotkey_Text_Color] forState:UIControlStateNormal];
                [btnHotkey setTitleColor:[UIColor colorWithHexString:kOther_Hotkey_Text_Color andAlpha:0.3] forState:UIControlStateHighlighted];
                btnHotkey.layer.borderColor = [[UIColor colorWithHexString:kOther_HotKey_Border_Color] CGColor];
            }
            
            currentSize = [self computeSizeFromString:displayHotkey];
            currentSize = CGSizeMake(currentSize.width, currentSize.height + 10.0f);
            if (currentSize.width >= maxWidth) {
                
                CGFloat height = ((int)currentSize.width % (int)maxWidth ? currentSize.width / maxWidth : currentSize.width / maxWidth + 1) * currentSize.height;
                btnHotkey.frame = CGRectMake(currentWidth, currentHeight, maxWidth, height);
                currentHeight = currentHeight + height + 10.0f;
                currentWidth = 10.0f;
            }else {
                
                if(currentSize.width + currentWidth < maxWidth) {
                    
                    btnHotkey.frame = CGRectMake(currentWidth, currentHeight, currentSize.width, currentSize.height);
                    currentWidth = currentWidth + currentSize.width + 5.0f;
                }else if (currentSize.width + currentWidth == maxWidth) {
                    
                    btnHotkey.frame = CGRectMake(currentWidth, currentHeight, currentSize.width, currentSize.height);
                    currentWidth = 10.0f;
                    currentHeight = currentHeight + currentSize.height + 10.0f;
                }else if(currentSize.width + currentWidth > maxWidth ) {
                    
                    currentWidth = 10.0f;
                    currentHeight = currentHeight + currentSize.height + 10.0f;
                    btnHotkey.frame = CGRectMake(currentWidth, currentHeight, currentSize.width, currentSize.height);
                    currentWidth = currentWidth + currentSize.width + 5.0f;
                }
            }
            
            if(i == hotkeys.count - 1) {
                
                currentHeight += currentSize.height + 15.0f;
            }
            
            [self addSubview:btnHotkey];
            currentSize = CGSizeZero;
            btnHotkey = nil;
        }
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreen_Width, currentHeight);
    }
}

- (CGSize)computeSizeFromString:(NSString *)string {
    
    CGSize size = [string sizeWithAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:12.0f] }];
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return adjustedSize;
}

- (void)didClickButton:(id)sender {
    
    NSInteger index = [(UIButton *)sender tag];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickHotkeyWithIndex:)]) {
        
        [self.delegate didClickHotkeyWithIndex:index];
    }
}

@end
