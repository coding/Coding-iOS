//
//  DemoModel.m
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//

#import "DemoModel.h"

@implementation DemoModel

+ (DemoModel *) modelWithName:(NSString *)friendName friendId:(NSString *)friendId imageData:(NSData *)imageData
{
    DemoModel *newDemoModel = [[self alloc]init];
    newDemoModel.friendName = friendName;
    newDemoModel.friendId = friendId;
    newDemoModel.imageData = imageData;
    return newDemoModel;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.friendName forKey:NSStringFromSelector(@selector(friendName))];
    [aCoder encodeObject:self.friendId forKey:NSStringFromSelector(@selector(friendId))];
    [aCoder encodeObject:self.imageData  forKey:NSStringFromSelector(@selector(imageData))];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder //NS_DESIGNATED_INITIALIZER
{
    self = [super init];
    if (self){
        _friendName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(friendName))];
        _friendId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(friendId))];
        _imageData = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageData))];
    }
    return self;
}
@end
