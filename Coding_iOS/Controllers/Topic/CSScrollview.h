//
//  CSScrollview.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CSScrollTime 5.0
@class CSScrollItem;
typedef void (^CSScrollTapBlock)(CSScrollItem* item);

//简单来说，就是scrollview + pageControl的功能
@interface CSScrollview : UIView
@property (nonatomic, copy) CSScrollTapBlock tapBlk;
@property (nonatomic, assign) BOOL autoScrollEnable;
@property (nonatomic, assign) BOOL showPageControl;
@property (nonatomic, strong, readonly) NSArray* items;

- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewFlowLayout*)layout;
- (void)update:(NSArray*)datas;
@end


@interface CSScrollItem : NSObject
@property (nonatomic, strong) id data;
@property (nonatomic, copy) NSString* imgUrl;
+ (instancetype)itemWithData:(id)data imgUrl:(NSString*)imgUrl;
@end

@interface CSScrollUnit : UICollectionViewCell
@property (nonatomic, strong) CSScrollItem* refIteml;
@end