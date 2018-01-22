//
//  EAWiki.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "FileShare.h"

@interface EAWiki : NSObject
@property (strong, nonatomic) User *creator, *editor;
@property (strong, nonatomic) NSNumber *id, *iid, *historyId, *currentUserRoleId, *historiesCount, *lastVersion, *currentVersion, *parentIid, *order, *version;
@property (strong, nonatomic) NSNumber *project_id;//需要从别的地方拿数据
@property (strong, nonatomic) NSString *title, *content, *html, *msg, *path;
@property (strong, nonatomic) NSDate *createdAt, *updatedAt;
@property (strong, nonatomic) NSArray *children;
@property (strong, nonatomic, readonly) NSDictionary *propertyArrayMap;

@property (readwrite, nonatomic, strong) FileShare *share;

@property (readonly, strong, nonatomic) EAWiki *parentWiki;
@property (readonly, nonatomic, strong) NSArray *childrenDisplayList;

@property (assign, nonatomic) BOOL isExpanded;
@property (readonly, assign, nonatomic) NSInteger lavel;
@property (readonly, assign, nonatomic) BOOL isHistoryVersion, hasChildren;

@property (strong, nonatomic) NSString *mdTitle, *mdContent;//edit
@property (strong, nonatomic) NSNumber *draftVersion;

- (BOOL)hasDraft;
- (BOOL)draftVersionChanged;
- (BOOL)hasChanged;
- (void)saveDraft;
- (void)readDraft;
- (void)deleteDraft;

- (NSDictionary *)toShareParams;
@end
