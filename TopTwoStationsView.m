//
//  TopTwoStationsView.m
//  tube
//
//  Created by sergey on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopTwoStationsView.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "FastAccessTableViewController.h"


@interface UITextField (myCustomTextField)

@end

@implementation UITextField (myCustomTextField)

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 20, 0);
}

@end

@implementation TopTwoStationsView

@synthesize toolbar;
@synthesize secondStation;
@synthesize firstStation;
@synthesize firstButton;
@synthesize secondButton;
@synthesize tableView;

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
    [toolbar setImage:[UIImage imageNamed:@"toolbar_bg1.png"]];
    [toolbar setUserInteractionEnabled:YES];
	[self addSubview:toolbar];

	UIImage *imageOpenList = [UIImage imageNamed:@"openlist.png"];
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton setImage:imageOpenList forState:UIControlStateNormal];
	refreshButton.imageEdgeInsets = UIEdgeInsetsMake(-1.0, -13.0, 0, 0);
	[refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
	refreshButton.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
    
	firstStation = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
	firstStation.delegate = self;
	firstStation.borderStyle = UITextBorderStyleNone;
	firstStation.rightView = refreshButton;
	firstStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];
    firstStation.backgroundColor = [UIColor clearColor];
	firstStation.textAlignment = UITextAlignmentLeft;
	firstStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	firstStation.rightViewMode = UITextFieldViewModeAlways;
    firstStation.autocorrectionType=UITextAutocorrectionTypeNo;
    firstStation.autocapitalizationType=UITextAutocapitalizationTypeNone; 
	[firstStation setReturnKeyType:UIReturnKeyDone];
	[firstStation setClearButtonMode:UITextFieldViewModeNever];
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
	[toolbar addSubview:firstStation];	
    
	UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button1 addTarget:self action:@selector(transitFirstToBigField) forControlEvents:UIControlEventTouchUpInside];
	button1.frame = CGRectMake(0, 6, 130, 44);
    self.firstButton=button1;
    
    [toolbar addSubview:button1];
    
	UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
	refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(-1, -13.0, 0, 0);
	[refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
	refreshButton2.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
	 
	secondStation = [[UITextField alloc] initWithFrame:CGRectMake(160, 0, 160, 44)];
	secondStation.delegate=self;
	secondStation.borderStyle = UITextBorderStyleNone;
	secondStation.rightView = refreshButton2;
	secondStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];
    secondStation.backgroundColor = [UIColor clearColor];
	secondStation.textAlignment = UITextAlignmentLeft;
	secondStation.rightViewMode = UITextFieldViewModeAlways;
    secondStation.autocorrectionType=UITextAutocorrectionTypeNo;
    secondStation.autocapitalizationType=UITextAutocapitalizationTypeNone; 
	[secondStation setReturnKeyType:UIReturnKeyDone];
	[secondStation setClearButtonMode:UITextFieldViewModeNever];
	secondStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
	[toolbar addSubview:secondStation];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button2 addTarget:self action:@selector(transitSecondToBigField) forControlEvents:UIControlEventTouchUpInside];
	button2.frame = CGRectMake(160 ,6, 130, 44);
    self.secondButton=button2;
    
    [toolbar addSubview:button2];
    
    [toolbar release];
}

-(void)transitFirstToBigField
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=YES;
        
        secondStation.hidden=YES;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstButton.userInteractionEnabled=NO;
        secondButton.userInteractionEnabled=NO;
        
        firstStation.frame = CGRectMake(0, 0, 320, 44);
        firstStation.background = [UIImage imageNamed:@"toolbar_big_bg_lighted.png"];
        
        firstStation.text = @"";
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        firstStation.leftView=nil;
        firstStation.leftViewMode=UITextFieldViewModeAlways;
        
        UIButton *refreshButton2 = (UIButton*)firstStation.rightView;
        refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(-2.0, -21.0, 0, 0);

    }];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];
    
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    
    appDelegate.mainViewController.currentSelection=0;
    self.tableView=controller;
    firstStation.delegate = self.tableView;
    [firstStation becomeFirstResponder];
}

