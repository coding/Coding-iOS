//
//  CSMyTopicVC.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "User.h"
@interface CSMyTopicVC : BaseViewController<iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) NSArray *segmentItems;
@property (strong, nonatomic) User *curUser;
@end

@interface CSMyTopicView : UIView
@property (nonatomic,weak)UIViewController *parentVC;
@end
