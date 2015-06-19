//
//  User.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "User.h"

@implementation User
+ (User *)userWithGlobalKey:(NSString *)global_key{
    User *curUser = [[User alloc] init];
    curUser.global_key = global_key;
    return curUser;
}
- (BOOL)isSameToUser:(User *)user{
    if (!user) {
        return NO;
    }
    return ((self.id && user.id && self.id.integerValue == user.id.integerValue)
            || (self.global_key && user.global_key && [self.global_key isEqualToString:user.global_key]));
}
- (NSString *)toUserInfoPath{
    return [NSString stringWithFormat:@"api/user/key/%@", _global_key];
}

- (NSString *)toResetPasswordPath{
    return @"api/user/updatePassword";
}
- (NSDictionary *)toResetPasswordParams{
    return @{@"current_password" : [self.curPassword sha1Str],
             @"password" : [self.resetPassword sha1Str],
             @"confirm_password" : [self.resetPasswordConfirm sha1Str]};
}

- (NSString *)toFllowedOrNotPath{
    NSString *path;
    path = _followed.boolValue ? @"api/user/unfollow" : @"api/user/follow";
    return path;
}
- (NSDictionary *)toFllowedOrNotParams{
    NSDictionary *dict;
    if (_global_key) {
        dict = @{@"users" : _global_key};
    }else if (_id){
        dict = @{@"users" : _id};
    }
    return dict;
}

- (NSString *)company{
    if (_company && _company.length > 0) {
        return _company;
    }else{
        return @"未填写";
    }
}

- (NSString *)job_str{
    if (_job_str && _job_str.length > 0) {
        return _job_str;
    }else{
        return @"未填写";
    }
}
- (NSString *)location{
    if (_location && _location.length > 0) {
        return _location;
    }else{
        return @"未填写";
    }
}
- (NSString *)tags_str{
    if (_tags_str && _tags_str.length > 0) {
        return _tags_str;
    }else{
        return @"未添加";
    }
}
- (NSString *)slogan{
    if (_slogan && _slogan.length > 0) {
        return _slogan;
    }else{
        return @"未填写";
    }
}

- (void)setName:(NSString *)name{
    _name = name;
    if (_name) {
        _pinyinName = [_name transformToPinyin];
    }
}

- (NSString *)pinyinName{
    if (!_pinyinName) {
        return @"";
    }
    return _pinyinName;
}

- (NSString *)toUpdateInfoPath{
    return @"api/user/updateInfo";
}
- (NSDictionary *)toUpdateInfoParams{
    return @{@"id" : _id,
             @"email" : _email? _email: @"",
             @"global_key" : _global_key? _global_key: @"",
//             暂时没用到
//             @"introduction" : _introduction,
//             @"phone" : _phone,
//             /static/fruit_avatar/Fruit-20.png
             @"lavatar" : _avatar? _avatar: [NSString stringWithFormat:@"/static/fruit_avatar/Fruit-%d.png", (rand()%20)+1],
             @"name" : _name? _name: @"",
             @"sex" : _sex? _sex: [NSNumber numberWithInteger:2],
             @"birthday" : _birthday? _birthday: @"",
             @"location" : _location? _location: @"",
             @"slogan" : _slogan? _slogan: @"",
             @"company" : _company? _company: @"",
             @"job" : _job? _job: [NSNumber numberWithInteger:0],
             @"tags" : _tags? _tags: @""};
}
- (NSString *)toDeleteConversationPath{
    return [NSString stringWithFormat:@"api/message/conversations/%@", self.id.stringValue];
}
- (NSString *)localFriendsPath{
    return @"FriendsPath";
}

- (NSString *)changePasswordTips{
    NSString *tipStr = nil;
    if (!self.curPassword || self.curPassword.length <= 0){
        tipStr = @"请输入当前密码";
    }else if (!self.resetPassword || self.resetPassword.length <= 0){
        tipStr = @"请输入新密码";
    }else if (!self.resetPasswordConfirm || self.resetPasswordConfirm.length <= 0) {
        tipStr = @"请确认新密码";
    }else if (![self.resetPassword isEqualToString:self.resetPasswordConfirm]){
        tipStr = @"两次输入的密码不一致";
    }else if (self.resetPassword.length < 6){
        tipStr = @"新密码不能少于6位";
    }else if (self.resetPassword.length > 64){
        tipStr = @"新密码不得长于64位";
    }
    return tipStr;
}
@end
