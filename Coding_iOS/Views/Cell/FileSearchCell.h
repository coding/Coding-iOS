//
//  FileSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kFileSearchCellHeight 75

#import <UIKit/UIKit.h>
#import "ProjectFile.h"

@interface FileSearchCell : UITableViewCell
@property (strong, nonatomic) ProjectFile *file;

@end
