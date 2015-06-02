//
//  Depot.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Depot : NSObject
@property (strong, nonatomic) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *name, *path, *depot_path, *default_branch;
@end
