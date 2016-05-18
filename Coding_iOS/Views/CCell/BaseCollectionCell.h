//
//  BaseCollectionCell.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"

@interface BaseCollectionCell : UICollectionViewCell

- (void)configViewWithModel:(BaseModel *)model;

@end
