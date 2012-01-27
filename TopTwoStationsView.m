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

//- (CGRect)textRectForBounds:(CGRect)bounds {
    
//    return CGRectInset(bounds, 10, 0);
//}

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
  //  toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width,self.frame.size.height)];
//	[self addSubview:toolbar];

    toolbar = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width,self.frame.size.height)];
    [toolbar setImage:[UIImage imageNamed:@"toolbar_bg.png"]];
    [toolbar setUserInteractionEnabled:YES];
	[self addSubview:toolbar];

	UIImage *imageOpenList = [UIImage imageNamed:@"openlist.png"];
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton setImage:imageOpenList forState:UIControlStateNormal];
	[refreshButton setImage:imageOpenList forState:UIControlStateHighlighted];
	refreshButton.imageEdgeInsets = UIEdgeInsetsMake(0, -imageOpenList.size.width/2, 0, 0);
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
	[refreshButton2 setImage:imageOpenList forState:UIControlStateHighlighted];
	refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(0, -imageOpenList.size.width/2, 0, 0);
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
        secondStation.userInteractionEnabled=NO;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstButton.userInteractionEnabled=NO;
        secondButton.userInteractionEnabled=NO;
        
        firstStation.frame = CGRectMake(0, 0, 320, 44);
        firstStation.background = [UIImage imageNamed:@"toolbar_big_bg_lighted.png"];
        
        firstStation.text = @"";
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        [firstStation setLeftView:nil];
        [firstStation setRightViewMode: UITextFieldViewModeAlways];
    }];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];
    
    
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
        secondStation.userInteractionEnabled=YES;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstButton.userInteractionEnabled=YES;
        secondButton.userInteractionEnabled=YES;
        
        firstStation.frame = CGRectMake(0, 0, 160, 44);
        firstStation.background = [UIImage imageNamed:@"toolbar_bg.png"];

        
        
    }];
    
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
        firstStation.userInteractionEnabled=NO;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstButton.userInteractionEnabled=NO;
        secondButton.userInteractionEnabled=NO;
        
        secondStation.frame = CGRectMake(0, 0, 320, 44);
        secondStation.background = [UIImage imageNamed:@"toolbar_big_bg_lighted.png"];


        secondStation.text = @"";
        secondStation.rightViewMode = UITextFieldViewModeAlways;
        [secondStation setLeftView:nil];
        [secondStation setRightViewMode: UITextFieldViewModeAlways];
        
    }];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];
    appDelegate.mainViewController.currentSelection=1;
    
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
        firstStation.userInteractionEnabled=YES;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstButton.userInteractionEnabled=YES;
        secondButton.userInteractionEnabled=YES;
        
        secondStation.background = [UIImage imageNamed:@"toolbar_bg.png"];
        secondStation.frame = CGRectMake(160, 0, 160, 44);
    }];
    
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
        cancelButton1.imageEdgeInsets = UIEdgeInsetsMake(0, -crossImage.size.width/2, 0, 0);
        [cancelButton1 addTarget:self action:@selector(clearFromStation) forControlEvents:UIControlEventTouchUpInside];
        cancelButton1.bounds = CGRectMake(0,0, crossImage.size.width, crossImage.size.height);

        UIButton *cancelButton2= [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton2 setImage:crossImage forState:UIControlStateNormal];
        [cancelButton2 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
        cancelButton2.imageEdgeInsets = UIEdgeInsetsMake(0, -crossImage.size.width/2, 0, 0);
        [cancelButton2 addTarget:self action:@selector(clearToStation) forControlEvents:UIControlEventTouchUpInside];
        cancelButton2.bounds = CGRectMake(0,0, crossImage.size.width, crossImage.size.height);

        firstStation.rightView= cancelButton1;
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        secondStation.rightView = cancelButton2;
        secondStation.rightViewMode = UITextFieldViewModeAlways;
        
        firstStation.frame = CGRectMake(0, 0, 160, 22);
        secondStation.frame = CGRectMake(160, 0, 160, 22);
        
        self.frame=CGRectMake(0,0, 320, 20); 
        self.toolbar.frame=CGRectMake(0,0, 320, 22); 


    }];
    
    secondStation.delegate=self;
    self.tableView=nil;
    [secondStation resignFirstResponder];

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
    [appDelegate.mainViewController pressedSelectFromStation];
}

-(void) selectToStation {
    [secondStation resignFirstResponder];
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController removeTableView];
    [appDelegate.mainViewController pressedSelectToStation];
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
    if (fromStation) {
       
        firstStation.text = fromStation.name;
        firstStation.rightViewMode = UITextFieldViewModeNever;
        [firstStation setLeftView:[[UIImageView alloc] initWithImage:[self imageWithColor:[fromStation lines]]]];
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
    if (toStation) {
        secondStation.text = toStation.name;
        secondStation.rightViewMode = UITextFieldViewModeNever;
        [secondStation setLeftView:[[UIImageView alloc] initWithImage:[self imageWithColor:[toStation lines]]]];
        [secondStation setLeftViewMode: UITextFieldViewModeAlways];
        secondStation.background = [UIImage imageNamed:@"toolbar_text_bg_lighted.png"];

    } else {
        [self clearToStation];
    }
}

-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContext(CGSizeMake(29,29));
    
    CGRect circleRect = CGRectMake(10.0, 5.0, 13.0, 13.0);
	
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