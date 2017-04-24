//
//  UITableViewCell+Common.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/18.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "UITableViewCell+Common.h"
#import "ObjcRuntime.h"

@implementation UITableViewCell (Common)
- (void)customSetAccessoryType:(UITableViewCellAccessoryType)type{
    NSInteger accessoryTag = 1234;
    if (type == UITableViewCellAccessoryDisclosureIndicator) {
        if (self.accessoryView.tag != accessoryTag) {
            UIView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_left"] highlightedImage:[UIImage imageNamed:@"cell_arrow_left"]];
            accessoryView.tag = accessoryTag;
            self.accessoryView = accessoryView;
        }
        self.accessoryView.hidden = NO;
        [self customSetAccessoryType:type];
    }else{
        if (self.accessoryView.tag == accessoryTag) {
            self.accessoryView.hidden = YES;
        }
        [self customSetAccessoryType:type];
    }
}

//- (void)customSetSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle{
//    NSInteger selectionTag = 1235;
//    if (selectionStyle == UITableViewCellSelectionStyleDefault) {
//        if (self.selectedBackgroundView.tag != selectionTag) {
//            UIView *selectedBGV = [UIView new];
//            selectedBGV.backgroundColor = [UIColor randomColor];
//            self.selectedBackgroundView = selectedBGV;
//        }
//        [self customSetSelectionStyle:selectionStyle];
//    }else{
//        [self customSetSelectionStyle:selectionStyle];
//    }
//}

- (void)customSetSelected:(BOOL)selected{
    NSInteger selectionTag = 1235;
    if (self.selectionStyle == UITableViewCellSelectionStyleDefault) {
        if (self.selectedBackgroundView.tag != selectionTag) {
            UIView *selectedBGV = [UIView new];
            selectedBGV.backgroundColor = kColorD8DDE4;
            self.selectedBackgroundView = selectedBGV;
        }
        [self customSetSelected:selected];
    }else{
        [self customSetSelected:selected];
    }
}

+ (void)load{
    swizzleAllCell();
}

@end

void swizzleAllCell(){
    Swizzle([UITableViewCell class], @selector(setAccessoryType:), @selector(customSetAccessoryType:));
//    Swizzle([UITableViewCell class], @selector(setSelectionStyle:), @selector(customSetSelectionStyle:));
    Swizzle([UITableViewCell class], @selector(setSelected:), @selector(customSetSelected:));
}
