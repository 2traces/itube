//
//  TopTwoStationsView.m
//  tube
//
//  Created by Sergey Mingalev on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopTwoStationsView.h"
#import "MainViewController.h"
#import "FastAccessTableViewController.h"
#import "StationTextField.h"
#import "SSTheme.h"
#import "tubeAppDelegate.h"

@implementation TopTwoStationsView

@synthesize toolbar;
@synthesize toStationField;
@synthesize fromStationField;
@synthesize firstButton;
@synthesize secondButton;
@synthesize tableView;
@synthesize arrowView;
@synthesize leftButton;
@synthesize deviceHeight, deviceWidth;
@synthesize fieldWidth, viewHeight;
@synthesize fieldDelta, fieldHeight;
@synthesize delegate;

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
    
    self.autoresizesSubviews = YES;
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
    [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 149.0, self.frame.size.height-4.0, 167.0)]];
    [toolbar setUserInteractionEnabled:YES];
    toolbar.autoresizesSubviews = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:toolbar];
    
    fromStationField = [[StationTextField alloc] initWithFrame:CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight) andStyle:StationTextFieldStyleDefault];
    fromStationField.delegate = self;
    fromStationField.placeholder=NSLocalizedString(@"FromDest", @"From..");
    [toolbar addSubview:fromStationField];
    fromStationField.parentView=self;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 addTarget:self action:@selector(transitFirstToBigField) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth-30.0, fieldHeight);
    self.firstButton=button1;
    [toolbar addSubview:button1];
    
    toStationField = [[StationTextField alloc] initWithFrame:CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight) andStyle:StationTextFieldStyleDefault];
    toStationField.delegate=self;
    toStationField.placeholder=NSLocalizedString(@"ToDest", @"To..");
    [toolbar addSubview:toStationField];
    toStationField.parentView=self;
    
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
        
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            
            UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button3 addTarget:self action:@selector(showiPadLeftPathView) forControlEvents:UIControlEventTouchUpInside];
            [button3 setImage:[UIImage imageNamed:@"newdes_inv_close_ipad_button.png"] forState:UIControlStateNormal];
            button3.frame = CGRectMake(self.frame.size.width-fieldWidth*2.0-31.0, 8, 25, 44);
            self.leftButton=button3;
            self.leftButton.userInteractionEnabled=YES;
            [toolbar addSubview:button3];
            
            UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button4 setImage:[UIImage imageNamed:@"newdes_settings_ipad_button.png"] forState:UIControlStateNormal];
            [button4 setImage:[UIImage imageNamed:@"newdes_settings_ipad_button_pressed.png"] forState:UIControlStateHighlighted];
            [button4 addTarget:self action:@selector(showiPadSettingsModalView) forControlEvents:UIControlEventTouchUpInside];
            button4.frame = CGRectMake(10, 8, 44, 44);
            [toolbar addSubview:button4];
            
        } else {
            
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
            
        }
        
        //       [toolbar release];
        
    }
}

#pragma mark - new methods
-(void)setFromStation:(MStation *)fromStation
{
    if (fromStationField.state==StationTextFieldStyleSearch) {
        [self transitFirstToSmallField];
    }
    fromStationField.station=fromStation;
}

-(void)setToStation:(MStation*)toStation
{
    if (toStationField.state==StationTextFieldStyleSearch) {
        [self transitSecondToSmallField];
    }
    toStationField.station=toStation;
}

-(void)layoutSubviews
{
    if (IS_IPAD) {
        
        fromStationField.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fromStationField.frame.size.width, fromStationField.frame.size.height);
        toStationField.frame = CGRectMake(self.frame.size.width-toStationField.frame.size.width, fieldDelta, toStationField.frame.size.width, toStationField.frame.size.height);
        
        firstButton.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth-30.0, fieldHeight);
        secondButton.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth-30.0, fieldHeight);
        
        CGFloat desireOrigin = (toStationField.frame.origin.x - fromStationField.frame.origin.x - fromStationField.frame.size.width)/2.0+7.0;
        
        arrowView.frame = CGRectMake(toStationField.frame.origin.x-desireOrigin, [[SSThemeManager sharedTheme] isNewTheme] ? 22 : 15, arrowView.frame.size.width, arrowView.frame.size.height);
        
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            leftButton.frame = CGRectMake(self.frame.size.width-fieldWidth*2.0-31.0, 8, 25, 44);
        }
        
