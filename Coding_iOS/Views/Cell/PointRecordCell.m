//
//  PointRecordCell.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointRecordCell.h"

@implementation PointRecordCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setCurRecord:(PointRecord *)curRecord{
    _curRecord = curRecord;
    if (!_curRecord) {
        return;
    }
    
}
+ (CGFloat)cellHeight{
    return 44.0;
}
@end
