//
//  EACodeReleaseAttachmentsOrReferencesCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/23.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EACodeRelease.h"

typedef NS_ENUM(NSUInteger, EACodeReleaseAttachmentsOrReferencesCellType) {
    EACodeReleaseAttachmentsOrReferencesCellTypeAttachments = 0,
    EACodeReleaseAttachmentsOrReferencesCellTypeReferences,
};

@interface EACodeReleaseAttachmentsOrReferencesCell : UITableViewCell

@property (copy, nonatomic) void(^itemClickedBlock)(id item);

- (void)setupCodeRelease:(EACodeRelease *)curR type:(EACodeReleaseAttachmentsOrReferencesCellType)type;

+ (CGFloat)cellHeightWithObj:(EACodeRelease *)obj type:(EACodeReleaseAttachmentsOrReferencesCellType)type;

@end
