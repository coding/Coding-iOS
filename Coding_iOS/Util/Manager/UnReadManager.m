//
//  UnReadManager.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-23.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UnReadManager.h"
#import "Coding_NetAPIManager.h"

@implementation UnReadManager
+ (instancetype)shareManager{
    static UnReadManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _messages = [NSNumber numberWithInteger:0];
        _notifications = [NSNumber numberWithInteger:0];
        _project_update_count = [NSNumber numberWithInteger:0];
    }
    return self;
}
- (void)updateUnRead{
    [[Coding_NetAPIManager sharedManager] request_UnReadCountWithBlock:^(id data, NSError *error) {
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            self.messages = [dataDict objectForKey:kUnReadKey_messages];
            self.notifications = [dataDict objectForKey:kUnReadKey_notifications];
            self.project_update_count = [dataDict objectForKey:kUnReadKey_project_update_count];
            //更新应用角标
            NSInteger unreadCount = self.messages.integerValue
            +self.notifications.integerValue;
//            +self.project_update_count.integerValue;
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
        }
    }];
}
- (void)updateUnReadOfNotification{
    [[Coding_NetAPIManager sharedManager] request_UnReadNotificationsWithBlock:^(id data, NSError *error) {
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            self.notification_at = [dataDict objectForKey:kUnReadKey_notification_AT];
            self.notification_comment = [dataDict objectForKey:kUnReadKey_notification_Comment];
            self.notification_system = [dataDict objectForKey:kUnReadKey_notification_System];
        }
    }];
}
- (void)setMessages:(NSNumber *)messages{
    if (_messages.integerValue != messages.integerValue) {
        _messages = messages;
    }
}
- (void)setNotifications:(NSNumber *)notifications{
    if (_notifications.integerValue != notifications.integerValue) {
        _notifications = notifications;
    }
}
- (void)setProject_update_count:(NSNumber *)project_update_count{
    if (_project_update_count.integerValue != project_update_count.integerValue) {
        _project_update_count = project_update_count;
    }
}
- (void)setNotification_at:(NSNumber *)notification_at{
    if (_notification_at.integerValue != notification_at.integerValue) {
        _notification_at = notification_at;
    }
}
- (void)setNotification_system:(NSNumber *)notification_system{
    if (_notification_system.integerValue != notification_system.integerValue) {
        _notification_system = notification_system;
    }
}
- (void)setNotification_comment:(NSNumber *)notification_comment{
    if (_notification_comment.integerValue != notification_comment.integerValue) {
        _notification_comment = notification_comment;
    }
}
@end
