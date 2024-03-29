//
//  TopTwoStationsView.m
//  tube
//
//  Created by Sergey Mingalev on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopRasterView.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "FastAccessTableViewController.h"
#import "StationTextField.h"
#import "SSTheme.h"

@implementation TopRasterView

@synthesize toolbar;
@synthesize secondStation;
@synthesize firstStation;
@synthesize firstButton;
@synthesize secondButton;
@synthesize tableView;
@synthesize arrowView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self  drawInitialState];
    }
    return self;
}

-(void)drawInitialState
{
    toolbar = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width,self.frame.size.height)];
    [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 149.0, 0, 167.0)]];
//    [toolbar setImage:[UIImage imageNamed:@"toolbar_bg2.png"]];
    [toolbar setUserInteractionEnabled:YES];
	[self addSubview:toolbar];

//	UIImage *imageOpenList = [UIImage imageNamed:@"openlist2.png"];
//    UIImage *imageOpenListHL = [UIImage imageNamed:@"openlist2.png"];
    UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
    UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
	[refreshButton setImage:imageOpenList forState:UIControlStateNormal];
	[refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
    
	firstStation = [[StationTextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	firstStation.delegate = self;
	firstStation.borderStyle = UITextBorderStyleNone;
	firstStation.rightView = refreshButton;
	firstStation.background = [UIImage imageNamed:@"toolbar_text_bg2.png"];
    firstStation.backgroundColor = [UIColor clearColor];
	firstStation.textAlignment = UITextAlignmentLeft;
	firstStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	firstStation.rightViewMode = UITextFieldViewModeAlways;
    firstStation.autocorrectionType=UITextAutocorrectionTypeNo;
    firstStation.autocapitalizationType=UITextAutocapitalizationTypeNone; 
	[firstStation setReturnKeyType:UIReturnKeyDone];
	[firstStation setClearButtonMode:UITextFieldViewModeNever];
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    firstStation.tag = 111;
    firstStation.placeholder=@"From..";
    
	[toolbar addSubview:firstStation];	
    
	UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button1 addTarget:self action:@selector(transitFirstToBigField) forControlEvents:UIControlEventTouchUpInside];
	button1.frame = CGRectMake(0, 6, 320, 44);
    self.firstButton=button1;
    
    [toolbar addSubview:button1];
    arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowIcon.png"]];
    [arrowView setFrame:CGRectMake(153, 6, 15, 15)];
    [toolbar addSubview:arrowView];
    arrowView.hidden=YES;
    [arrowView release];
    
    [toolbar release];

}

-(void)transitFirstToBigField
{
//    NSTimeInterval duration = 0.2f;
//    
//    [UIView animateWithDuration:duration animations:^{ 
        isEditing=YES;
//        
//        secondStation.hidden=YES;
//        
        firstButton.hidden=YES;
//        secondButton.hidden=YES;
//        
        firstButton.userInteractionEnabled=NO;
//        secondButton.userInteractionEnabled=NO;
//        
//        firstStation.frame = CGRectMake(0, 0, 320, 44);
//        firstStation.background = [UIImage imageNamed:@"toolbar_big_bg_lighted.png"];
//        
        firstStation.text = @"";
//        firstStation.rightViewMode = UITextFieldViewModeAlways;
//        firstStation.leftView=nil;
//        firstStation.leftViewMode=UITextFieldViewModeAlways;
//
//    }];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    FastAccessTableViewController *controller = [appDelegate.glViewController showTableView];
    
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    
    appDelegate.glViewController.currentSelection=nil;
    self.tableView=controller;
    firstStation.delegate = self.tableView;
    [firstStation becomeFirstResponder];
}

-(void)transitToPathView
{
//    NSTimeInterval duration = 0.2f;
//    
//    [UIView animateWithDuration:duration animations:^{ 
//        isEditing=NO;
//        
//        firstStation.hidden=NO;
//        firstStation.userInteractionEnabled=YES;
//        
//        secondStation.hidden=NO;
//        secondStation.userInteractionEnabled=YES;
//
//        firstButton.hidden=YES;
//        secondButton.hidden=YES;
//        
//        firstStation.background = nil;
//        secondStation.background = nil;
//        
//        firstStation.state=3;
//        
//        UIImage *crossImage = [UIImage imageNamed:@"cross_transp.png"];
//        UIImage *crossImageHighlighted = [UIImage imageNamed:@"cross_opaq.png"];
//
//        UIButton *cancelButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [cancelButton1 setImage:crossImage forState:UIControlStateNormal];
//        [cancelButton1 setFrame:CGRectMake(0.0, 0.0, crossImage.size.width, crossImage.size.height)];
//        [cancelButton1 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
//        [cancelButton1 addTarget:self action:@selector(resetFromStation) forControlEvents:UIControlEventTouchUpInside];
//
//        UIButton *cancelButton2= [UIButton buttonWithType:UIButtonTypeCustom];
//        [cancelButton2 setImage:crossImage forState:UIControlStateNormal];
//        [cancelButton2 setFrame:CGRectMake(0.0, 0.0, crossImage.size.width, crossImage.size.height)];
//        [cancelButton2 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
//        [cancelButton2 addTarget:self action:@selector(resetToStation) forControlEvents:UIControlEventTouchUpInside];
//
//        firstStation.rightView= cancelButton1;
//        firstStation.rightViewMode = UITextFieldViewModeAlways;
//        secondStation.rightView = cancelButton2;
//        secondStation.rightViewMode = UITextFieldViewModeAlways;
// 
//        CGFloat addWidth = 60;
//        CGFloat maxWidth = 160;
//        
//        CGSize textBounds1 = [firstStation.text sizeWithFont:firstStation.font];
//        CGSize textBounds2 = [secondStation.text sizeWithFont:secondStation.font];
//        
//        CGFloat desireWidth1;
//        CGFloat desireWidth2;
//        CGFloat desireOrigin1;
//        CGFloat desireOrigin2;
//        CGFloat arrowOrigin;
//        
//        if (textBounds1.width+textBounds2.width+addWidth*2+arrowView.frame.size.width>maxWidth*2) {
//            if (textBounds1.width+addWidth>maxWidth && textBounds2.width+addWidth>maxWidth) {
//                desireWidth1=maxWidth;
//                desireWidth2=maxWidth;
//                desireOrigin1 = 0;
//                desireOrigin2 = 160;
//                arrowOrigin = 153;
//            } else if (textBounds1.width+addWidth>=maxWidth && textBounds2.width+addWidth<=maxWidth) {
//                desireWidth2=textBounds2.width+addWidth;
//                desireOrigin2=320-desireWidth2;
//                desireOrigin1=0;
//                desireWidth1 = desireOrigin2 - arrowView.frame.size.width;
//                arrowOrigin = desireWidth1+(desireOrigin2-desireWidth1)/2-8;
//            } else {
//                desireWidth1=textBounds1.width+addWidth;
//                desireOrigin1=0;
//                desireOrigin2=desireWidth1+arrowView.frame.size.width;
//                desireWidth2=320 -desireOrigin2;
//                arrowOrigin=desireWidth1;
//            }
//                
//        } else {
//            desireWidth1=textBounds1.width+addWidth;
//            desireWidth2=textBounds2.width+addWidth;
//            desireOrigin1=0;
//            desireOrigin2=320-desireWidth2;
//            arrowOrigin = desireWidth1+(desireOrigin2-desireWidth1)/2-8;
//        }
//        
//        firstStation.frame = CGRectMake(desireOrigin1, 0,desireWidth1, 26);
//        secondStation.frame = CGRectMake(desireOrigin2, 0, desireWidth2, 26);
//        
//        self.frame=CGRectMake(0, 0, 320, 26); 
//        self.toolbar.frame=CGRectMake(0, 0, 320, 26); 
//        [toolbar setImage:[UIImage imageNamed:@"upper_path_bg.png"]];
//        
//        arrowView.hidden=NO;
//        arrowView.frame =CGRectMake(arrowOrigin, arrowView.frame.origin.y, arrowView.frame.size.width, arrowView.frame.size.height);
//        
//        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
//        
//        //UIImageView *lineColor1 = [[UIImageView alloc] initWithImage:[self biggerImageWithColor:[appDelegate.mainViewController.fromStation lines]]];
//        //[firstStation setLeftView:lineColor1];
//        //[lineColor1 release];
//
//        //UIImageView *lineColor2 = [[UIImageView alloc] initWithImage:[self biggerImageWithColor:[appDelegate.mainViewController.toStation lines]]];
//        //[secondStation setLeftView:lineColor2];
//        //[lineColor2 release];
//        
//    }];
//    
//    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
//    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
}

-(void)transitToInitialSize
{
//    NSTimeInterval duration = 0.2f;
//    
//    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;
//        
        firstStation.hidden=NO;
//        firstStation.userInteractionEnabled=YES;
//        
//        secondStation.hidden=NO;
//        secondStation.userInteractionEnabled=YES;
//        
        firstButton.hidden=NO;
        firstButton.userInteractionEnabled = YES;
//        secondButton.hidden=NO;
//        
//        firstStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];
//        secondStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];
//       
//        
//        UIImage *imageOpenList = [UIImage imageNamed:@"openlist.png"];
//        UIImage *imageOpenListHL = [UIImage imageNamed:@"openlist_highlight.png"];
//        
//        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [refreshButton setImage:imageOpenList forState:UIControlStateNormal];
//        [refreshButton setImage:imageOpenListHL forState:UIControlStateHighlighted];
//        [refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
//        [refreshButton setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
//
//        
//        firstStation.rightView = refreshButton;
//
//        UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
//        [refreshButton2 setImage:imageOpenListHL forState:UIControlStateHighlighted];
//        [refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
//        [refreshButton2 setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
//
//        
//        secondStation.rightView = refreshButton2;
//       
//        firstStation.rightViewMode = UITextFieldViewModeAlways;
//        secondStation.rightViewMode = UITextFieldViewModeAlways;
//        
//        firstStation.frame = CGRectMake(0, 0, 160, 44);
//        secondStation.frame = CGRectMake(160, 0, 160, 44);
//        
//        self.frame=CGRectMake(0,0, 320, 44); 
//        self.toolbar.frame=CGRectMake(0,0, 320,44); 
//       
//        [toolbar setImage:[UIImage imageNamed:@"toolbar_bg1.png"]];
//        
//        arrowView.hidden=YES;
//        
//    }];
//    
//    
//    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
//    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
//    
//    shouldEnlarge =NO;

}


-(UIImage*)imageWithColor:(MCategory*)category
{
    if (!category) {
        UIImage *image = [self drawCircleView:[UIColor whiteColor]];
        return image;
    }
    
    UIImage *image = [self drawCircleView:category.color];
    
    
    return image;
}

-(UIImage*)biggerImageWithColor:(MCategory*)line
{
    UIImage *image = [self drawBiggerCircleView:[line color]];
    return image;
}

-(void) selectFromStation {
    [firstStation resignFirstResponder];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.glViewController removeTableView];
    if ([firstButton isHidden]) {
       // [self transitFirstToSmallField];
    }
    [appDelegate.glViewController pressedSelectFromStation];
}

