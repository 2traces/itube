//
//  StationTextField.m
//  tube
//
//  Created by Sergey Mingalev on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationTextField.h"
#import "SSTheme.h"
#import <QuartzCore/QuartzCore.h>

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

#pragma mark - custom init
- (id)initWithFrame:(CGRect)frame andStyle:(StationTextFieldStyle)style
{
    if (style==StationTextFieldStyleDefault) {
        self = [self initWithFrame:frame];
        if (self) {
            self.borderStyle = UITextBorderStyleNone;
            self.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0];
            self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
            self.backgroundColor = [UIColor clearColor];
            self.textAlignment = UITextAlignmentLeft;
            self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            self.rightViewMode = UITextFieldViewModeAlways;
            self.autocorrectionType=UITextAutocorrectionTypeNo;
            self.autocapitalizationType=UITextAutocapitalizationTypeNone;
            [self setReturnKeyType:UIReturnKeyDone];
            [self setClearButtonMode:UITextFieldViewModeNever];
            self.state=style;
        }
        return self;
    }
    
    return nil;
}


#pragma mark - Style Changes

-(void)changeStyleTo:(StationTextFieldStyle)style withFrame:(CGRect)frame animated:(BOOL)animated
{
    switch (style) {
        case StationTextFieldStyleDefault:
            if (animated) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.frame=frame;
                    //self.background = [[UIImage imageNamed:@"toolbar_bg.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0];
                    self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
                }];
            }

            break;
        case StationTextFieldStyleSearch:
            if (animated) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.frame=frame;
                    self.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroungHighlighted] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 63.0, 0, 93.0)];
                    self.text = @"";
                    self.rightViewMode = UITextFieldViewModeAlways;
                    self.leftView=nil;
                    self.leftViewMode=UITextFieldViewModeAlways;
                    self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
                    self.state=style;
                }];
            }
            
            break;
        case StationTextFieldStyleStation:
            self.state=style;
            break;
        case StationTextFieldStylePath:
            self.state=style;
            break;
            
        default:
            break;
    }
}


#pragma mark - TextField override

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewFrame = self.rightView.frame;
    
    CGRect newFrame;
    
    newFrame.origin.x=bounds.size.width-rightViewFrame.size.width-[[SSThemeManager sharedTheme] stationTextFieldRightAdjust];
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
    
    newFrame.origin.x=[[SSThemeManager sharedTheme] stationTextFieldDrawTextInRectAdjust]; //3.0 _original
    newFrame.origin.y=3.0;
    newFrame.size.width=rect.size.width-10.0;
    newFrame.size.height = textBounds.height;
    
    
    if ([[SSThemeManager sharedTheme] isNewTheme]) {
        CGSize myShadowOffset = CGSizeMake(0, 1);
        float myColorValues[] = {0.84, 0.62, 0.47, 1.0};
        
        CGContextRef myContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(myContext);
        
        CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
        CGContextSetShadowWithColor (myContext, myShadowOffset, 0, myColor);
        
        [super drawTextInRect:newFrame];
        
        CGColorRelease(myColor);
        CGColorSpaceRelease(myColorSpace);
        
        CGContextRestoreGState(myContext);
    } else {
        [super drawTextInRect:newFrame];
    }
    
}

- (void)drawPlaceholderInRect:(CGRect)rect 
{
    CGRect newFrame;
    CGSize textBounds = [self.placeholder sizeWithFont:self.font];
    
    newFrame.origin.x=18.0;
    newFrame.origin.y=3.0;
    newFrame.size.width=rect.size.width-10.0;
    newFrame.size.height = textBounds.height;
    
    [super drawPlaceholderInRect:newFrame];
}

@end
