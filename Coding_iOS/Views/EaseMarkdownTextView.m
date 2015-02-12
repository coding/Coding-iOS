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
#import <RegexKitLite/RegexKitLite.h>

//at某人的功能
#import "UsersViewController.h"
#import "ProjectMemberListViewController.h"
#import "Users.h"
#import "Login.h"


@implementation EaseMarkdownTextView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.inputAccessoryView = [RFKeyboardToolbar toolbarWithButtons:[self buttons]];
    }
    return self;
}

- (NSArray *)buttons {
    return @[
             [self createButtonWithTitle:@"@" andEventHandler:^{ [self doAT]; }],
             
             [self createButtonWithTitle:@"#" andEventHandler:^{ [self insertText:@"#"]; }],
             [self createButtonWithTitle:@"*" andEventHandler:^{ [self insertText:@"*"]; }],
             [self createButtonWithTitle:@"`" andEventHandler:^{ [self insertText:@"`"]; }],
             [self createButtonWithTitle:@"-" andEventHandler:^{ [self insertText:@"-"]; }],
             
             
             
             [self createButtonWithTitle:@"标题" andEventHandler:^{ [self doTitle]; }],
             [self createButtonWithTitle:@"粗体" andEventHandler:^{ [self doBold]; }],
             [self createButtonWithTitle:@"斜体" andEventHandler:^{ [self doItalic]; }],
             [self createButtonWithTitle:@"代码" andEventHandler:^{ [self doCode]; }],
             [self createButtonWithTitle:@"引用" andEventHandler:^{ [self doQuote]; }],
             [self createButtonWithTitle:@"列表" andEventHandler:^{ [self doList]; }],
             
             [self createButtonWithTitle:@"链接" andEventHandler:^{
                 NSString *tipStr = @"在此输入链接描述";
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 1;
                 selectionRange.length = tipStr.length;

                 [self insertText:[NSString stringWithFormat:@"[%@]()", tipStr]];
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"图片链接" andEventHandler:^{
                 NSString *tipStr = @"在此输入图片描述";
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 2;
                 selectionRange.length = tipStr.length;

                 [self insertText:[NSString stringWithFormat:@"![%@]()", tipStr]];
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"分割线" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 NSString *insertStr = [self needPreNewLine]? @"\n\n------\n": @"\n------\n";
                 
                 selectionRange.location += insertStr.length;
                 selectionRange.length = 0;
                 
                 [self insertText:insertStr];
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"_" andEventHandler:^{ [self insertText:@"_"]; }],
             [self createButtonWithTitle:@"+" andEventHandler:^{ [self insertText:@"+"]; }],
             [self createButtonWithTitle:@"~" andEventHandler:^{ [self insertText:@"~"]; }],
             [self createButtonWithTitle:@"=" andEventHandler:^{ [self insertText:@"="]; }],
             [self createButtonWithTitle:@"[" andEventHandler:^{ [self insertText:@"["]; }],
             [self createButtonWithTitle:@"]" andEventHandler:^{ [self insertText:@"]"]; }],
             [self createButtonWithTitle:@"<" andEventHandler:^{ [self insertText:@"<"]; }],
             [self createButtonWithTitle:@">" andEventHandler:^{ [self insertText:@">"]; }]
             ];
}

- (BOOL)needPreNewLine{
    NSString *preStr = [self.text substringToIndex:self.selectedRange.location];
    return !(preStr.length == 0
            || [preStr isMatchedByRegex:@"[\\n\\r]+[\\t\\f]*$"]);
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

#pragma mark md_Method
- (void)doTitle{
    [self doMDWithLeftStr:@"## " rightStr:@" ##" tipStr:@"在此输入标题" doNeedPreNewLine:YES];
}

- (void)doBold{
    [self doMDWithLeftStr:@"**" rightStr:@"**" tipStr:@"在此输入粗体文字" doNeedPreNewLine:NO];
}

- (void)doItalic{
    [self doMDWithLeftStr:@"*" rightStr:@"*" tipStr:@"在此输入斜体文字" doNeedPreNewLine:NO];
}

- (void)doCode{
    [self doMDWithLeftStr:@"```\n" rightStr:@"\n```" tipStr:@"在此输入代码片段" doNeedPreNewLine:YES];
}

- (void)doQuote{
    [self doMDWithLeftStr:@"> " rightStr:@"" tipStr:@"在此输入引用文字" doNeedPreNewLine:YES];
}

- (void)doList{
    [self doMDWithLeftStr:@"- " rightStr:@"" tipStr:@"在此输入列表项" doNeedPreNewLine:YES];
}

- (void)doMDWithLeftStr:(NSString *)leftStr rightStr:(NSString *)rightStr tipStr:(NSString *)tipStr doNeedPreNewLine:(BOOL)doNeedPreNewLine{
    
    BOOL needPreNewLine = doNeedPreNewLine? [self needPreNewLine]: NO;
    
    
    if (!leftStr || !rightStr || !tipStr) {
        return;
    }
    NSRange selectionRange = self.selectedRange;
    NSString *insertStr = [self.text substringWithRange:selectionRange];
    
    if (selectionRange.length > 0) {//已有选中文字
        //撤销
        if (selectionRange.location >= leftStr.length && selectionRange.location + selectionRange.length + rightStr.length <= self.text.length) {
            NSRange expandRange = NSMakeRange(selectionRange.location- leftStr.length, selectionRange.length +leftStr.length +rightStr.length);
            expandRange = [self.text rangeOfString:[NSString stringWithFormat:@"%@%@%@", leftStr, insertStr, rightStr] options:NSLiteralSearch range:expandRange];
            if (expandRange.location != NSNotFound) {
                selectionRange.location -= leftStr.length;
                selectionRange.length = insertStr.length;
                [self setSelectionRange:expandRange];
                [self insertText:insertStr];
                [self setSelectionRange:selectionRange];
                return;
            }
        }
        //添加
        selectionRange.location += needPreNewLine? leftStr.length +1: leftStr.length;
        insertStr = [NSString stringWithFormat:needPreNewLine? @"\n%@%@%@": @"%@%@%@", leftStr, insertStr, rightStr];
    }else{//未选中任何文字
        //添加
        selectionRange.location += needPreNewLine? leftStr.length +1: leftStr.length;
        selectionRange.length = tipStr.length;
        insertStr = [NSString stringWithFormat:needPreNewLine? @"\n%@%@%@": @"%@%@%@", leftStr, tipStr, rightStr];
    }
    [self insertText:insertStr];
    [self setSelectionRange:selectionRange];
}

#pragma mark AT
- (void)doAT{
    __weak typeof(self) weakSelf = self;
    if (self.curProject) {
        //@项目成员
        [ProjectMemberListViewController showATSomeoneWithBlock:^(User *curUser) {
            [weakSelf atSomeUser:curUser andRange:self.selectedRange];
        } withProject:self.curProject];
    }else{
        //@好友
        [UsersViewController showATSomeoneWithBlock:^(User *curUser) {
            [weakSelf atSomeUser:curUser andRange:self.selectedRange];
        }];
    }
}

- (void)atSomeUser:(User *)curUser andRange:(NSRange)range{
    if (curUser) {
        NSString *appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
        [self insertText:appendingStr];
    }
}


@end
