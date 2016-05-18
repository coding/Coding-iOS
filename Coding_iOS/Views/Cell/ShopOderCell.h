//
//  ShopOderCell.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"
@interface ShopOderCell : UITableViewCell
{

}

@property (nonatomic, assign) CGFloat cellHeight;

- (void)configViewWithModel:(BaseModel *)model;

@end
