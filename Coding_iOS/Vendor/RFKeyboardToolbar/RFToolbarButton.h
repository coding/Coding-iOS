//
//  RFToolbarButton.h
//
//  Created by Rudd Fawcett on 12/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The block used for each button.
 */
typedef void (^eventHandlerBlock)();

@interface RFToolbarButton : UIButton

/**
 *  Creates a new RFToolbarButton.
 *
 *  @param title The string to show on the button.
 *
 *  @return A new button.
 */
+ (instancetype)buttonWithTitle:(NSString *)title;

/**
 *  Creates a new RFToolbarButton.
 *
 *  @param title        The string to show on the button.
 *  @param eventHandler The event handler block.
 *  @param controlEvent The type of event.
 *
 *  @return A new button.
 */
+ (instancetype)buttonWithTitle:(NSString *)title andEventHandler:(eventHandlerBlock)eventHandler forControlEvents:(UIControlEvents)controlEvent;

/**
 *  Adds the event handler for the button.
 *
 *  @param eventHandler The event handler block.
 *  @param controlEvent The type of event.
 */
- (void)addEventHandler:(eventHandlerBlock)eventHandler forControlEvents:(UIControlEvents)controlEvent;

@end
