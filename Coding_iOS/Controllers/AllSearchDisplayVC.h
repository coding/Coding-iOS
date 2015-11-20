//
//  AllSearchDisplayVC.h
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

@protocol AllSearchDisplayVCdelegate <NSObject>

@optional

@end

typedef NS_ENUM(NSUInteger, eSearchType) {
    eSearchType_Project=0,
    eSearchType_Task,
    eSearchType_Topic,
    eSearchType_Tweet,
    eSearchType_Document,
    eSearchType_User,
    eSearchType_Merge,
    eSearchType_Pull,
    eSearchType_All
};

#import <UIKit/UIKit.h>

@interface AllSearchDisplayVC : UISearchDisplayController
@property (nonatomic,weak)UIViewController *parentVC;
@property (nonatomic,assign)eSearchType curSearchType;
@property (assign)id<AllSearchDisplayVCdelegate> delegate;
-(void)reloadDisplayData;
@end
