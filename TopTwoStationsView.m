//
//  TopTwoStationsView.m
//  tube
//
//  Created by Sergey Mingalev on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopTwoStationsView.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "FastAccessTableViewController.h"
#import "StationTextField.h"
#import "SSTheme.h"

@implementation TopTwoStationsView

@synthesize toolbar;
@synthesize secondStation;
@synthesize firstStation;
@synthesize firstButton;
@synthesize secondButton;
@synthesize tableView;
@synthesize arrowView;
@synthesize leftButton;
@synthesize deviceHeight, deviceWidth;
@synthesize fieldWidth, viewHeight;
@synthesize fieldDelta, fieldHeight;

-(id)initWithViewHeight:(CGFloat)vHeight fieldWidth:(CGFloat)fWidth  fieldHeight:(CGFloat)fHeight fieldDelta:(CGFloat)fDelta deviceHeight:(CGFloat)dHeight deviceWidth:(CGFloat)dWidth {

    self.deviceWidth=dWidth;
    self.deviceHeight=dHeight;
    self.fieldWidth=fWidth;
    self.viewHeight=vHeight;
    self.fieldHeight=fHeight;
    self.fieldDelta=fDelta;
    
        if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
            return [self initWithFrame:CGRectMake(0.0, 0.0, deviceHeight, viewHeight)];
        } else {
            return [self initWithFrame:CGRectMake(0.0, 0.0, deviceWidth, viewHeight)];
        }
}

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
    self.backgroundColor=[UIColor clearColor];
    
        self.toolbar = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
        [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 149.0, 0, 167.0)]];
        [toolbar setUserInteractionEnabled:YES];
        toolbar.autoresizesSubviews = YES;
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:toolbar];
        
        UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
        UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
        [refreshButton setImage:imageOpenList forState:UIControlStateNormal];
        [refreshButton setImage:imageOpenListHL forState:UIControlStateHighlighted];
        [refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
        
        firstStation = [[StationTextField alloc] initWithFrame:CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight) andStyle:StationTextFieldStyleDefault];
        firstStation.delegate = self;
        firstStation.rightView = refreshButton;
        firstStation.placeholder=NSLocalizedString(@"FromDest", @"From..");
        
        [toolbar addSubview:firstStation];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button1 addTarget:self action:@selector(transitFirstToBigField) forControlEvents:UIControlEventTouchUpInside];
        button1.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth-30.0, fieldHeight);
        self.firstButton=button1;
        
        [toolbar addSubview:button1];
        
        UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
        [refreshButton2 setImage:imageOpenListHL forState:UIControlStateHighlighted];
        [refreshButton2 setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
        [refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
        
        secondStation = [[StationTextField alloc] initWithFrame:CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight) andStyle:StationTextFieldStyleDefault];
        secondStation.delegate=self;
        secondStation.rightView = refreshButton2;
        secondStation.placeholder=NSLocalizedString(@"ToDest", @"To..");
        
        [toolbar addSubview:secondStation];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button2 addTarget:self action:@selector(transitSecondToBigField) forControlEvents:UIControlEventTouchUpInside];
        button2.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth-30.0, fieldHeight);
        self.secondButton=button2;
        
        [toolbar addSubview:button2];
        
        UIImage *image = [[SSThemeManager sharedTheme] topToolbarArrowPathImage];
        arrowView = [[UIImageView alloc] initWithImage:image];
        [arrowView setFrame:CGRectMake(self.frame.size.width-fieldWidth-7, 6+fieldDelta, image.size.width, image.size.height)];
        [toolbar addSubview:arrowView];
        arrowView.hidden=YES;
        [arrowView release];

    if (IS_IPAD) {

        UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button3 addTarget:self action:@selector(showiPadLeftPathView) forControlEvents:UIControlEventTouchUpInside];
        [button3 setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
        button3.frame = CGRectMake(15, 8, 17, 30);
        self.leftButton=button3;
        self.leftButton.userInteractionEnabled=YES;
        [toolbar addSubview:button3];
        
        UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button4 setImage:[UIImage imageNamed:@"settings_ipad_button.png"] forState:UIControlStateNormal];
        [button4 addTarget:self action:@selector(showiPadSettingsModalView) forControlEvents:UIControlEventTouchUpInside];
        button4.frame = CGRectMake(38, 4, 35, 38);
        [toolbar addSubview:button4];
        
 //       [toolbar release];
        
    }
