// RDVTabBarItem.h
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

@interface RDVTabBarItem : UIControl

/**
 * itemHeight is an optional property. When set it is used instead of tabBar's height.
 */
@property CGFloat itemHeight;

#pragma mark - Title configuration

/**
 * The title displayed by the tab bar item.
 */
@property (nonatomic, copy) NSString *title;

/**
 * The offset for the rectangle around the tab bar item's title.
 */
@property (nonatomic) UIOffset titlePositionAdjustment;

/**
 * For title's text attributes see
 * https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
 */

/**
 * The title attributes dictionary used for tab bar item's unselected state.
 */
@property (copy) NSDictionary *unselectedTitleAttributes;

/**
 * The title attributes dictionary used for tab bar item's selected state.
 */
@property (copy) NSDictionary *selectedTitleAttributes;

#pragma mark - Image configuration

/**
 * The offset for the rectangle around the tab bar item's image.
 */
@property (nonatomic) UIOffset imagePositionAdjustment;

/**
 * The image used for tab bar item's selected state.
 */
- (UIImage *)finishedSelectedImage;

/**
 * The image used for tab bar item's unselected state.
 */
- (UIImage *)finishedUnselectedImage;

/**
 * Sets the tab bar item's selected and unselected images.
 */
- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage;

#pragma mark - Background configuration

/**
 * The background image used for tab bar item's selected state.
 */
- (UIImage *)backgroundSelectedImage;

/**
 * The background image used for tab bar item's unselected state.
 */
- (UIImage *)backgroundUnselectedImage;

/**
 * Sets the tab bar item's selected and unselected background images.
 */
- (void)setBackgroundSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage;

#pragma mark - Badge configuration

/**
 * Text that is displayed in the upper-right corner of the item with a surrounding background.
 */
@property (nonatomic, copy) NSString *badgeValue;

/**
 * Image used for background of badge.
 */
@property (strong) UIImage *badgeBackgroundImage;

/**
 * Color used for badge's background.
 */
@property (strong) UIColor *badgeBackgroundColor;

/**
 * Color used for badge's text.
 */
@property (strong) UIColor *badgeTextColor;

/**
 * The offset for the rectangle around the tab bar item's badge.
 */
@property (nonatomic) UIOffset badgePositionAdjustment;

/**
 * Font used for badge's text.
 */
@property (nonatomic) UIFont *badgeTextFont;

@end
