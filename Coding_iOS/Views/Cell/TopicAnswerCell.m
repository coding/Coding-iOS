//
//  TopicAnswerCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/18.
//  Copyright © 2016年 Coding. All rights reserved.

#import "TopicAnswerCell.h"
#import "TopicCommentCell.h"
#import "TopicAnswerCommentMoreCell.h"


@interface TopicAnswerCell ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation TopicAnswerCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_myTableView) {
            _myTableView = ({
                UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
                tableView.backgroundColor = [UIColor clearColor];
                tableView.scrollEnabled = NO;
                tableView.delegate = self;
                tableView.dataSource = self;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment];
                [tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment_Media];
                [tableView registerClass:[TopicAnswerCommentMoreCell class] forCellReuseIdentifier:kCellIdentifier_TopicAnswerCommentMoreCell];
                [self.contentView addSubview:tableView];
                [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.contentView);
                }];
                tableView;
            });
            
            UIView *topLineV = [UIView new];
            topLineV.backgroundColor = kColorDDD;
            [_myTableView addSubview:topLineV];
            [topLineV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.right.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
            }];
        }
    }
    return self;
}

- (void)setCurAnswer:(ProjectTopic *)curAnswer{
    _curAnswer = curAnswer;
    [_myTableView reloadData];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *answer = (ProjectTopic *)obj;
        cellHeight += [TopicCommentCell cellHeightWithObj:answer];
        for (int index = 0; index < [answer commentsDisplayNum]; index++) {
            cellHeight += [TopicCommentCell cellHeightWithObj:answer.child_comments[index]];
        }
        cellHeight += answer.child_count.integerValue > [answer commentsDisplayNum]? [TopicAnswerCommentMoreCell cellHeight]: 0;
    }
    return cellHeight;
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 1;
    num += [_curAnswer commentsDisplayNum];
    num += _curAnswer.child_count.integerValue > [_curAnswer commentsDisplayNum]? 1: 0;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row -1 < [_curAnswer commentsDisplayNum]){
        ProjectTopic *toComment;
        CGFloat leftSpace;
        if (indexPath.row == 0) {
            toComment = _curAnswer;
            leftSpace = [_curAnswer commentsDisplayNum] > 0? kPaddingLeftWidth + 40: kScreen_Width;
        }else{
            toComment = _curAnswer.child_comments[indexPath.row - 1];
            leftSpace = (indexPath.row - 1 == [_curAnswer commentsDisplayNum] - 1)? kScreen_Width: kPaddingLeftWidth + 40;
        }
        TopicCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:toComment.htmlMedia.imageItems.count > 0? kCellIdentifier_TopicComment_Media: kCellIdentifier_TopicComment forIndexPath:indexPath];
        cell.toComment = toComment;
        cell.isAnswer = indexPath.row == 0;
        cell.projectId = _projectId;
        cell.contentLabel.delegate = self;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:leftSpace hasSectionLine:NO];
        return cell;
    }else{
        TopicAnswerCommentMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicAnswerCommentMoreCell forIndexPath:indexPath];
        cell.commentNum = _curAnswer.child_count;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row -1 < [_curAnswer commentsDisplayNum]){
        ProjectTopic *toComment = indexPath.row == 0? _curAnswer: _curAnswer.child_comments[indexPath.row - 1];
        cellHeight = [TopicCommentCell cellHeightWithObj:toComment];
    }else{
        cellHeight = [TopicAnswerCommentMoreCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProjectTopic *toComment = nil;
    if (indexPath.row -1 < [_curAnswer commentsDisplayNum]){
        toComment = indexPath.row == 0? _curAnswer: _curAnswer.child_comments[indexPath.row - 1];
    }
    if (self.commentClickedBlock) {
        self.commentClickedBlock(_curAnswer, toComment, [tableView cellForRowAtIndexPath:indexPath]);
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    if (self.linkStrBlock) {
        self.linkStrBlock(clickedItem.href);
    }
}

@end
