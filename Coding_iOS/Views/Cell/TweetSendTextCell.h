//
//  TweetSendTextCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TweetSendText @"TweetSendTextCell"

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "Users.h"
#import "AGEmojiKeyBoardView.h"

@interface TweetSendTextCell : UITableViewCell<UITextViewDelegate>
@property (nonatomic, strong) UIView *footerToolBar;
@property (strong, nonatomic) UIPlaceHolderTextView *tweetContentView;
- (void)setLocationStr:(NSString *)locationStr;

@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);
@property (nonatomic,copy) void(^photoBtnBlock)();
@property (nonatomic,copy) void(^locationBtnBlock)();
@property (nonatomic,copy) void(^topicBtnBlock)();
+ (CGFloat)cellHeight;
@end
