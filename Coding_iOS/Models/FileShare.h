//
//  FileShare.h
//  Coding_iOS
//
//  Created by Ease on 2016/11/3.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileShare : NSObject
@property (strong, nonatomic) NSString *url;
+ (FileShare *)instanceWithUrl:(NSString *)url;

@end
