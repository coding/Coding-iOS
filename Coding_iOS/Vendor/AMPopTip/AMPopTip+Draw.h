//
//  AMPopTip+Draw.h
//  AMPopTip
//
//  Created by Andrea Mazzini on 10/06/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

#import "AMPopTip.h"

@interface AMPopTip (Draw)

/** Poptip's Bezier path
 *
 * Returns the path used to draw the poptip, used internally by the poptip.
 *
 * @param rect The rect holding the poptip
 * @param direction The direction of the poptip appearance
 * @return UIBezierPath The poptip's path
 */
- (nonnull UIBezierPath *)pathWithRect:(CGRect)rect direction:(AMPopTipDirection)direction;

@end
