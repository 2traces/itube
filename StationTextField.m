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
#import "tubeAppDelegate.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation StationTextField

@synthesize state;
@synthesize station;
@synthesize parentView;

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
            self.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 135)];
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
            
            UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
            UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
            
            UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightView setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
            [rightView setImage:imageOpenList forState:UIControlStateNormal];
            [rightView setImage:imageOpenListHL forState:UIControlStateHighlighted];
            self.rightView=rightView;
            
            [rightView addTarget:self action:@selector(callStationList) forControlEvents:UIControlEventTouchUpInside];
            
        }
        return self;
    }
    
    return nil;
}

#pragma mark - setStation override
-(void)setStation:(MStation *)newstation
{
    if (newstation) {
        if (station) {
            [newstation retain];
            [station release];
            station=newstation;
            
            if ([[MHelper sharedHelper] languageIndex]%2) {
                self.text = station.altname;
            } else {
                self.text = station.name;
            }
            
        } else {
            [newstation retain];
            [station release];
            station=newstation;
            
            if ([[MHelper sharedHelper] languageIndex]%2) {
                self.text = station.altname;
            } else {
                self.text = station.name;
            }
            
            [self changeStyleTo:StationTextFieldStyleStation withFrame:self.frame animated:YES];
        }
    } else {
        if (station) {
            station=nil;
            self.text=nil;
            [self changeStyleTo:StationTextFieldStyleDefault withFrame:self.frame animated:YES];
        }
    }
}

#pragma mark - Style Changes

-(void)changeStyleTo:(StationTextFieldStyle)style withFrame:(CGRect)frame animated:(BOOL)animated
{
    switch (style) {
        case StationTextFieldStyleDefault:
        {
            
            NSTimeInterval animduration;
            if (animated) {
                animduration=0.2;
            } else {
                animduration=-1;
            }
            
            [UIView animateWithDuration:animduration animations:^{
                self.frame=frame;
                self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
                self.textColor = [UIColor blackColor];
                self.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 135)];
                self.rightViewMode = UITextFieldViewModeAlways;
                self.state=style;
                
                self.text = [station name];
                
                
                self.leftView=nil;
                self.leftViewMode =  UITextFieldViewModeNever;
            }];

            UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
            UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
            
            UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightView setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
            [rightView setImage:imageOpenList forState:UIControlStateNormal];
            [rightView setImage:imageOpenListHL forState:UIControlStateHighlighted];
            [rightView addTarget:self action:@selector(callStationList) forControlEvents:UIControlEventTouchUpInside];
            
            self.rightView=rightView;

        }
            
            break;
        case StationTextFieldStyleSearch:
        {
            
            NSTimeInterval animduration;
            if (animated) {
                animduration=0.2;
            } else {
                animduration=-1;
            }
            
            [UIView animateWithDuration:animduration animations:^{
                self.frame=frame;
                self.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 63.0, 0, 93.0)];
                self.text = @"";
                self.rightViewMode = UITextFieldViewModeAlways;
                self.leftView=nil;
                self.leftViewMode=UITextFieldViewModeAlways;
                self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
                self.textColor = [UIColor blackColor];
                
                
                self.state=style;
            }];
            
            UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
            UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
            
            UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightView setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
            [rightView setImage:imageOpenList forState:UIControlStateNormal];
            [rightView setImage:imageOpenListHL forState:UIControlStateHighlighted];
            [rightView addTarget:self action:@selector(callStationList) forControlEvents:UIControlEventTouchUpInside];
            
            self.rightView=rightView;

        }
            break;
        case StationTextFieldStyleStation:
        {
            
            NSTimeInterval animduration;
            if (animated) {
                animduration=0.2;
            } else {
                animduration=-1;
            }
            
            [UIView animateWithDuration:animduration animations:^{
                self.frame=frame;
                self.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
                self.textColor = [UIColor blackColor];
                

                self.text = [station name];

                UIImageView *lineColor = [[UIImageView alloc] initWithImage:[self imageWithColor:[station lines]]];
                [self setLeftView:lineColor];
                [lineColor release];
                
                [self setLeftViewMode: UITextFieldViewModeAlways];
                self.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroungHighlighted] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 135)];
                
            }];
            
            UIImage *crossImage = [[SSThemeManager sharedTheme] topToolbarCrossImage:UIControlStateNormal];
            UIImage *crossImageHighlighted = [[SSThemeManager sharedTheme] topToolbarCrossImage:UIControlStateHighlighted];
            
            UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [resetButton setImage:crossImage forState:UIControlStateNormal];
            [resetButton setFrame:CGRectMake(0.0, 0.0, crossImage.size.width, crossImage.size.height)];
            [resetButton setImage:crossImageHighlighted forState:UIControlStateHighlighted];
            [resetButton addTarget:self action:@selector(resetStation) forControlEvents:UIControlEventTouchUpInside];
            self.rightView= resetButton;
            self.rightViewMode = UITextFieldViewModeAlways;

            
            self.state=style;
        }
            break;
        case StationTextFieldStylePath:
            self.background = [UIImage imageNamed:@"pixeldummy.png"];
            
            if ([[SSThemeManager sharedTheme] isNewTheme]) {
                [self setLeftView:nil];
            }
            
            self.frame=frame;
            
            self.font = [[SSThemeManager sharedTheme] toolbarPathFont];
            self.textColor = [[SSThemeManager sharedTheme] toolbarPathFontColor];
            
            self.state=style;
            break;
            
        default:
            break;
    }
}

