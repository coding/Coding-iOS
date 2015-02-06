//
//  RFToolbarButton.m
//
//  Created by Rudd Fawcett on 12/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFToolbarButton.h"

@interface RFToolbarButton ()

/**
 *  The button's title.
 */
@property (nonatomic, strong) NSString *title;

/**
 *  The button's event block.
 */
@property (nonatomic, copy) eventHandlerBlock buttonPressBlock;

@end

@implementation RFToolbarButton

+ (instancetype)buttonWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title];
}

+ (instancetype)buttonWithTitle:(NSString *)title andEventHandler:(eventHandlerBlock)eventHandler forControlEvents:(UIControlEvents)controlEvent {
    RFToolbarButton *newButton = [RFToolbarButton buttonWithTitle:title];
    [newButton addEventHandler:eventHandler forControlEvents:controlEvent];
    
    return newButton;
}

- (id)initWithTitle:(NSString *)title {
    _title = title;
    return [self init];
}

- (id)init {
    CGSize sizeOfText = [self.title sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.f]}];
    
    if (self = [super initWithFrame:CGRectMake(0, 0, sizeOfText.width + 18.104, sizeOfText.height + 10.298)]) {
        self.backgroundColor = [UIColor colorWithWhite:0.902 alpha:1.0];
        
        self.layer.cornerRadius = 3.0f;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        
        [self setTitle:self.title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithWhite:0.500 alpha:1.0] forState:UIControlStateNormal];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.500 alpha:1.0];
    }
    return self;
}

- (void)addEventHandler:(eventHandlerBlock)eventHandler forControlEvents:(UIControlEvents)controlEvent {
    self.buttonPressBlock = eventHandler;
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:controlEvent];
}

- (void)buttonPressed {
    self.buttonPressBlock();
}

@end