-(void) selectToStation {
    [secondStation resignFirstResponder];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.glViewController removeTableView];
    if ([secondButton isHidden]) {
       // [self transitSecondToSmallField];
    }
    [appDelegate.glViewController pressedSelectToStation];
}

-(void)resetBothStations
{
    shouldEnlarge = YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.glViewController resetBothStations];
}

-(void)resetFromStation
{
    shouldEnlarge = YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.glViewController resetFromStation];
}

-(void)resetToStation
{
    shouldEnlarge=YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.glViewController resetToStation];
}

-(void)clearFromStation
{
    firstStation.text = @"";
    firstStation.rightViewMode = UITextFieldViewModeAlways;
    [firstStation setLeftView:nil];
    [firstStation setLeftViewMode: UITextFieldViewModeNever];
    firstStation.background = [UIImage imageNamed:@"toolbar_text_bg2.png"];

}

-(void)clearToStation
{
    secondStation.text = @"";
    secondStation.rightViewMode = UITextFieldViewModeAlways;
    [secondStation setLeftView:nil];
    [secondStation setLeftViewMode: UITextFieldViewModeNever];
    secondStation.background = [UIImage imageNamed:@"toolbar_text_bg2.png"];

}

-(void)setFromStation:(MItem*)fromStation
{
//    if ([firstButton isHidden]) {
        //[self transitFirstToSmallField];
        [firstButton setHidden:NO];
        firstButton.userInteractionEnabled = YES;
//    }

    isEditing = NO;
    [firstStation resignFirstResponder];
    
//    if (shouldEnlarge)
//    {
        [self transitToInitialSize];
//    }
    
    if (fromStation) {
       
        firstStation.text = fromStation.name;
        
        firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];

        firstStation.rightViewMode = UITextFieldViewModeAlways;
        
//        UIImageView *lineColor = [[UIImageView alloc] initWithImage:[self imageWithColor:[[fromStation categories] anyObject]]];
//        [firstStation setLeftView:lineColor];
//        [lineColor release];
        
        [firstStation setLeftViewMode: UITextFieldViewModeAlways];
        firstStation.background = [UIImage imageNamed:@"toolbar_text_bg_lighted2.png"];

    } else {
        [self clearFromStation];
    }
}

-(void)setToStation:(MItem*)toStation
{

    if ([secondButton isHidden]) {
        //[self transitSecondToSmallField];
    }

    if (shouldEnlarge)
    {
        [self transitToInitialSize];
    }
    
    if (toStation) {
        secondStation.text = toStation.name;
 
        secondStation.rightViewMode = UITextFieldViewModeNever;
        
        secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];

        //UIImageView *lineColor = [[UIImageView alloc] initWithImage:[self imageWithColor:[toStation lines]]];
        //[secondStation setLeftView:lineColor];
        //[lineColor release];
        
        [secondStation setLeftViewMode: UITextFieldViewModeAlways];
        secondStation.background = [UIImage imageNamed:@"toolbar_text_bg_lighted2.png"];

    } else {
        [self clearToStation];
    }
}

-(UIImage*)drawCircleView:(UIColor*)myColor
{
    if (!myColor) {
        myColor = [UIColor whiteColor];
    }
    
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

// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isEditing) {
        return YES;
    } else {
        return NO;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)dealloc
{
    [super dealloc];
}

@end