//
//  CodingTip.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "CodingTip.h"
#import "Login.h"

@implementation CodingTip

- (void)setId:(NSNumber *)id{
    if ([id isKindOfClass:[NSString class]]){
        _id = @([(NSString *)id integerValue]);
    }else{
        _id = id;
    }
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeImageAndMonkey];
        _content = _htmlMedia.contentDisplay;
    }
    if (_target_type.length > 0) {
        [self adjust];
    }
}

- (void)setTarget_type:(NSString *)target_type{
    _target_type = target_type;
    if (_content.length > 0) {
        [self adjust];
    }
}

- (void)adjust{
    //根据 content、target_type 去重组数据
    if ([_target_type isEqualToString:@"Depot"]) {//您导入的仓库（xxx）成功。点击查看：<a>playmore</a>
        _user_item = [HtmlMediaItem htmlMediaItemWithTypeATUser:[Login curLoginUser] mediaRange:NSMakeRange(0, 0)];
    }else if ([_target_type isEqualToString:@"Task"] && _htmlMedia.mediaItems.count == 1){//任务提醒
        _user_item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_CustomLink];
        _user_item.linkStr = @"任务提醒";
        _user_item.href = [(HtmlMediaItem *)_htmlMedia.mediaItems.firstObject href];
    }else if ([_target_type isEqualToString:@"Tweet"] && _htmlMedia.mediaItems.count == 1){//冒泡推荐
        _user_item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_CustomLink];
        _user_item.linkStr = @"冒泡提醒";
        _user_item.href = [(HtmlMediaItem *)_htmlMedia.mediaItems.firstObject href];
    }else if ([_target_type isEqualToString:@"User"] && _htmlMedia.mediaItems.count <= 0){
        _user_item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_CustomLink];
        _user_item.linkStr = @"账号提醒";
    }else{
        _user_item = [_htmlMedia.mediaItems firstObject];
        [_htmlMedia removeItem:_user_item];
    }
    if (_htmlMedia.mediaItems.count > 0) {
        _target_item = [_htmlMedia.mediaItems lastObject];
        [_htmlMedia removeItem:_target_item];
    }
    _target_type_ColorName = [[CodingTip p_color_dict] objectForKey:_target_type];
    if (_target_type_ColorName.length <= 0) {
        _target_type_ColorName = @"0x379FD3";
    }
    _target_type_imageName = [NSString stringWithFormat:@"tipIcon_%@", _target_type];
    _content = _htmlMedia.contentDisplay;
}

+ (NSDictionary *)p_color_dict{
    static NSDictionary *color_dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color_dict = @{
                       @"BranchMember" : @"0x1AB6D9",
                       @"CommitLineNote" : @"",
                       @"Depot" : @"",
                       @"MergeRequestBean" : @"0x4E74B7",
                       @"MergeRequestComment" : @"0x4E74B7",
                       @"Project" : @"0xF8BE46",
                       @"ProjectFileComment" : @"",
                       @"ProjectMember" : @"0x1AB6D9",
                       @"ProjectPayment" : @"",
                       @"ProjectTopic" : @"0x2FAEEA",
                       @"ProjectTweet" : @"0xFB8638",
                       @"ProjectTweetComment" : @"0xFB8638",
                       @"tweetReward" : @"0xFB8638",
                       @"TweetReward" : @"0xFB8638",
                       @"PullRequestBean" : @"0x49C9A7",
                       @"PullRequestComment" : @"0x49C9A7",
                       @"QcTask" : @"0x3C8CEA",
                       @"Task" : @"0x379FD3",
                       @"TaskComment" : @"0x379FD3",
                       @"Tweet" : @"0xFB8638",
                       @"TweetComment" : @"0xFB8638",
                       @"TweetLike" : @"0xFF5847",
                       @"User" : @"0x496AB3",
                       @"UserFollow" : @"0x3BBD79",
                       @"ProjectTopicCommentVote": @"",
                       };
    });
    return color_dict;
}
@end
