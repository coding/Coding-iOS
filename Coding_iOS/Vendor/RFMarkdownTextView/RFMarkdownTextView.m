//
//  RFMarkdownTextView.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/1/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFMarkdownTextView.h"

@interface RFMarkdownTextView ()

@property (strong,nonatomic) RFMarkdownSyntaxStorage *syntaxStorage;

@end

@implementation RFMarkdownTextView

- (id)initWithFrame:(CGRect)frame {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    _syntaxStorage = [RFMarkdownSyntaxStorage new];
    [_syntaxStorage appendAttributedString:attrString];
    
    CGRect newTextViewRect = frame;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    CGSize containerSize = CGSizeMake(newTextViewRect.size.width,  CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    
    [layoutManager addTextContainer:container];
    [_syntaxStorage addLayoutManager:layoutManager];
    
    if (self = [super initWithFrame:frame textContainer:container]) {
        self.delegate = self;
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
             [self createButtonWithTitle:@"Link" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 1;
                 [self insertText:@"[]()"];
                 [self setSelectionRange:selectionRange];
                 
             }],
             [self createButtonWithTitle:@"Codeblock" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += self.text.length == 0 ? 3 : 4;
                 
                 [self insertText: self.text.length == 0 ? @"```\n```" : @"\n```\n```"];
                 [self setSelectionRange:selectionRange];
             }],
             [self createButtonWithTitle:@"Image" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 2;
                 
                 [self insertText:@"![]()"];
                 [self setSelectionRange:self.selectedRange];
             }],
             [self createButtonWithTitle:@"Task" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 7;
                 
                 [self insertText:self.text.length == 0 ? @"- [ ] " : @"\n- [ ] "];
                 [self setSelectionRange:selectionRange];
             }],
             [self createButtonWithTitle:@"Quote" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 3;

                 [self insertText:self.text.length == 0 ? @"> " : @"\n> "];
                 [self setSelectionRange:selectionRange];
             }]];
}

- (void)setSelectionRange:(NSRange)range {
    UIColor *previousTint = self.tintColor;
    
    self.tintColor = UIColor.clearColor;
    self.selectedRange = range;
    self.tintColor = previousTint;
}

- (RFToolbarButton *)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler {
    return [RFToolbarButton buttonWithTitle:title andEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
}

- (void)textViewDidChange:(UITextView *)textView {
    [_syntaxStorage update];
}

@end