//    else {
//        
//        toolbar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 149.0, 0, 167.0)]];
//        [toolbar setUserInteractionEnabled:YES];
//        toolbar.autoresizesSubviews = YES;
//        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [self addSubview:toolbar];
//        
//        UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
//        UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
//        
//        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [refreshButton setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
//        [refreshButton setImage:imageOpenList forState:UIControlStateNormal];
//        [refreshButton setImage:imageOpenListHL forState:UIControlStateHighlighted];
//        [refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
//        
//        firstStation = [[StationTextField alloc] initWithFrame:CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight) andStyle:StationTextFieldStyleDefault];
//        firstStation.delegate = self;
//        firstStation.rightView = refreshButton;
//        firstStation.placeholder=NSLocalizedString(@"FromDest", @"From..");
//        
//        [toolbar addSubview:firstStation];
//        
//        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button1 addTarget:self action:@selector(transitFirstToBigField) forControlEvents:UIControlEventTouchUpInside];
//        button1.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth-30.0 , fieldHeight);
//        self.firstButton=button1;
//        
//        [toolbar addSubview:button1];
//        
//        UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
//        [refreshButton2 setImage:imageOpenListHL forState:UIControlStateHighlighted];
//        [refreshButton2 setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
//        [refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
//        
//        secondStation = [[StationTextField alloc] initWithFrame:CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight) andStyle:StationTextFieldStyleDefault];
//        secondStation.delegate=self;
//        secondStation.borderStyle = UITextBorderStyleNone;
//        secondStation.rightView = refreshButton2;
//        secondStation.placeholder=NSLocalizedString(@"ToDest", @"To..");
//        
//        [toolbar addSubview:secondStation];
//        
//        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button2 addTarget:self action:@selector(transitSecondToBigField) forControlEvents:UIControlEventTouchUpInside];
//        button2.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth-30.0, fieldHeight);
//        self.secondButton=button2;
//        
//        [toolbar addSubview:button2];
//        
//        UIImage *image = [[SSThemeManager sharedTheme] topToolbarArrowPathImage];
//        arrowView = [[UIImageView alloc] initWithImage:image];
//        [arrowView setFrame:CGRectMake(self.frame.size.width-fieldWidth-7, 6+fieldDelta, image.size.width, image.size.height)];
//        [toolbar addSubview:arrowView];
//        arrowView.hidden=YES;
//        [arrowView release];
//        
//        [toolbar release];
//        
//    }
}

-(void)adjustSubviews:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        firstStation.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight);
        secondStation.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight);
        
        firstButton.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth-30.0, fieldHeight);
        secondButton.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth-30.0, fieldHeight);
        
        CGFloat desireOrigin = (secondStation.frame.origin.x - firstStation.frame.origin.x - firstStation.frame.size.width)/2.0+7.0;
        arrowView.frame = CGRectMake(secondStation.frame.origin.x-desireOrigin,15, arrowView.frame.size.width, arrowView.frame.size.height);
        
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            if (self.frame.size.width<deviceHeight) {
                [self.leftButton setImage:[UIImage imageNamed:@"close_ipad_button.png"] forState:UIControlStateNormal];
            } else {
                [self.leftButton setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
            }
        } else {
            if (self.frame.size.width<deviceWidth) {
                [self.leftButton setImage:[UIImage imageNamed:@"close_ipad_button.png"] forState:UIControlStateNormal];
            } else {
                [self.leftButton setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
            }
        }
    }
}

-(void)transitFirstToBigField
{
    isEditing=YES;
    
    secondStation.hidden=YES;
    
    firstButton.hidden=YES;
    secondButton.hidden=YES;
    
    firstButton.userInteractionEnabled=NO;
    secondButton.userInteractionEnabled=NO;
    
    CGRect frame;
    
        frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth*2, fieldHeight);
    
    [firstStation changeStyleTo:StationTextFieldStyleSearch withFrame:frame animated:YES];
    
    if (IS_IPAD) {
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.mainViewController.currentSelection=0;
        StationListViewController *controller = [appDelegate.mainViewController showiPadLiveSearchView];
        firstStation.delegate = controller;
        controller.isTextFieldInUse=YES;
        [firstStation becomeFirstResponder];
    } else {
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];
        appDelegate.mainViewController.currentSelection=0;
        self.tableView=controller;
        firstStation.delegate = self.tableView;
        [firstStation becomeFirstResponder];
    }
}

