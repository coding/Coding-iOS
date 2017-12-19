//
//  AMPopTip+Draw.m
//  AMPopTip
//
//  Created by Andrea Mazzini on 10/06/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

#import "AMPopTip+Draw.h"

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

@implementation AMPopTip (Draw)

- (UIBezierPath *)pathWithRect:(CGRect)rect direction:(AMPopTipDirection)direction {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGRect baloonFrame;

    // Drawing a round rect and the arrow alone sometime shows a white halfpixel line, so here's a fun bit of code... feel free to fall asleep
    switch (direction) {
        case AMPopTipDirectionNone: {
            baloonFrame = (CGRect){ (CGPoint) { self.borderWidth, self.borderWidth }, (CGSize){ self.frame.size.width - self.borderWidth * 2, self.frame.size.height - self.borderWidth * 2} };
            path = [UIBezierPath bezierPathWithRoundedRect:baloonFrame cornerRadius:self.radius];

            break;
        }
        case AMPopTipDirectionDown: {
            baloonFrame = (CGRect){ (CGPoint) { 0, self.arrowSize.height }, (CGSize){ rect.size.width - self.borderWidth * 2, rect.size.height - self.arrowSize.height - self.borderWidth * 2} };

            [path moveToPoint:(CGPoint){ self.arrowPosition.x + self.borderWidth, self.arrowPosition.y }];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x + self.arrowSize.width / 2, self.arrowPosition.y + self.arrowSize.height }];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.radius, self.arrowSize.height }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius,  self.arrowSize.height + self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width, self.arrowSize.height + baloonFrame.size.height - self.radius }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius,  self.arrowSize.height + baloonFrame.size.height - self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(90) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.radius, self.arrowSize.height + baloonFrame.size.height }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius,  self.arrowSize.height + baloonFrame.size.height - self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(180) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.borderWidth, self.arrowSize.height + self.radius }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius, self.arrowSize.height + self.radius } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(270) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x - self.arrowSize.width / 2, self.arrowPosition.y + self.arrowSize.height }];
            [path closePath];

            break;
        }
        case AMPopTipDirectionUp: {
            baloonFrame = (CGRect){ (CGPoint) { 0, 0 }, (CGSize){ rect.size.width - self.borderWidth * 2, rect.size.height - self.arrowSize.height - self.borderWidth * 2 } };

            [path moveToPoint:(CGPoint){ self.arrowPosition.x + self.borderWidth, self.arrowPosition.y - self.borderWidth }];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x + self.arrowSize.width / 2, self.arrowPosition.y - self.arrowSize.height - self.borderWidth }];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.radius, baloonFrame.origin.y + baloonFrame.size.height + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius, baloonFrame.origin.y + baloonFrame.size.height - self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(0) clockwise:NO];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width, baloonFrame.origin.y + self.radius + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(270) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.radius, baloonFrame.origin.y + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(180) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ self.borderWidth + self.radius, baloonFrame.origin.y + baloonFrame.size.height - self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(90) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth + self.arrowPosition.x - self.arrowSize.width / 2, self.arrowPosition.y - self.arrowSize.height - self.borderWidth }];
            [path closePath];

            break;
        }
        case AMPopTipDirectionLeft: {
            // Flip the size around for the left/right poptip
            CGSize arrowSize = CGSizeMake(self.arrowSize.height, self.arrowSize.width);
            baloonFrame = (CGRect){ (CGPoint) { 0, 0 }, (CGSize){ rect.size.width - arrowSize.width - self.borderWidth * 2, rect.size.height - self.borderWidth * 2} };

            [path moveToPoint:(CGPoint){ self.arrowPosition.x - self.borderWidth, self.arrowPosition.y }];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x - arrowSize.width - self.borderWidth, self.arrowPosition.y - arrowSize.height / 2 }];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.borderWidth, baloonFrame.origin.y + self.radius }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(270) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.radius + self.borderWidth, baloonFrame.origin.y + self.borderWidth}];
            [path addArcWithCenter:(CGPoint){ self.radius + self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(180) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ self.radius + self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(90) clockwise:NO];
            [path addLineToPoint:(CGPoint){ baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.size.width - self.radius -  self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius -  self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(0) clockwise:NO];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x - arrowSize.width - self.borderWidth, self.arrowPosition.y + arrowSize.height / 2 }];
            [path closePath];

            break;
        }
        case AMPopTipDirectionRight: {
            // Flip the size around for the left/right poptip
            CGSize arrowSize = CGSizeMake(self.arrowSize.height, self.arrowSize.width);
            baloonFrame = (CGRect){ (CGPoint) { arrowSize.width, 0 }, (CGSize){ rect.size.width - arrowSize.width - self.borderWidth * 2, rect.size.height - self.borderWidth * 2} };

            [path moveToPoint:(CGPoint){ self.arrowPosition.x + self.borderWidth, self.arrowPosition.y }];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x + arrowSize.width + self.borderWidth, self.arrowPosition.y - arrowSize.height / 2 }];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + self.radius + self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(180) endAngle:DEGREES_TO_RADIANS(270) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + self.borderWidth}];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + self.radius + self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(0) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth }];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + baloonFrame.size.width - self.radius - self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth} radius:self.radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(90) clockwise:YES];
            [path addLineToPoint:(CGPoint){ baloonFrame.origin.x + self.radius + self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.borderWidth}];
            [path addArcWithCenter:(CGPoint){ baloonFrame.origin.x + self.radius + self.borderWidth, baloonFrame.origin.y + baloonFrame.size.height - self.radius - self.borderWidth } radius:self.radius startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(180) clockwise:YES];
            [path addLineToPoint:(CGPoint){ self.arrowPosition.x + arrowSize.width + self.borderWidth, self.arrowPosition.y + arrowSize.height / 2 }];
            [path closePath];
            
            break;
        }
    }
    return path;
}

@end
