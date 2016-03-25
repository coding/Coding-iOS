//
//  ResourceReference.h
//  Coding_iOS
//
//  Created by Ease on 16/2/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceReference : NSObject
@property (strong, nonatomic) NSMutableArray *Task, *MergeRequestBean, *ProjectTopic, *ProjectFile, *itemList;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

@end

@interface ResourceReferenceItem : NSObject
@property (strong, nonatomic) NSString *target_type, *title, *link;
@property (strong, nonatomic) NSNumber *code, *target_id;
@end