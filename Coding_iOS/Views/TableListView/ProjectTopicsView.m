//
//  ProjectTopicsView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopicsView.h"
#import "TopicListView.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTag.h"

@interface ProjectTopicsView ()
{
    NSArray *_one;
    NSMutableArray *_two;
    NSArray *_three;
    NSArray *_total;
    NSMutableArray *_oneNumber;
    NSMutableArray *_twoNumber;
    NSMutableArray *_totalIndex;
    NSInteger _segIndex;
}

@property (nonatomic, strong) Project *myProject;
@property (nonatomic, copy) ProjectTopicBlock block;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) ProjectTopicListView *mylistView;

@property (strong, nonatomic) NSMutableArray *labelsAll;
@property (strong, nonatomic) NSMutableArray *labelsMy;

@end

@implementation ProjectTopicsView

- (id)initWithFrame:(CGRect)frame
            project:(Project *)project
              block:(ProjectTopicBlock)block
       defaultIndex:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProject = project;
        _block = block;

        ProjectTopics *curProTopics = [ProjectTopics topicsWithPro:_myProject queryType:0];
        _mylistView = [[ProjectTopicListView alloc] initWithFrame:CGRectMake(0, kMySegmentControl_Height, kScreen_Width, self.frame.size.height - kMySegmentControl_Height)
                                                     projectTopics:curProTopics
                                                            block:_block];
        [self addSubview:_mylistView];
        [_mylistView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMySegmentControl_Height, 0, 0, 0));
        }];
        
        // 添加滑块
        _one = @[@"全部讨论", @"我的讨论"];
        _two = [NSMutableArray arrayWithObjects:@"全部标签", nil];
        _three = @[@"最后评论排序", @"发布时间排序", @"热门排序"];
        _total = @[_one, _two, _three];
        _oneNumber = [NSMutableArray arrayWithObjects:@0, @0, nil];
        _twoNumber = [NSMutableArray arrayWithObjects:@0, nil];
        _totalIndex = [NSMutableArray arrayWithObjects:@0, @0, @0, nil];
        __weak typeof(self) weakSelf = self;
        self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height)
                                                                  Items:@[_one[0], _two[0], _three[0]]
                                                               withIcon:YES
                                                          selectedBlock:^(NSInteger index) {
                                                              [weakSelf openList:index];
                                                          }];
        [self addSubview:self.mySegmentControl];
        
        _labelsAll = [[NSMutableArray alloc] initWithCapacity:4];
        _labelsMy = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)refreshToQueryData
{
    [self sendLabelRequest];
    [self sendCountRequest];
    [_mylistView refreshToQueryData];
}

- (NSString *)toCountPath
{
    return [NSString stringWithFormat:@"api/project/%d/topic/count", _myProject.id.intValue];
}

//- (NSString *)toLabelAllPath
//{
//    return [NSString stringWithFormat:@"api/user/%@/project/%@/topics/labels", _myProject.owner_user_name, _myProject.name];
//}

- (NSString *)toLabelMyPath
{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/topics/labels/my", _myProject.owner_user_name, _myProject.name];
}

- (void)sendLabelRequest
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_TagListInProject:_myProject type:ProjectTagTypeTopic andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf parseLabelInfo:data];
        }
    }];
}

- (void)sendCountRequest
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectTopic_Count_WithPath:[self toCountPath] andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf parseCountInfo:data];
        }
    }];
    [[Coding_NetAPIManager sharedManager] request_ProjectTopic_LabelMy_WithPath:[self toLabelMyPath] andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf parseCountMyInfo:data];
        }
    }];
}

- (void)parseLabelInfo:(NSArray *)labelInfo
{
    if ([_totalIndex[0] integerValue] == 0) {
        NSInteger tempIndex = 0;
        ProjectTag *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsAll[[_totalIndex[1] integerValue] - 1] : nil;
        
        [_labelsAll removeAllObjects];
        [_two removeAllObjects];
        [_two addObject:@"全部标签"];
        [_twoNumber removeAllObjects];
        [_twoNumber addObject:_oneNumber[0]];
        for (ProjectTag *lbl in labelInfo) {
            if ([lbl.count integerValue] > 0) {
                [_labelsAll addObject:lbl];
                [_two addObject:lbl.name];
                [_twoNumber addObject:lbl.count];
                
                if (tempLbl && [tempLbl.id isEqualToNumber:lbl.id]) {
                    tempIndex = _two.count - 1;
                }
            }
        }
    
        [_totalIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:tempIndex]];
        [self.mySegmentControl setTitle:_two[tempIndex] withIndex:1];
        
        [self changeOrder];
    } else {
        [_labelsAll removeAllObjects];
        [_twoNumber removeAllObjects];
        [_twoNumber addObject:_oneNumber[0]];
        for (ProjectTag *lbl in labelInfo) {
            if ([lbl.count integerValue] > 0) {
                [_labelsAll addObject:lbl];
                [_twoNumber addObject:lbl.count];
            }
        }
    }
}