//        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
//            if (![[SSThemeManager sharedTheme] isNewTheme]) {
//                if (self.frame.size.width<deviceHeight) {
//                    [self.leftButton setImage:[UIImage imageNamed:@"close_ipad_button.png"] forState:UIControlStateNormal];
//                } else {
//                    [self.leftButton setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
//                }
//            }
//        } else {
//            if (![[SSThemeManager sharedTheme] isNewTheme]) {
//                if (self.frame.size.width<deviceWidth) {
//                    [self.leftButton setImage:[UIImage imageNamed:@"close_ipad_button.png"] forState:UIControlStateNormal];
//                } else {
//                    [self.leftButton setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
//                }
//            }
//        }
    }
}

-(void)adjustSubviews:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        
        fromStationField.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fromStationField.frame.size.width, fromStationField.frame.size.height);
        toStationField.frame = CGRectMake(self.frame.size.width-toStationField.frame.size.width, fieldDelta, toStationField.frame.size.width, toStationField.frame.size.height);
        
        firstButton.frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth-30.0, fieldHeight);
        secondButton.frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth-30.0, fieldHeight);
        
        CGFloat desireOrigin = (toStationField.frame.origin.x - fromStationField.frame.origin.x - fromStationField.frame.size.width)/2.0+7.0;
        
        arrowView.frame = CGRectMake(toStationField.frame.origin.x-desireOrigin, [[SSThemeManager sharedTheme] isNewTheme] ? 22 : 15, arrowView.frame.size.width, arrowView.frame.size.height);
        
        if ([[SSThemeManager sharedTheme] isNewTheme]) {
            leftButton.frame = CGRectMake(self.frame.size.width-fieldWidth*2.0-31.0, 8, 25, 44);
        }
        
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            if (![[SSThemeManager sharedTheme] isNewTheme]) {
                if (self.frame.size.width<deviceHeight) {
                    [self.leftButton setImage:[UIImage imageNamed:@"close_ipad_button.png"] forState:UIControlStateNormal];
                } else {
                    [self.leftButton setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
                }
            }
        } else {
            if (![[SSThemeManager sharedTheme] isNewTheme]) {
                if (self.frame.size.width<deviceWidth) {
                    [self.leftButton setImage:[UIImage imageNamed:@"close_ipad_button.png"] forState:UIControlStateNormal];
                } else {
                    [self.leftButton setImage:[UIImage imageNamed:@"inv_close_ipad_button.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

-(void)transitFirstToBigField
{
    isEditing=YES;
    
    toStationField.hidden=YES;
    
    firstButton.hidden=YES;
    secondButton.hidden=YES;
    
    firstButton.userInteractionEnabled=NO;
    secondButton.userInteractionEnabled=NO;
    
    CGRect frame;
    
    frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth*2, fieldHeight);
    
    [fromStationField changeStyleTo:StationTextFieldStyleSearch withFrame:frame animated:YES];
    
    if (IS_IPAD) {
        [delegate setCurrentSelection:0];
        StationListViewController *controller =  (StationListViewController *)[delegate showiPadLiveSearchView];
        fromStationField.delegate = controller;
        controller.isTextFieldInUse=NO;
        [fromStationField becomeFirstResponder];
    } else {
        FastAccessTableViewController *controller =(FastAccessTableViewController*) [delegate showTableView];
        [delegate setCurrentSelection:0];
        self.tableView=controller;
        fromStationField.delegate = self.tableView;
        [fromStationField becomeFirstResponder];
    }
}

-(void)transitFirstToSmallField
{
    isEditing=NO;
    
    toStationField.hidden=NO;
    
    firstButton.hidden=NO;
    secondButton.hidden=NO;
    
    firstButton.userInteractionEnabled=YES;
    secondButton.userInteractionEnabled=YES;
    
    CGRect frame;
    
    frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight);
    
    if (fromStationField.station) {
        [fromStationField changeStyleTo:StationTextFieldStyleStation withFrame:frame animated:YES];
    } else {
        [fromStationField changeStyleTo:StationTextFieldStyleDefault withFrame:frame animated:YES];
    }
    
    fromStationField.delegate=self;
    self.tableView=nil;
    [fromStationField resignFirstResponder];
}

-(void)transitSecondToBigField
{
    isEditing=YES;
    
    fromStationField.hidden=YES;
    
    firstButton.hidden=YES;
    secondButton.hidden=YES;
    
    firstButton.userInteractionEnabled=NO;
    secondButton.userInteractionEnabled=NO;
    
    CGRect frame;
    
    frame = CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth*2, fieldHeight);
    
    [toStationField changeStyleTo:StationTextFieldStyleSearch withFrame:frame animated:YES];
    
    if (IS_IPAD) {
        [delegate setCurrentSelection:1];
        StationListViewController *controller = [delegate showiPadLiveSearchView];
        toStationField.delegate = controller;
        controller.isTextFieldInUse=NO;
        [toStationField becomeFirstResponder];
    } else {
        FastAccessTableViewController *controller = [delegate showTableView];
        [delegate setCurrentSelection:1];
        self.tableView=controller;
        toStationField.delegate = self.tableView;
        [toStationField becomeFirstResponder];
    }
}

-(void)transitSecondToSmallField
{
    isEditing=NO;
    
    fromStationField.hidden=NO;
    
    firstButton.hidden=NO;
    secondButton.hidden=NO;
    
    firstButton.userInteractionEnabled=YES;
    secondButton.userInteractionEnabled=YES;
    
    CGRect frame;
    
    frame = CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight);
    
    if (toStationField.station) {
        [toStationField changeStyleTo:StationTextFieldStyleStation withFrame:frame animated:YES];
    } else {
        [toStationField changeStyleTo:StationTextFieldStyleDefault withFrame:frame animated:YES];
    }
    
    toStationField.delegate=self;
    self.tableView=nil;
    [toStationField resignFirstResponder];
}

-(void)transitToPathView
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{
        isEditing=NO;
        
        fromStationField.hidden=NO;
        fromStationField.userInteractionEnabled=YES;
        
        toStationField.hidden=NO;
        toStationField.userInteractionEnabled=YES;
        
        firstButton.hidden=YES;
        secondButton.hidden=YES;
        
        arrowView.hidden=NO;
        
        CGFloat maxWidth = fieldWidth;
        
        CGSize textBounds1 = [fromStationField.text sizeWithFont:[[SSThemeManager sharedTheme] toolbarPathFont]];
        CGSize textBounds2 = [toStationField.text sizeWithFont:[[SSThemeManager sharedTheme] toolbarPathFont]];
        
        CGFloat desireWidth1;
        CGFloat desireWidth2;
        CGFloat desireOrigin1;
        CGFloat desireOrigin2;
        CGFloat arrowOrigin;
        CGFloat overallFirst;
        CGFloat overallSecond;
        
        if (fromStationField.leftView) {
            overallFirst = fromStationField.leftView.frame.size.width+textBounds1.width+fromStationField.rightView.frame.size.width+25;
        } else {
            overallFirst = textBounds1.width+fromStationField.rightView.frame.size.width+10;
        }
        
        if (toStationField.leftView) {
            overallSecond = toStationField.leftView.frame.size.width+textBounds2.width+toStationField.rightView.frame.size.width+25;
        } else {
            overallSecond = textBounds2.width+toStationField.rightView.frame.size.width+10;
        }
        
        if (overallFirst+overallSecond+arrowView.frame.size.width>maxWidth*2) {
            if (overallFirst>maxWidth && overallSecond>maxWidth) {
                desireWidth1=maxWidth-arrowView.frame.size.width/2;
                desireWidth2=maxWidth-arrowView.frame.size.width/2;
                desireOrigin1 = self.frame.size.width-2*maxWidth;
                desireOrigin2 = desireOrigin1+desireWidth1+arrowView.frame.size.width;
                arrowOrigin = desireOrigin1 + desireWidth1;
                NSLog(@"case1 - both bigger");
            } else if (overallFirst>=maxWidth && overallSecond<=maxWidth) {
                desireWidth2=overallSecond;
                desireOrigin2=self.frame.size.width-desireWidth2;
                desireOrigin1=self.frame.size.width-2*maxWidth;
                desireWidth1 = desireOrigin2 - desireOrigin1 - arrowView.frame.size.width;
                arrowOrigin = desireOrigin1 + desireWidth1;
                NSLog(@"case2 - first bigger");
            } else {
                desireWidth1=overallFirst;
                desireOrigin1=self.frame.size.width-2*maxWidth;
                desireOrigin2=desireOrigin1+desireWidth1+arrowView.frame.size.width;
                desireWidth2=self.frame.size.width - desireOrigin2;
                arrowOrigin=desireOrigin1 + desireWidth1;
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
        
        CGRect fromNewFrame;
        CGRect toNewFrame;
        
        if (IS_IPAD) {
            
            fromNewFrame = CGRectMake(desireOrigin1, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta ,desireWidth1, 44);
            toNewFrame = CGRectMake(desireOrigin2, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta, desireWidth2, 44);
            arrowView.frame =CGRectMake(arrowOrigin, [[SSThemeManager sharedTheme] isNewTheme] ? 22 : 15, arrowView.frame.size.width, arrowView.frame.size.height);
            
        } else {
            
            fromNewFrame = CGRectMake(desireOrigin1, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta, desireWidth1, 26);
            toNewFrame = CGRectMake(desireOrigin2, [[SSThemeManager sharedTheme] isNewTheme] ? 6 : fieldDelta, desireWidth2, 26);
            arrowView.frame =CGRectMake(arrowOrigin, [[SSThemeManager sharedTheme] isNewTheme] ? 12 : 6, arrowView.frame.size.width, arrowView.frame.size.height);
            
            CGFloat height = [[SSThemeManager sharedTheme] topToolbarPathHeight:UIBarMetricsDefault];
            
            self.frame=CGRectMake(0, 0, 320, height);
            self.toolbar.frame=CGRectMake(0, 0, 320, height);
            
            [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundPathImage] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 149.0, self.viewHeight-4.0, 167.0)]];
            
            
        }
        
        [fromStationField changeStyleTo:StationTextFieldStylePath withFrame:fromNewFrame animated:NO];
        [toStationField changeStyleTo:StationTextFieldStylePath withFrame:toNewFrame animated:NO];
        
    }];
}

