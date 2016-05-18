//
//  CategorySearchBar.h
//  Coding_iOS
//
//  Created by jwill on 15/11/18.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectBlock)();

@interface CategorySearchBar : UISearchBar
-(void)patchWithCategoryWithSelectBlock:(SelectBlock)block;
-(void)setSearchCategory:(NSString*)title;
@end


@interface MainSearchBar : UISearchBar
@property (strong, nonatomic) UIButton *scanBtn;
@end
