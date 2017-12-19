//
//  AMPopTip+Exit.h
//  AMPopTip
//
//  Created by Valerio Mazzeo on 09/02/2016.
//  Copyright © 2016 Valerio Mazzeo. All rights reserved.
//

#import "AMPopTip.h"

@interface AMPopTip (Exit)

/** Perform exit animation
 *
 * Triggers the chosen exit animation
 *
 * @param completion Completion handler
 */
- (void)performExitAnimation:(nullable void (^)())completion;

@end
