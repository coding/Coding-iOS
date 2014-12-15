//
//  FAImageView.m
//
//  Copyright (c) 2012 Alex Usbergo. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//
//  An UIImageView with the support of displaying
//  a vectorial icon (by using the fontawesome iconic font)
//  if the image is missing


#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@interface FAImageView : UIImageView

/* The background color for the default view displayed when the image is missing */
@property (nonatomic, strong) UIColor *defaultIconColor UI_APPEARANCE_SELECTOR;

/* Set the icon using the fontawesome icon's identifier */
@property (nonatomic, strong) NSString *defaultIconIdentifier;

/* Set the icon using the icon enumerations */
@property (nonatomic, assign) FAIcon defaultIcon;

/* The view that is displayed when the image is set to nil */
@property (nonatomic, strong) UILabel *defaultView;

@end
