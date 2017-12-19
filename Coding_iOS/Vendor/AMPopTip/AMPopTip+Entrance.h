//
//  AMPopTip+Entrance.h
//  AMPopTip
//
//  Created by Andrea Mazzini on 10/06/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

#import "AMPopTip.h"

@interface AMPopTip (Entrance)

/** Perform entrance animation
 *
 * Triggers the chosen entrance animation
 *
 * @param completion Completion handler
 */
- (void)performEntranceAnimation:(nullable void (^)())completion;

@end
