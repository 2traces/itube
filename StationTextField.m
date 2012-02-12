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

-(void)layoutSubviews
{
    if (state==3) {
        CGRect rect = self.rightView.frame;
        self.rightView.frame = CGRectMake(self.rightView.frame.origin.x-20,self.rightView.frame.origin.y-20.0, self.rightView.frame.size.width, self.rightView.frame.size.height);
    }
    
    [super layoutSubviews];
}

@end
