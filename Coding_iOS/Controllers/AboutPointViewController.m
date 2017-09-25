//
//  AboutPointViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/9/18.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "AboutPointViewController.h"

@interface AboutPointViewController ()
@property (weak, nonatomic) IBOutlet UILabel *aboutL;

@end

@implementation AboutPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于码币";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_aboutL.text];
    //段落
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineSpacing:5.0];
//    [paragraphStyle setParagraphSpacing:10];
    [paragraphStyle setLineBreakMode:_aboutL.lineBreakMode];
    [paragraphStyle setAlignment:_aboutL.textAlignment];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_aboutL.text length])];
    //标题
    NSArray *titleList = @[@"什么是码币", @"可以用码币做什么", @"如何获取码币"];
    for (NSString *title in titleList) {
        NSRange textR = [_aboutL.text rangeOfString:title];
        if (textR.location != NSNotFound) {
            [attributedString addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightMedium],
                                              NSForegroundColorAttributeName: kColorDark3} range:textR];
        }
    }
    _aboutL.attributedText = attributedString;
}

@end
