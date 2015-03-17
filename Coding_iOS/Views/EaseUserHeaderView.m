//
//  EaseUserHeaderView.m
//  Coding_iOS
//
//  Created by Ease on 15/3/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EaseUserHeaderView.h"

@implementation EaseUserHeaderView

+ (id)userHeaderViewWithUser:(User *)user image:(UIImage *)image{
    if (!user || !image) {
        return nil;
    }
    CGRect headerFrame;
    if ([user.global_key isEqualToString:[Login curLoginUser].global_key]) {
        headerFrame = CGRectMake(0, 0, kScreen_Width, 200);
    }else{
        headerFrame = CGRectMake(0, 0, kScreen_Width, 300);
    }
    
    
    
    EaseUserHeaderView *headerView = [[EaseUserHeaderView alloc] initWithFrame:headerFrame];
    headerView.image = image;
    headerView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    
    
    
    return headerView;
}

@end