-(void)transitFirstToSmallField
{
    isEditing=NO;
    
    secondStation.hidden=NO;
    
    firstButton.hidden=NO;
    secondButton.hidden=NO;
    
    firstButton.userInteractionEnabled=YES;
    secondButton.userInteractionEnabled=YES;
    
    CGRect frame;
    
        frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight);
    
    [firstStation changeStyleTo:StationTextFieldStyleDefault withFrame:frame animated:YES];
    
    firstStation.delegate=self;
    self.tableView=nil;
    [firstStation resignFirstResponder];
}

-(void)transitSecondToBigField
{
    isEditing=YES;
    
    firstStation.hidden=YES;
    
    firstButton.hidden=YES;
    secondButton.hidden=YES;
    
    firstButton.userInteractionEnabled=NO;
    secondButton.userInteractionEnabled=NO;
    
    CGRect frame;
    
        frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth*2, fieldHeight);
    
    [secondStation changeStyleTo:StationTextFieldStyleSearch withFrame:frame animated:YES];
    
    if (IS_IPAD) {
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.mainViewController.currentSelection=1;
        StationListViewController *controller = [appDelegate.mainViewController showiPadLiveSearchView];
        secondStation.delegate = controller;
        controller.isTextFieldInUse=YES;
        [secondStation becomeFirstResponder];
    } else {
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        FastAccessTableViewController *controller = [appDelegate.mainViewController showTableView];
        appDelegate.mainViewController.currentSelection=1;
        self.tableView=controller;
        secondStation.delegate = self.tableView;
        [secondStation becomeFirstResponder];
    }
}

