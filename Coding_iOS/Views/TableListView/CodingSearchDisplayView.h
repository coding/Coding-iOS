//
//  CodingSearchDisplayView.h
//  Coding_iOS
//
//  Created by Ease on 2016/12/15.
//  Copyright © 2016年 Coding. All rights reserved.
//

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
#import "PublicSearchModel.h"

@interface CodingSearchDisplayView : UIView
@property (nonatomic,assign)eSearchType curSearchType;
@property (strong, nonatomic) NSString *searchBarText;
@property (nonatomic, strong) PublicSearchModel *searchPros;
@property (copy, nonatomic) void(^cellClickedBlock)(id clickedItem, eSearchType searType);
@property (copy, nonatomic) void(^goToConversationBlock)(User *curUser);
@property (copy, nonatomic) void(^refreshAllBlock)();

@end
