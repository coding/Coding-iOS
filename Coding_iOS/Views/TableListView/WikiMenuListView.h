//
//  WikiMenuListView.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/4/5.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAWiki.h"

@interface WikiMenuListView : UIView
@property (copy, nonatomic) void(^selectedWikiBlock)(EAWiki *wiki);

- (void)setWikiList:(NSArray<EAWiki *> *)wikiList selectedWiki:(EAWiki *)selectedWiki;
- (void)show;
- (void)dismiss;
@end
