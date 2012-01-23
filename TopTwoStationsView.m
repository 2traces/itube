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
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width,self.frame.size.height)];
	[self addSubview:toolbar];
    
	UIImage *imageOpenList = [UIImage imageNamed:@"openlist.png"];
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton setImage:imageOpenList forState:UIControlStateNormal];
	[refreshButton setImage:imageOpenList forState:UIControlStateHighlighted];
	refreshButton.imageEdgeInsets = UIEdgeInsetsMake(0, -imageOpenList.size.width/2, 0, 0);
	[refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
	refreshButton.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
    
	firstStation = [[UITextField alloc] initWithFrame:CGRectMake(0,7, 157, 36)];
	firstStation.delegate = self;
	firstStation.borderStyle = UITextBorderStyleNone;
	firstStation.rightView = refreshButton;
	firstStation.background = [UIImage imageNamed:@"textfield.png"];
	firstStation.textAlignment = UITextAlignmentLeft;
	firstStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	firstStation.rightViewMode = UITextFieldViewModeAlways;
	[firstStation setReturnKeyType:UIReturnKeyDone];
	[firstStation setClearButtonMode:UITextFieldViewModeWhileEditing];
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
//    firstStation.enabled=NO;
    
	[toolbar addSubview:firstStation];	
    
	UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button1 addTarget:self action:@selector(transitFirstToBigField) forControlEvents:UIControlEventTouchUpInside];
	button1.frame = CGRectMake(0,6, 130, 38);
    self.firstButton=button1;
    
    [toolbar addSubview:button1];
    
	UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
	[refreshButton2 setImage:imageOpenList forState:UIControlStateHighlighted];
	refreshButton2.imageEdgeInsets = UIEdgeInsetsMake(0, -imageOpenList.size.width/2, 0, 0);
	[refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
	refreshButton2.bounds = CGRectMake(0,0, imageOpenList.size.width, imageOpenList.size.height);
	
	secondStation = [[UITextField alloc] initWithFrame:CGRectMake(160,7, 157, 36)];
	secondStation.delegate=self;
	secondStation.borderStyle = UITextBorderStyleNone;
	secondStation.rightView = refreshButton2;
	secondStation.background = [UIImage imageNamed:@"textfield.png"];
	secondStation.textAlignment = UITextAlignmentLeft;
	secondStation.rightViewMode = UITextFieldViewModeAlways;
	[secondStation setReturnKeyType:UIReturnKeyDone];
	[secondStation setClearButtonMode:UITextFieldViewModeWhileEditing];
	secondStation.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
    
	[toolbar addSubview:secondStation];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button2 addTarget:self action:@selector(transitSecondToBigField) forControlEvents:UIControlEventTouchUpInside];
	button2.frame = CGRectMake(160 ,6, 130, 38);
    self.secondButton=button2;
    
    [toolbar addSubview:button2];
    
    [toolbar release];

}

-(void)transitFirstToBigField
{
    NSTimeInterval duration = 0.3f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=YES;
        
        secondStation.hidden=YES;
        secondStation.userInteractionEnabled=NO;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstButton.userInteractionEnabled=NO;
        secondButton.userInteractionEnabled=NO;
        
        firstStation.frame = CGRectMake(0,3, 317, 36);
    }];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];

    
/*    if (!tableView) {
        self.tableView=[[[FastAccessTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        tableView.view.frame=CGRectMake(0,44,320,200);

        [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    
    [self addSubview:tableView.tableView];
    [self bringSubviewToFront:tableView.tableView];*/
    self.tableView=controller;
    firstStation.delegate = self.tableView;
    [firstStation becomeFirstResponder];

}

-(void)transitFirstToSmallField
{
    NSTimeInterval duration = 0.3f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;

        secondStation.hidden=NO;
        secondStation.userInteractionEnabled=YES;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstButton.userInteractionEnabled=YES;
        secondButton.userInteractionEnabled=YES;
        
        firstStation.frame = CGRectMake(0,3, 157, 36);
    }];
    
}

-(void)transitSecondToBigField
{
    NSTimeInterval duration = 0.3f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=YES;

        firstStation.hidden=YES;
        firstStation.userInteractionEnabled=NO;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        firstButton.userInteractionEnabled=NO;
        secondButton.userInteractionEnabled=NO;
        
        secondStation.frame = CGRectMake(0,3, 317, 36);
    }];
    
}

-(void)transitSecondToSmallField
{
    NSTimeInterval duration = 0.3f;
    
    [UIView animateWithDuration:duration animations:^{ 
        isEditing=NO;

        firstStation.hidden=NO;
        firstStation.userInteractionEnabled=YES;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        firstButton.userInteractionEnabled=YES;
        secondButton.userInteractionEnabled=YES;
        
        secondStation.frame = CGRectMake(160, 7, 157, 36);
    }];
    
}

-(UIImage*)imageWithColor:(MLine*)line
{
    UIImage *image = [self drawCircleView:[line color]];
    return image;
}

-(void) selectFromStation {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController pressedSelectFromStation];
}

-(void) selectToStation {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController pressedSelectToStation];
}

-(void)setFromStation:(MStation*)fromStation
{
    if ([firstButton isHidden]) {
        [self transitFirstToSmallField];
    }
    
    firstStation.text = fromStation.name;
    firstStation.rightView = nil;
    [firstStation setLeftView:[[UIImageView alloc] initWithImage:[self imageWithColor:[fromStation lines]]]];
    [firstStation setLeftViewMode: UITextFieldViewModeAlways];

}

-(void)setToStation:(MStation*)toStation
{
    if ([secondButton isHidden]) {
        [self transitSecondToSmallField];
    }
    
    secondStation.text = toStation.name;
    secondStation.rightView = nil;
    [secondStation setLeftView:[[UIImageView alloc] initWithImage:[self imageWithColor:[toStation lines]]]];
    [secondStation setLeftViewMode: UITextFieldViewModeAlways];
}

-(UIImage*)drawCircleView:(UIColor*)myColor
{
    UIGraphicsBeginImageContext(CGSizeMake(29,29));
    
    CGRect circleRect = CGRectMake(10.0, 7.0, 13.0, 13.0);
	
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	DLog(@"Here5");
}

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