-(void)transitToInitialSize
{
    NSTimeInterval duration = 0.2f;
    
    [UIView animateWithDuration:duration animations:^{
        isEditing=NO;
        
        fromStationField.hidden=NO;
        fromStationField.userInteractionEnabled=YES;
        
        toStationField.hidden=NO;
        toStationField.userInteractionEnabled=YES;
        
        firstButton.hidden=NO;
        secondButton.hidden=NO;
        
        if (IS_IPAD) {
            if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
                //                self.frame=CGRectMake(0,0, self., viewHeight);
                //                self.toolbar.frame=CGRectMake(0,0, deviceHeight, viewHeight);
            } else {
                //                self.frame=CGRectMake(0,0, deviceWidth, viewHeight);
                //                self.toolbar.frame=CGRectMake(0,0, deviceWidth, viewHeight);
            }
            
        } else {
            if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
                self.frame=CGRectMake(0,0, deviceHeight, viewHeight);
                self.toolbar.frame=CGRectMake(0,0, deviceHeight, viewHeight);
            } else {
                self.frame=CGRectMake(0,0, deviceWidth, viewHeight);
                self.toolbar.frame=CGRectMake(0,0, deviceWidth, viewHeight);
            }
            
        }
        
        [toolbar setImage:[[[SSThemeManager sharedTheme] topToolbarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 149.0, self.viewHeight-4.0, 167.0)]];
        
        arrowView.hidden=YES;
        
    }];
}