-(void)transitSecondToSmallField
{
    isEditing=NO;
    
    firstStation.hidden=NO;
    
    firstButton.hidden=NO;
    secondButton.hidden=NO;
    
    firstButton.userInteractionEnabled=YES;
    secondButton.userInteractionEnabled=YES;
    
    CGRect frame;
    
        frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight);
    
    [secondStation changeStyleTo:StationTextFieldStyleDefault withFrame:frame animated:YES];
    
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
        
        firstStation.background = [UIImage imageNamed:@"pixeldummy.png"];
        secondStation.background = [UIImage imageNamed:@"pixeldummy.png"];
        
        firstStation.state=3;
        
        UIImage *crossImage = [[SSThemeManager sharedTheme] topToolbarCrossImage:UIControlStateNormal];
        UIImage *crossImageHighlighted = [[SSThemeManager sharedTheme] topToolbarCrossImage:UIControlStateHighlighted];
        
        UIButton *cancelButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton1 setImage:crossImage forState:UIControlStateNormal];
        [cancelButton1 setFrame:CGRectMake(0.0, 0.0, crossImage.size.width, crossImage.size.height)];
        [cancelButton1 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
        [cancelButton1 addTarget:self action:@selector(resetFromStation) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton2= [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton2 setImage:crossImage forState:UIControlStateNormal];
        [cancelButton2 setFrame:CGRectMake(0.0, 0.0, crossImage.size.width, crossImage.size.height)];
        [cancelButton2 setImage:crossImageHighlighted forState:UIControlStateHighlighted];
        [cancelButton2 addTarget:self action:@selector(resetToStation) forControlEvents:UIControlEventTouchUpInside];
        
        firstStation.rightView= cancelButton1;
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        secondStation.rightView = cancelButton2;
        secondStation.rightViewMode = UITextFieldViewModeAlways;
        
        arrowView.hidden=NO;
        
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UIImageView *lineColor1 = [[UIImageView alloc] initWithImage:[self biggerImageWithColor:[appDelegate.mainViewController.fromStation lines]]];
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            [firstStation setLeftView:nil];
        } else {
            [firstStation setLeftView:lineColor1];
        }
        
        [lineColor1 release];
        
        UIImageView *lineColor2 = [[UIImageView alloc] initWithImage:[self biggerImageWithColor:[appDelegate.mainViewController.toStation lines]]];
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            [secondStation setLeftView:nil];
        } else {
            [secondStation setLeftView:lineColor2];
        }
        [lineColor2 release];

        CGFloat addWidth = 65;
        CGFloat maxWidth = fieldWidth;
 
        firstStation.font = [[SSThemeManager sharedTheme] toolbarPathFont];
        secondStation.font =  [[SSThemeManager sharedTheme] toolbarPathFont];
        
        firstStation.textColor = [[SSThemeManager sharedTheme] toolbarPathFontColor];
        secondStation.textColor = [[SSThemeManager sharedTheme] toolbarPathFontColor];
        
        CGSize textBounds1 = [firstStation.text sizeWithFont:firstStation.font];
        CGSize textBounds2 = [secondStation.text sizeWithFont:secondStation.font];
        
        CGFloat desireWidth1;
        CGFloat desireWidth2;
        CGFloat desireOrigin1;
        CGFloat desireOrigin2;
        CGFloat arrowOrigin;
        
        if (IS_IPAD) {
            if (textBounds1.width+textBounds2.width+addWidth*2+arrowView.frame.size.width>maxWidth*2) {
                if (textBounds1.width+addWidth>maxWidth && textBounds2.width+addWidth>maxWidth) {
                    desireWidth1=maxWidth-arrowView.frame.size.width/2;
                    desireWidth2=maxWidth-arrowView.frame.size.width/2;
                    desireOrigin1 = firstStation.frame.origin.x;
                    desireOrigin2 = self.frame.size.width-desireWidth2;
                    arrowOrigin = desireOrigin2-arrowView.frame.size.width;
                } else if (textBounds1.width+addWidth>=maxWidth && textBounds2.width+addWidth<=maxWidth) {
                    desireWidth2=textBounds2.width+addWidth;
                    desireOrigin2=self.frame.size.width-desireWidth2;
                    desireOrigin1=firstStation.frame.origin.x;
                    desireWidth1 = desireOrigin2 - arrowView.frame.size.width-desireOrigin1;
                    arrowOrigin = desireOrigin2 - arrowView.frame.size.width;
                } else {
                    desireWidth1=textBounds1.width+addWidth;
                    desireOrigin1=firstStation.frame.origin.x;
                    desireOrigin2=desireOrigin1+desireWidth1+arrowView.frame.size.width;
                    desireWidth2=self.frame.size.width-desireOrigin2;
                    arrowOrigin=desireOrigin1+desireWidth1;
                }
                
            } else {
                desireWidth1=textBounds1.width+addWidth;
                desireWidth2=textBounds2.width+addWidth;
                desireOrigin1=firstStation.frame.origin.x;
                desireOrigin2=self.frame.size.width-desireWidth2;
                arrowOrigin = desireOrigin2-(desireOrigin2-desireOrigin1-desireWidth1)/2-8;
            }
            
            firstStation.frame = CGRectMake(desireOrigin1, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta ,desireWidth1, 44);
            secondStation.frame = CGRectMake(desireOrigin2, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta, desireWidth2, 44);
            arrowView.frame =CGRectMake(arrowOrigin, [[SSThemeManager sharedTheme] isNewTheme] ? 20 : 15, arrowView.frame.size.width, arrowView.frame.size.height);
            
        } else {
            
            CGFloat overallFirst;
            CGFloat overallSecond;
            
            if (firstStation.leftView) {
                overallFirst = firstStation.leftView.frame.size.width+textBounds1.width+firstStation.rightView.frame.size.width+25;
            } else {
                overallFirst = textBounds1.width+firstStation.rightView.frame.size.width+10;
            }

            if (secondStation.leftView) {
                overallSecond = secondStation.leftView.frame.size.width+textBounds2.width+secondStation.rightView.frame.size.width+25;
            } else {
                overallSecond = textBounds2.width+secondStation.rightView.frame.size.width+10;
            }
            
            if (overallFirst+overallSecond+arrowView.frame.size.width>maxWidth*2) {
                if (overallFirst>maxWidth && overallSecond>maxWidth) {
                    desireWidth1=maxWidth-arrowView.frame.size.width/2;
                    desireWidth2=maxWidth-arrowView.frame.size.width/2;
                    desireOrigin1 = self.frame.size.width-2*maxWidth;
                    desireOrigin2 = maxWidth+arrowView.frame.size.width/2;
                    arrowOrigin = desireWidth1;
                    NSLog(@"case1 - both bigger");
                } else if (overallFirst>=maxWidth && overallSecond<=maxWidth) {
                    desireWidth2=overallSecond;
                    desireOrigin2=self.frame.size.width-desireWidth2;
                    desireOrigin1=self.frame.size.width-2*maxWidth;
                    desireWidth1 = desireOrigin2 - arrowView.frame.size.width;
                    arrowOrigin = desireWidth1;
                    NSLog(@"case2 - first bigger");
                } else {
                    desireWidth1=overallFirst;
                    desireOrigin1=self.frame.size.width-2*maxWidth;
                    desireOrigin2=desireWidth1+arrowView.frame.size.width;
                    desireWidth2=self.frame.size.width - desireOrigin2;
                    arrowOrigin=desireWidth1;
                    NSLog(@"case3 - second bigger");
                }
                
            } else {
                
                CGFloat emptySpace = maxWidth*2-overallFirst-overallSecond-arrowView.frame.size.width;
                CGFloat oneEmptySpace = emptySpace/6.0;
                
                desireWidth1=overallFirst+oneEmptySpace;
                desireWidth2=overallSecond+oneEmptySpace;
                desireOrigin1=self.frame.size.width-2*maxWidth+oneEmptySpace;
                desireOrigin2=self.frame.size.width-desireWidth2-oneEmptySpace;
                arrowOrigin = desireOrigin1 + desireWidth1 + oneEmptySpace;
                NSLog(@"case4 - both smaller");
            }
            
            CGFloat height = [[SSThemeManager sharedTheme] topToolbarPathHeight:UIBarMetricsDefault];
            
            self.frame=CGRectMake(0, 0, 320, height);
            self.toolbar.frame=CGRectMake(0, 0, 320, height);
            
            firstStation.frame = CGRectMake(desireOrigin1, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta, desireWidth1, 26); 
            secondStation.frame = CGRectMake(desireOrigin2, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta, desireWidth2, 26); 
            
            arrowView.frame =CGRectMake(arrowOrigin, [[SSThemeManager sharedTheme] isNewTheme] ? 12 : 6, arrowView.frame.size.width, arrowView.frame.size.height);
            
            [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundPathImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 149.0, 0, 167.0)]];
            
            firstStation.state=StationTextFieldStylePath;
            secondStation.state=StationTextFieldStylePath;

        }
                
    }];
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
        
        firstStation.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
        secondStation.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
        
        UIImage *imageOpenList = [[SSThemeManager sharedTheme] stationTextFieldRightImageNormal];
        UIImage *imageOpenListHL = [[SSThemeManager sharedTheme] stationTextFieldRightImageHighlighted];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton setImage:imageOpenList forState:UIControlStateNormal];
        [refreshButton setImage:imageOpenListHL forState:UIControlStateHighlighted];
        [refreshButton addTarget:self action:@selector(selectFromStation) forControlEvents:UIControlEventTouchUpInside];
        [refreshButton setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
        
        firstStation.rightView = refreshButton;
        
        UIButton *refreshButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton2 setImage:imageOpenList forState:UIControlStateNormal];
        [refreshButton2 setImage:imageOpenListHL forState:UIControlStateHighlighted];
        [refreshButton2 addTarget:self action:@selector(selectToStation) forControlEvents:UIControlEventTouchUpInside];
        [refreshButton2 setFrame:CGRectMake(0.0, 0.0, imageOpenList.size.width,imageOpenList.size.height)];
        
        secondStation.rightView = refreshButton2;
        
        firstStation.rightViewMode = UITextFieldViewModeAlways;
        secondStation.rightViewMode = UITextFieldViewModeAlways;
        
        if (IS_IPAD) {
            if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
                //                self.frame=CGRectMake(0,0, self., viewHeight);
                //                self.toolbar.frame=CGRectMake(0,0, deviceHeight, viewHeight);
            } else {
                //                self.frame=CGRectMake(0,0, deviceWidth, viewHeight);
                //                self.toolbar.frame=CGRectMake(0,0, deviceWidth, viewHeight);
            }
            
            firstStation.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight);
            secondStation.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight);
            
        } else {
            if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
                self.frame=CGRectMake(0,0, deviceHeight, viewHeight);
                self.toolbar.frame=CGRectMake(0,0, deviceHeight, viewHeight);
            } else {
                self.frame=CGRectMake(0,0, deviceWidth, viewHeight);
                self.toolbar.frame=CGRectMake(0,0, deviceWidth, viewHeight);
            }
            
            firstStation.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight);
            secondStation.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight);
        }
        
        [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 149.0, 0, 167.0)]];
        
        arrowView.hidden=YES;
        
    }];
    
