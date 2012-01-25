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

@interface TopTwoStationsView : UIView <UITextFieldDelegate>
{
    UIImageView  *toolbar; 
	UITextField *firstStation;
	UITextField *secondStation;	
    BOOL isEditing;
    
    FastAccessTableViewController *tableView;
}

@property (nonatomic, retain) UIImageView *toolbar;
@property (nonatomic, retain) UITextField *firstStation;
@property (nonatomic, retain) UITextField *secondStation;
@property (nonatomic, retain) UIButton *firstButton;
@property (nonatomic, retain) UIButton *secondButton;
@property (nonatomic, retain) FastAccessTableViewController *tableView;

-(void)drawInitialState;
-(void)setFromStation:(MStation*)fromStation;
-(void)setToStation:(MStation*)toStation;
-(UIImage*)drawCircleView:(UIColor*)myColor;

@end