- (void)parseCountMyInfo:(NSArray *)labelInfo
{
    if ([_totalIndex[0] integerValue] == 1) {
        NSInteger tempIndex = 0;
        ProjectTag *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsMy[[_totalIndex[1] integerValue] - 1] : nil;
        
        [_labelsMy removeAllObjects];
        [_labelsMy addObjectsFromArray:labelInfo];
        [_two removeAllObjects];
        [_two addObject:@"全部标签"];
        for (ProjectTag *lbl in labelInfo) {
            [_two addObject:lbl.name];
            
            if (tempLbl && [tempLbl.id isEqualToNumber:lbl.id]) {
                tempIndex = _two.count - 1;
            }
        }
        
        [_totalIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:tempIndex]];
        [self.mySegmentControl setTitle:_two[tempIndex] withIndex:1];
        
        [self changeOrder];
    } else {
        [_labelsMy removeAllObjects];
        [_labelsMy addObjectsFromArray:labelInfo];
    }
}

- (void)parseCountInfo:(NSDictionary *)dic
{
    _oneNumber[0] = [dic objectForKey:@"all"];
    _oneNumber[1] = [dic objectForKey:@"my"];
    _twoNumber[0] = _oneNumber[0];
}

- (void)changeIndex:(NSInteger)index withSegmentIndex:(NSInteger)segmentIndex
{
    [_totalIndex replaceObjectAtIndex:segmentIndex withObject:[NSNumber numberWithInteger:index]];
    if (segmentIndex == 0) {
        NSInteger tempIndex = 0;
        if (index == 0) {
            ProjectTag *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsMy[[_totalIndex[1] integerValue] - 1] : nil;
            [_two removeAllObjects];
            [_two addObject:@"全部标签"];
            for (int i=0; i<_labelsAll.count; i++) {
                ProjectTag *lbl = _labelsAll[i];
                [_two addObject:lbl.name];
                
                if (tempLbl && [tempLbl.id isEqualToNumber:lbl.id]) {
                    tempIndex = i + 1;
                }
            }
        } else {
            ProjectTag *tempLbl = [_totalIndex[1] integerValue] > 0 ? _labelsAll[[_totalIndex[1] integerValue] - 1] : nil;
            [_two removeAllObjects];
            [_two addObject:@"全部标签"];
            for (int i=0; i<_labelsMy.count; i++) {
                ProjectTag *lbl = _labelsMy[i];
                [_two addObject:lbl.name];
                
                if (tempLbl && [tempLbl.id isEqualToNumber:lbl.id]) {
                    tempIndex = i + 1;
                }
            }
        }

        [_totalIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:tempIndex]];
        [self.mySegmentControl setTitle:_two[tempIndex] withIndex:1];
    }
 
    [self.mySegmentControl setTitle:_total[segmentIndex][index] withIndex:segmentIndex];

    [self changeOrder];
}

- (void)changeOrder
{
    if ([_totalIndex[1] integerValue] > 0) {
        if ([_totalIndex[0] integerValue] > 0) {
            ProjectTag *lbl = _labelsMy[[_totalIndex[1] integerValue] - 1];
            [_mylistView setOrder:[_totalIndex[2] integerValue] withLabelID:lbl.id andType:[_totalIndex[0] integerValue]];
        } else {
            ProjectTag *lbl = _labelsAll[[_totalIndex[1] integerValue] - 1];
            [_mylistView setOrder:[_totalIndex[2] integerValue] withLabelID:lbl.id andType:[_totalIndex[0] integerValue]];
        }
    } else {
        [_mylistView setOrder:[_totalIndex[2] integerValue] withLabelID:@0 andType:[_totalIndex[0] integerValue]];
    }
}

- (void)openList:(NSInteger)segmentIndex
{
    TopicListView *lView = (TopicListView *)[self viewWithTag:9898];
    if (!lView) {
        // 显示
        _segIndex = segmentIndex;
        NSArray *lists = (NSArray *)_total[segmentIndex];
        CGRect rect = CGRectMake(0, kMySegmentControl_Height, kScreen_Width, self.frame.size.height - kMySegmentControl_Height);

        NSArray *nAry = nil;
        if (segmentIndex == 0) {
            nAry = _oneNumber;
        } else if (segmentIndex == 1 && [_totalIndex[0] integerValue] == 0) {
            nAry = _twoNumber;
        }
        __weak typeof(self) weakSelf = self;
        TopicListView *listView = [[TopicListView alloc] initWithFrame:rect
                                                                titles:lists
                                                               numbers:nAry
                                                          defaultIndex:[_totalIndex[segmentIndex] integerValue]
                                                         selectedBlock:^(NSInteger index) {
                                                             [weakSelf changeIndex:index withSegmentIndex:segmentIndex];
                                                         }
                                                             hideBlock:^() {
                                                             [weakSelf.mySegmentControl selectIndex:-1];
                                                         }];
        listView.tag = 9898;
        [self addSubview:listView];
        [listView showBtnView];
    } else if (_segIndex != segmentIndex) {
        // 另展示
        _segIndex = segmentIndex;
        
        NSArray *nAry = nil;
        if (segmentIndex == 0) {
            nAry = _oneNumber;
        } else if (segmentIndex == 1 && [_totalIndex[0] integerValue] == 0) {
            nAry = _twoNumber;
        }
        NSArray *lists = (NSArray *)_total[segmentIndex];
        __weak typeof(self) weakSelf = self;
        [lView changeWithTitles:lists
                        numbers:nAry
                   defaultIndex:[_totalIndex[segmentIndex] integerValue]
                  selectedBlock:^(NSInteger index) {
                       [weakSelf changeIndex:index withSegmentIndex:segmentIndex];
                   }
                      hideBlock:^() {
                          [weakSelf.mySegmentControl selectIndex:-1];
                      }];
    } else {
        // 隐藏
        [lView hideBtnView];
    }
}

@end
