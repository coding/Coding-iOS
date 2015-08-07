//
//  CSTopiclistView.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

typedef void(^TopicListViewBlock)(NSDictionary* topic);
typedef enum {
    CSMyTopicsTypeWatched,
    CSMyTopicsTypeJoined,
}CSMyTopicsType;

@interface CSTopiclistView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,assign)BOOL isMe;
- (id)initWithFrame:(CGRect)frame globalKey:(NSString *)key type:(CSMyTopicsType )type block:(TopicListViewBlock)block;
- (void)setTopics:(id )topics;
- (void)refreshToQueryData;

@end

