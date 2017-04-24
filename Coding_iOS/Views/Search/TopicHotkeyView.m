//
//  TopicHotkeyView.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TopicHotkeyView.h"

#define kFirst_Hotkey_Color         @"0x2EBE76"
#define kOther_Hotkey_Text_Color    @"0x222222"
#define kOther_HotKey_Border_Color  @"0xb5b5b5"

@interface TopicHotkeyView ()
@property (nonatomic,strong) NSMutableArray *keyDatalist;
@property (nonatomic,strong) NSMutableArray *keyViewlist;

@end

@implementation TopicHotkeyView

- (void)setHotkeys:(NSArray *)hotkeys {
    if (!_keyDatalist) {
        _keyDatalist = [@[] mutableCopy];
        _keyViewlist = [@[] mutableCopy];
    }
    
    for (UIView *subView in _keyViewlist) {
        [subView removeFromSuperview];
    }
    [_keyViewlist removeAllObjects];
    [_keyDatalist removeAllObjects];
    
    if ([hotkeys count] <= 0) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreen_Width, 0);
        return;
    }
    
    [_keyDatalist addObjectsFromArray:hotkeys];
    
    
    if(hotkeys.count) {
        
        CGFloat currentWidth = 10.0f;
        CGFloat currentHeight = 15.0f;
        CGSize currentSize = CGSizeZero;
        CGFloat maxWidth = kScreen_Width - 20.0f;
        UIFont *hotkeyFont = [UIFont systemFontOfSize:12.0f];
        
        for (int i = 0; i < _keyDatalist.count; i++) {
            NSString *displayHotkey = [NSString stringWithFormat:@"   #%@#   ", hotkeys[i][@"name"]];
            UIButton *btnHotkey = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnHotkey setTag:i];
            [btnHotkey setTitle:displayHotkey forState:UIControlStateNormal];
            [btnHotkey.titleLabel setFont:hotkeyFont];
            btnHotkey.layer.borderWidth = 1.0f;
            btnHotkey.layer.cornerRadius = 15.0f;
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
//            currentSize = CGSizeMake(currentSize.width, currentSize.height + 10.0f);
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
            
            [_keyViewlist addObject:btnHotkey];
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kScreen_Width, currentHeight);
    }
}

- (CGSize)computeSizeFromString:(NSString *)string {
    
    CGSize maxSize = CGSizeMake(kScreen_Width, 30);
    CGSize curSize = [string boundingRectWithSize:maxSize
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f] }
                                          context:nil].size;
    return CGSizeMake(ceilf(curSize.width), 30);
    
}

- (void)didClickButton:(id)sender {
    NSInteger index = [(UIButton *)sender tag];
    if (_block) {
        _block(_keyDatalist[index]);
    }
}

@end