-(void)transitFirstToSmallField
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;
        
        secondStation.hidden=NO;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstButton.userInteractionEnabled=YES;
        secondButton.userInteractionEnabled=YES;
        
        firstStation.frame = CGRectMake(0, 0, 160, 44);
        firstStation.background = [UIImage imageNamed:@"toolbar_bg.png"];

        UIButton *refreshButton2 = (UIButton*)firstStation.rightView;
        refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(-1.0, -13.0, 0, 0);
    }];
    
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
    firstStation.delegate=self;
    self.tableView=nil;
    [firstStation resignFirstResponder];    
}

-(void)transitSecondToBigField
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=YES;
        
        firstStation.hidden=YES;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstButton.userInteractionEnabled=NO;
        secondButton.userInteractionEnabled=NO;
        
        secondStation.frame = CGRectMake(0, 0, 320, 44);
        secondStation.background = [UIImage imageNamed:@"toolbar_big_bg_lighted.png"];

        UIButton *refreshButton2 = (UIButton*)secondStation.rightView;
        refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(-2.0, -21.0, 0, 0);

        secondStation.text = @"";
        secondStation.rightViewMode = UITextFieldViewModeAlways;
        secondStation.leftView=nil;
        secondStation.leftViewMode=UITextFieldViewModeAlways;
        
    }];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];
    appDelegate.mainViewController.currentSelection=1;
    
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
    
    self.tableView=controller;
    secondStation.delegate = self.tableView;
    [secondStation becomeFirstResponder];
}

-(void)transitSecondToSmallField
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;
        
        firstStation.hidden=NO;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstButton.userInteractionEnabled=YES;
        secondButton.userInteractionEnabled=YES;
        
        secondStation.background = [UIImage imageNamed:@"toolbar_bg.png"];
        secondStation.frame = CGRectMake(160, 0, 160, 44);
        
        UIButton *refreshButton2 = (UIButton*)secondStation.rightView;
        refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(-1.0, -13.0, 0, 0);

    }];
    
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
    secondStation.delegate=self;
    self.tableView=nil;
    [secondStation resignFirstResponder];
}

-(void)transitToPathView
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;
        
        firstStation.hidden=NO;
        firstStation.userInteractionEnabled=YES;
        
        secondStation.hidden=NO;
        secondStation.userInteractionEnabled=YES;

        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstStation.background = nil;
        secondStation.background = nil;
        
        UIImage *crossImage = [UIImage imageNamed:@"cross_transp.png"];
        UIImage *crossImageHighlighted = [UIImage imageNamed:@"cross_opaq.png"];

        UIButton *cancelButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton1 setImage:crossImage forState:UIControlStateNormal];
        [cancelButton1 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
//        cancelButton1.imageEdgeInsets = UIEdgeInsetsMake(0.0, -2.0, 0, 0);
        [cancelButton1 addTarget:self action:@selector(resetFromStation) forControlEvents:UIControlEventTouchUpInside];
        cancelButton1.bounds = CGRectMake(0,-1, crossImage.size.width, crossImage.size.height);

        UIButton *cancelButton2= [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton2 setImage:crossImage forState:UIControlStateNormal];
        [cancelButton2 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
  //      cancelButton2.imageEdgeInsets = UIEdgeInsetsMake(0.0, 2.0, 0, 0);
        [cancelButton2 addTarget:self action:@selector(resetToStation) forControlEvents:UIControlEventTouchUpInside];
        cancelButton2.bounds = CGRectMake(0,0, crossImage.size.width, crossImage.size.height);

        firstStation.rightView= cancelButton1;
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        secondStation.rightView = cancelButton2;
        secondStation.rightViewMode = UITextFieldViewModeAlways;
 
        firstStation.frame = CGRectMake(0, 3, 160, 26);
        secondStation.frame = CGRectMake(160, 3, 160, 26);
        
        self.frame=CGRectMake(0,0, 320, 26); 
        self.toolbar.frame=CGRectMake(0,0, 320, 26); 
        [toolbar setImage:[UIImage imageNamed:@"upper_path_bg.png"]];
    }];
    
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
}

