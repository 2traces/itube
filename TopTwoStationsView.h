//
//  TopTwoStationsView.h
//  tube
//
//  Created by sergey on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MStation;
@class FastAccessTableViewController;
@class StationTextField;

@interface TopTwoStationsView : UIView <UITextFieldDelegate>
{
    UIImageView  *toolbar; 
	StationTextField *firstStation;
	StationTextField *secondStation;	
    BOOL isEditing;
    BOOL shouldEnlarge;
    UIImageView *arrowView;
    
    FastAccessTableViewController *tableView;
}

@property (nonatomic, retain) UIImageView *toolbar;
@property (nonatomic, retain) UITextField *firstStation;
@property (nonatomic, retain) UITextField *secondStation;
@property (nonatomic, retain) UIButton *firstButton;
@property (nonatomic, retain) UIButton *secondButton;
@property (nonatomic, retain) FastAccessTableViewController *tableView;
@property (nonatomic, retain) UIImageView *arrowView;
@property (nonatomic, retain) UIButton *leftButton;

-(void)drawInitialState;
-(void)adjustSubviews:(UIInterfaceOrientation)interfaceOrientation;
-(void)setFromStation:(MStation*)fromStation;
-(void)setToStation:(MStation*)toStation;
-(UIImage*)drawCircleView:(UIColor*)myColor;
-(UIImage*)drawBiggerCircleView:(UIColor*)myColor;
-(void)transitToPathView;

-(void)resetFromStation;
-(void)resetToStation;
-(void)resetBothStations;


@end
