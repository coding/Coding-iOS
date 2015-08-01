//
//  ProjectTag.m
//  Coding_iOS
//
//  Created by Ease on 15/7/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectTag.h"
#import "Login.h"

@implementation ProjectTag

- (instancetype)init
{
    self = [super init];
    if (self) {
        _id = @(0);
        _count = @(0);
        _owner_id = [Login curLoginUser].id;
        _name = @"";
    }
    return self;
}

- (NSString *)color{
    if (_color.length <= 0) {
        _color = [NSString stringWithFormat:@"#%@", [[UIColor randomColor] hexStringFromColor]];
    }
    return _color;
}

+ (instancetype)tagWithName:(NSString *)name{
    ProjectTag *tag = [[self alloc] init];
    tag.name = name;
    return tag;
}

+ (BOOL)tags:(NSArray *)aTags isEqualTo:(NSArray *)bTags{
    if (aTags.count == 0 && bTags.count == 0) {
        return YES;
    }
    BOOL isSame = YES;
    if (aTags.count != bTags.count ||
        (aTags.count == 0 && bTags.count == 0)) {
        isSame = NO;
    }else{
        for (ProjectTag *mdTag in aTags) {
            BOOL tempHasOne = NO;
            for (ProjectTag *tempTag in bTags) {
                tempHasOne = (tempTag.id.integerValue == mdTag.id.integerValue);
                if (tempHasOne) {
                    break;
                }
            }
            isSame = tempHasOne;
            if (!isSame) {
                break;
            }
        }
    }
    return isSame;
}
+ (instancetype)tags:(NSArray *)aTags hasTag:(ProjectTag *)curTag{
    ProjectTag *resultTag = nil;
    for (ProjectTag *tempTag in aTags) {
        if (tempTag.id.integerValue == curTag.id.integerValue) {
            resultTag = tempTag;
            break;
        }
    }
    return resultTag;
}
@end