//    firstStation.state=StationTextFieldStyleDefault;
//    secondStation.state=StationTextFieldStyleDefault;
    
    firstStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    secondStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    
    shouldEnlarge =NO;
}

-(void)showiPadLeftPathView
{
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showiPadLeftPathView];
}

-(void)showiPadSettingsModalView
{
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController showiPadSettingsModalView];
}

-(UIImage*)imageWithColor:(MLine*)line
{
    UIImage *image = [self drawCircleView:[line color]];
    return image;
}

-(UIImage*)biggerImageWithColor:(MLine*)line
{
    UIImage *image = [self drawBiggerCircleView:[line color]];
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

-(void)resetBothStations
{
    shouldEnlarge = YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainViewController resetBothStations];
    firstStation.state=StationTextFieldStyleDefault;
    secondStation.state=StationTextFieldStyleDefault;
}

-(void)resetFromStation
{
    shouldEnlarge = YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    firstStation.state=StationTextFieldStyleDefault;
    secondStation.state=StationTextFieldStyleStation;
    [appDelegate.mainViewController resetFromStation];
}

-(void)resetToStation
{
    shouldEnlarge=YES;
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    firstStation.state=StationTextFieldStyleStation;
    secondStation.state=StationTextFieldStyleDefault;
    [appDelegate.mainViewController resetToStation];
}

