//
//  MRListView.h
//  Coding_iOS
//
//  Created by Ease on 15/10/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRPRS.h"

@interface MRListView : UIView
@property (strong, nonatomic) MRPRS *curMRPRS;
@property (copy, nonatomic) void(^clickedMRBlock)(MRPR *clickedMR);

- (void)refreshToQueryData;
@end