-(void)clearFromStation
{
    fromStationField.text = @"";
    fromStationField.rightViewMode = UITextFieldViewModeAlways;
    [fromStationField setLeftView:nil];
    [fromStationField setLeftViewMode: UITextFieldViewModeNever];
    fromStationField.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    
}

-(void)clearToStation
{
    toStationField.text = @"";
    toStationField.rightViewMode = UITextFieldViewModeAlways;
    [toStationField setLeftView:nil];
    [toStationField setLeftViewMode: UITextFieldViewModeNever];
    toStationField.background = [[[SSThemeManager sharedTheme] stationTextFieldBackgroung] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    
}

#pragma mark - extern call

-(void)showiPadLeftPathView
{
    [delegate showiPadLeftPathView];
}

-(void)showiPadSettingsModalView
{
    [delegate showiPadSettingsModalView];
}

#pragma mark - extern button calls

-(void)restoreFieldAfterPopover
{
    if ([firstButton isHidden]) {
        [self transitFirstToSmallField];
    } else if ([secondButton isHidden]) {
        [self transitSecondToSmallField];
    }
}

-(void) selectFromStation {
    [fromStationField resignFirstResponder];
    [delegate removeTableView];
    if ([firstButton isHidden]) {
        [self transitFirstToSmallField];
    }
    [delegate pressedSelectFromStation];
}

-(void) selectToStation {
    [toStationField resignFirstResponder];
    [delegate removeTableView];
    if ([secondButton isHidden]) {
        [self transitSecondToSmallField];
    }
    [delegate pressedSelectToStation];
}


-(void)resetBothStations
{
    shouldEnlarge = YES;
    [delegate resetBothStations];
}

-(void)resetFromStation
{
    [self resetStation:fromStationField];
}

-(void)resetToStation
{
    [self resetStation:toStationField];
}

-(void)setButtonToState:(int)state
{
    if (state) {
        [self.leftButton setImage:[UIImage imageNamed:@"newdes_inv_close_ipad_button.png"] forState:UIControlStateNormal];
    } else {
        [self.leftButton setImage:[UIImage imageNamed:@"newdes_close_ipad_button.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - UITextField delegate

// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isEditing) {
        return YES;
    } else {
        return NO;
    }
}

-(void)resetStation:(StationTextField*)field
{
    if (field==fromStationField) {
        [delegate resetFromStation];
        if (toStationField.state==StationTextFieldStylePath) {
            [fromStationField changeStyleTo:StationTextFieldStyleDefault withFrame:CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight) animated:YES];
            [toStationField changeStyleTo:StationTextFieldStyleStation withFrame:CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight) animated:YES];
            [self transitToInitialSize];
        }
    } else {
        [delegate resetToStation];
        if (fromStationField.state==StationTextFieldStylePath) {
            [fromStationField changeStyleTo:StationTextFieldStyleStation withFrame:CGRectMake(self.frame.size.width-fieldWidth*2, fieldDelta, fieldWidth, fieldHeight) animated:YES];
            [toStationField changeStyleTo:StationTextFieldStyleDefault withFrame:CGRectMake(self.frame.size.width-fieldWidth, fieldDelta, fieldWidth, fieldHeight) animated:YES];
            [self transitToInitialSize];
        }
    }
}

-(void)callStationList:(StationTextField*)field
{
    if (field==fromStationField) {
        [self selectFromStation];
    } else {
        [self selectToStation];
    }
}

-(void)dealloc
{
    [super dealloc];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIView *view = [[delegate view] viewWithTag:555];
//    if (view) {
//        [view touchesBegan: touches withEvent: event];
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIView *view = [[delegate view] viewWithTag:555];
//    if (view) {
//        [view touchesMoved: touches withEvent: event];
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIView *view = [[delegate view] viewWithTag:555];
//    if (view) {
//        [view touchesEnded: touches withEvent: event];
//    }
//}
//
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    UIView *view = [[delegate view] viewWithTag:555];
//    if (view) {
//        [view motionBegan:motion withEvent:event];
//    }
//}
//
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    UIView *view = [[delegate view] viewWithTag:555];
//    if (view) {
//        [view motionEnded:motion withEvent:event];
//    }
//}
//
//- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    UIView *view = [[delegate view] viewWithTag:555];
//    if (view) {
//        [view motionCancelled:motion withEvent:event];
//    }
//}


@end