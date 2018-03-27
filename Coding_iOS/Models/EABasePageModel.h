//
//  EABasePageModel.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EABasePageModel : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;

@property (readwrite, nonatomic, strong) NSMutableArray *list;//需要指定数据类型的数据
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;//指定数据类型的字典

- (NSMutableDictionary *)toParams;
- (void)configWithObj:(EABasePageModel *)resultA;
@end