-(void)transitToInitialSize
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;
        
        firstStation.hidden=NO;
        firstStation.userInteractionEnabled=YES;
        
        secondStation.hidden=NO;
        secondStation.userInteractionEnabled=YES;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];
        secondStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];
       
        
        UIImage *imageOpenList = [UIImage imageNamed:@"openlist.png"];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton setImage:imageOpenList forState:UIControlStateNormal];
        refreshButton.imageEdgeInsets = UIEdgeInsetsMake(-1.0, -13.0, 0, 0);
        [refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
        refreshButton.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
        
        firstStation.rightView = refreshButton;

        UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
        refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(-1.0, -13.0, 0, 0);
        [refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
        refreshButton2.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
        
        secondStation.rightView = refreshButton2;
       
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        secondStation.rightViewMode = UITextFieldViewModeAlways;
        
        firstStation.frame = CGRectMake(0, 0, 160, 44);
        secondStation.frame = CGRectMake(160, 0, 160, 44);
        
        self.frame=CGRectMake(0,0, 320, 44); 
        self.toolbar.frame=CGRectMake(0,0, 320,44); 
       
         [toolbar setImage:[UIImage imageNamed:@"toolbar_bg1.png"]];
        
        
    }];
    
    
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
    shouldEnlarge =NO;

}


-(UIImage*)imageWithColor:(MLine*)line
{
    UIImage *image = [self drawCircleView:[line color]];
    return image;
}

-(void) selectFromStation {
    [firstStation resignFirstResponder];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController removeTableView];
    if ([firstButton isHidden]) {
        [self transitFirstToSmallField];
    }
    [appDelegate.mainViewController pressedSelectFromStation];
}

-(void) selectToStation {
    [secondStation resignFirstResponder];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController removeTableView];
    if ([secondButton isHidden]) {
        [self transitSecondToSmallField];
    }
    [appDelegate.mainViewController pressedSelectToStation];
}

-(void)resetFromStation
{
    shouldEnlarge = YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController resetFromStation];
}

-(void)resetToStation
{
    shouldEnlarge=YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController resetToStation];
}

-(void)clearFromStation
{
    firstStation.text = @"";
    firstStation.rightViewMode = UITextFieldViewModeAlways;
    [firstStation setLeftView:nil];
    [firstStation setLeftViewMode: UITextFieldViewModeNever];
    firstStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];

}

-(void)clearToStation
{
    secondStation.text = @"";
    secondStation.rightViewMode = UITextFieldViewModeAlways;
    [secondStation setLeftView:nil];
    [secondStation setLeftViewMode: UITextFieldViewModeNever];
    secondStation.background = [UIImage imageNamed:@"toolbar_text_bg.png"];

}

-(void)setFromStation:(MStation*)fromStation
{
    if ([firstButton isHidden]) {
        [self transitFirstToSmallField];
    }
    
    if (shouldEnlarge)
    {
        [self transitToInitialSize];
    }
    
    if (fromStation) {
       
        firstStation.text = fromStation.name;
        firstStation.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        
        firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];

        firstStation.rightViewMode = UITextFieldViewModeNever;
        
        UIImageView *lineColor = [[UIImageView alloc] initWithImage:[self imageWithColor:[fromStation lines]]];
        [firstStation setLeftView:lineColor];
        [lineColor release];
        
        [firstStation setLeftViewMode: UITextFieldViewModeAlways];
        firstStation.background = [UIImage imageNamed:@"toolbar_text_bg_lighted.png"];

    } else {
        [self clearFromStation];
    }
}

-(void)setToStation:(MStation*)toStation
{

    if ([secondButton isHidden]) {
        [self transitSecondToSmallField];
    }

    if (shouldEnlarge)
    {
        [self transitToInitialSize];
    }
    
    if (toStation) {
        secondStation.text = toStation.name;
        secondStation.rightViewMode = UITextFieldViewModeNever;
        
        secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];

        UIImageView *lineColor = [[UIImageView alloc] initWithImage:[self imageWithColor:[toStation lines]]];
        [secondStation setLeftView:lineColor];
        [lineColor release];
        
        [secondStation setLeftViewMode: UITextFieldViewModeAlways];
        secondStation.background = [UIImage imageNamed:@"toolbar_text_bg_lighted.png"];

    } else {
        [self clearToStation];
    }
}

-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(29,29), NO, 0.0);
    
    CGRect circleRect = CGRectMake(11.0, 6.0, 13.0, 13.0);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    const CGFloat* components = CGColorGetComponents(myColor.CGColor);
    
    CGContextSetRGBStrokeColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor)); 
    CGContextSetRGBFillColor(context, components[0],components[1], components[2],  CGColorGetAlpha(myColor.CGColor));  
	CGContextSetLineWidth(context, 1.0);
	CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
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