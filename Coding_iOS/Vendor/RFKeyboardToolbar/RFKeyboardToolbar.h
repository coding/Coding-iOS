//
//  RFKeyboardToolbar.h
//
//  Created by Rudd Fawcett on 12/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AvailabilityMacros.h>

#import "RFToolbarButton.h"

@interface RFKeyboardToolbar : UIView

/**
 *  The buttons of the toolbar.
 */
@property (nonatomic, strong) NSArray *buttons;

/**
 *  Creates a new toolbar.
 *
 *  @param buttons The buttons to draw in the view.
 *
 *  @return A RFKeyboardToolbar.
 */
+ (instancetype)toolbarWithButtons:(NSArray *)buttons;

/**
 *  Creates a new toolbar.
 *
 *  @param buttons The buttons to draw in the view.
 *
 *  @return A RFKeyboardToolbar.
 */
+ (instancetype)toolbarViewWithButtons:(NSArray *)buttons DEPRECATED_MSG_ATTRIBUTE("This will still work, but there's a shorter method available, toolbarWithButtons:");

/**
 *  
 *
 *  @param buttons  Sets the buttons for the toolbar.
 *  @param animated Whether or not it should be animated.
 */
- (void)setButtons:(NSArray *)buttons animated:(BOOL)animated;

@end
