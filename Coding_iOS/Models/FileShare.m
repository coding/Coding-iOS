//
//  FileShare.m
//  Coding_iOS
//
//  Created by Ease on 2016/11/3.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "FileShare.h"

@implementation FileShare
+ (FileShare *)instanceWithUrl:(NSString *)url{
    FileShare *share = [self new];
    share.url = url.copy;
    return share;
}
@end