#pragma mark - button methods

-(IBAction)resetStation
{
    self.text = @"";
    [parentView resetStation:self];
}

-(IBAction)callStationList
{
    [parentView callStationList:self];
}

#pragma mark - support methods

-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), NO, 0.0);
    
    CGRect circleRect = CGRectMake(0.0, 0.0, 9.0, 9.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));
    CGContextSetLineWidth(context, 0.0);
    CGContextFillEllipseInRect(context, circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    UIImage *bevelImg = [UIImage imageNamed:@"bevel.png"];
    
    [bevelImg drawInRect:circleRect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //CGContextRelease(context);
    
    return image;
}

-(UIImage*)drawBiggerCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(12,12), NO, 0.0);
    
    CGRect circleRect = CGRectMake(1.0, 1.0, 10.0, 10.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));
    CGContextSetLineWidth(context, 0.0);
    CGContextFillEllipseInRect(context, circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    UIImage *bevelImg = [UIImage imageNamed:@"bevel.png"];
    
    [bevelImg drawInRect:circleRect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //CGContextRelease(context);
    
    return image;
}

-(UIImage*)imageWithColor:(MLine*)line
{
    if(nil == line) return nil;
    UIImage *image = [self drawCircleView:[line color]];
    return image;
}

-(UIImage*)biggerImageWithColor:(MLine*)line
{
    if(nil == line) return nil;
    UIImage *image = [self drawBiggerCircleView:[line color]];
    return image;
}

#pragma mark - TextField override

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewFrame = self.rightView.frame;
    
    CGRect newFrame;
    if (state==StationTextFieldStyleStation && [[SSThemeManager sharedTheme] isNewTheme]) {
        newFrame.origin.x=bounds.size.width-rightViewFrame.size.width-10.0f;
    } else if (state==StationTextFieldStyleSearch && [[SSThemeManager sharedTheme] isNewTheme]) {
        newFrame.origin.x=bounds.size.width-rightViewFrame.size.width-2.0f;
    } else {
        newFrame.origin.x=bounds.size.width-rightViewFrame.size.width-[[SSThemeManager sharedTheme] stationTextFieldRightAdjust];
    }
    
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
    return CGRectInset(bounds, 20, 1);
}

-(void) drawTextInRect:(CGRect)rect
{
    
    CGRect newFrame;
    CGSize textBounds = [self.text sizeWithFont:self.font];
    
    newFrame.origin.x=[[SSThemeManager sharedTheme] stationTextFieldDrawTextInRectAdjust]; //3.0 _original
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (self.state == StationTextFieldStylePath) {
            if (IS_IPAD) {
                newFrame.origin.y=15.0;
            } else {
                newFrame.origin.y=6.0;
            }
        } else {
            newFrame.origin.y=15.0;
        }
    } else {
        newFrame.origin.y=3.0;
    }
    newFrame.size.width=rect.size.width-self.leftView.frame.size.width-5.0 ;//10
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (self.state == StationTextFieldStylePath) {
            newFrame.origin.y=3.0;
        } else {
            newFrame.origin.y=14.0;
        }
    } else {
        newFrame.origin.y=3.0;
    }
    newFrame.size.width=rect.size.width-10.0;
    newFrame.size.height = textBounds.height;
    
    [super drawPlaceholderInRect:newFrame];
}

@end
