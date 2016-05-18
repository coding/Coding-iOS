//
//  CSTopicDetailVC.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CSTopicDetailVC : BaseViewController
//@property (nonatomic,strong)NSDictionary *topic;
@property (nonatomic,assign) NSInteger topicID;
@end

@interface CSTopTweetDescCell : UITableViewCell
- (void)updateUI;
@end