-(void)clearFromStation
{
    firstStation.text = @"";
    firstStation.rightViewMode = UITextFieldViewModeAlways;
    [firstStation setLeftView:nil];
    [firstStation setLeftViewMode: UITextFieldViewModeNever];
    firstStation.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    
}

-(void)clearToStation
{
    secondStation.text = @"";
    secondStation.rightViewMode = UITextFieldViewModeAlways;
    [secondStation setLeftView:nil];
    [secondStation setLeftViewMode: UITextFieldViewModeNever];
    secondStation.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    
}

-(void)setStationToField:(StationTextField*)stationField withStation:(MStation*)station
{
    switch (stationField.state) {
        case StationTextFieldStylePath:
            if ([[MHelper sharedHelper] languageIndex]%2) {
                stationField.text = station.altname;
            } else {
                stationField.text = station.name;
            }
            
         break;

        case StationTextFieldStyleSearch:
            if (stationField==firstStation) {
                [self transitFirstToSmallField];
            } else {
                [self transitSecondToSmallField];
            }

        case StationTextFieldStyleDefault:
            if (shouldEnlarge) {
                [self transitToInitialSize];
            }

        case StationTextFieldStyleStation:
            if (station) {
                if ([[MHelper sharedHelper] languageIndex]%2) {
                    stationField.text = station.altname;
                } else {
                    stationField.text = station.name;
                }
                
                stationField.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
                
                if ([[SSThemeManager sharedTheme] isNewTheme]) {

                    UIImage *crossImage = [[SSThemeManager sharedTheme] topToolbarCrossImage:UIControlStateNormal];
                    UIImage *crossImageHighlighted = [[SSThemeManager sharedTheme] topToolbarCrossImage:UIControlStateHighlighted];
                    
                    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [cancelButton setImage:crossImage forState:UIControlStateNormal];
                    [cancelButton setFrame:CGRectMake(0.0, 0.0, crossImage.size.width, crossImage.size.height)];
                    [cancelButton setImage:crossImageHighlighted forState:UIControlStateHighlighted];
                    
                    if (stationField==firstStation) {
                        [cancelButton addTarget:self action:@selector(resetFromStation) forControlEvents:UIControlEventTouchUpInside];
                    } else {
                        [cancelButton addTarget:self action:@selector(resetToStation) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    stationField.rightView= cancelButton;
                    stationField.rightViewMode = UITextFieldViewModeAlways;

                } else {
                
                    stationField.rightViewMode = UITextFieldViewModeNever;
                
                }
                UIImageView *lineColor = [[UIImageView alloc] initWithImage:[self imageWithColor:[station lines]]];
                [stationField setLeftView:lineColor];
                [lineColor release];
                
                [stationField setLeftViewMode: UITextFieldViewModeAlways];
                stationField.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroungHighlighted] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
                
  //              stationField.state=StationTextFieldStyleStation;
                
            } else {
                if (stationField==firstStation) {
                    [self clearFromStation];
                } else {
                    [self clearToStation];
                }
            }
        default:
            break;
    }}

-(void)setFromStation:(MStation*)fromStation
{
//    if (fromStation) {
//        firstStation.state=StationTextFieldStyleStation;
//    } else {
//        firstStation.state=StationTextFieldStyleDefault;
//    }
    
    [self setStationToField:firstStation withStation:fromStation];
}

-(void)setToStation:(MStation*)toStation
{
//    if (toStation) {
//        secondStation.state=StationTextFieldStyleStation;
//    } else {
//        firstStation.state=StationTextFieldStyleDefault;
//    }

    [self setStationToField:secondStation withStation:toStation];
}

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
    
    CGContextRelease(context);
    
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
    
    CGContextRelease(context);
    
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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//}


-(void)dealloc
{
    [super dealloc];
}

@end