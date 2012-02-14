//
//  StationTextField.m
//  tube
//
//  Created by sergey on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationTextField.h"

@implementation StationTextField

@synthesize state;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewFrame = self.rightView.frame;
    
    CGRect newFrame;
    
    newFrame.origin.x=bounds.size.width-rightViewFrame.size.width-bounds.size.width*0.0375;
    newFrame.origin.y=bounds.size.height/2-rightViewFrame.size.height/2;
    newFrame.size.width=rightViewFrame.size.width;
    newFrame.size.height = rightViewFrame.size.height;
    
    return newFrame;
}


- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftViewFrame = self.leftView.frame;
    
    CGRect newFrame;
    
    newFrame.origin.x=13.0;
    newFrame.origin.y=bounds.size.height/2-leftViewFrame.size.height/2;
    newFrame.size.width=leftViewFrame.size.width;
    newFrame.size.height = leftViewFrame.size.height;
    
    return newFrame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 20, 0);
}

-(void) drawTextInRect:(CGRect)rect
{
    
    CGRect newFrame;
    CGSize textBounds = [self.text sizeWithFont:self.font];
    
    newFrame.origin.x=3.0;
    newFrame.origin.y=3.0;
    newFrame.size.width=rect.size.width-10.0;
    newFrame.size.height = textBounds.height;
    
    [super drawTextInRect:newFrame];
}

@end
