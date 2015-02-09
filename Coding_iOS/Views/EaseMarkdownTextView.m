//
//  EaseMarkdownTextView.m
//  Coding_iOS
//
//  Created by Ease on 15/2/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EaseMarkdownTextView.h"
#import "RFKeyboardToolbar.h"
#import "RFToolbarButton.h"


@implementation EaseMarkdownTextView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.inputAccessoryView = [RFKeyboardToolbar toolbarWithButtons:[self buttons]];
    }
    return self;
}

- (NSArray *)buttons {
    return @[[self createButtonWithTitle:@"#" andEventHandler:^{ [self insertText:@"#"]; }],
             [self createButtonWithTitle:@"*" andEventHandler:^{ [self insertText:@"*"]; }],
             [self createButtonWithTitle:@"_" andEventHandler:^{ [self insertText:@"_"]; }],
             [self createButtonWithTitle:@"`" andEventHandler:^{ [self insertText:@"`"]; }],
             [self createButtonWithTitle:@"@" andEventHandler:^{ [self insertText:@"@"]; }],
             [self createButtonWithTitle:@"链接" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 1;
                 [self insertText:@"[]()"];
                 [self setSelectionRange:selectionRange];
                 
             }],
             [self createButtonWithTitle:@"代码" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += self.text.length == 0 ? 3 : 4;
                 
                 [self insertText: self.text.length == 0 ? @"```\n```" : @"\n```\n```"];
                 [self setSelectionRange:selectionRange];
             }],
             [self createButtonWithTitle:@"图片链接" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 2;
                 
                 [self insertText:@"![]()"];
                 [self setSelectionRange:self.selectedRange];
             }],
             [self createButtonWithTitle:@"任务" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 7;
                 
                 [self insertText:self.text.length == 0 ? @"- [ ] " : @"\n- [ ] "];
                 [self setSelectionRange:selectionRange];
             }],
             [self createButtonWithTitle:@"引用" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 3;
                 
                 [self insertText:self.text.length == 0 ? @"> " : @"\n> "];
                 [self setSelectionRange:selectionRange];
             }]];
}

- (RFToolbarButton *)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler {
    return [RFToolbarButton buttonWithTitle:title andEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelectionRange:(NSRange)range {
    UIColor *previousTint = self.tintColor;
    
    self.tintColor = UIColor.clearColor;
    self.selectedRange = range;
    self.tintColor = previousTint;
}
@end
