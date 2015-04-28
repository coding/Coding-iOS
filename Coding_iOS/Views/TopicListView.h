//
//  TopicListView.h
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TopicListViewBlock)(NSInteger index);
typedef void(^TopicListViewHideBlock)();

@interface TopicListView : UIView

- (id)initWithFrame:(CGRect)frame
             titles:(NSArray *)titles
            numbers:(NSArray *)numbers
       defaultIndex:(NSInteger)index
      selectedBlock:(TopicListViewBlock)selectedHandle
          hideBlock:(TopicListViewHideBlock)hideHandle;
- (void)changeWithTitles:(NSArray *)titles
                 numbers:(NSArray *)numbers
            defaultIndex:(NSInteger)index
           selectedBlock:(TopicListViewBlock)selectedHandle
               hideBlock:(TopicListViewHideBlock)hideHandle;

- (void)showBtnView;
- (void)hideBtnView;

@end
