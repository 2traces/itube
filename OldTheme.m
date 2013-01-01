//
//  OldTheme.m
//  tube
//
//  Created by Sergey Mingalev on 30.11.12.
//
//

#import "OldTheme.h"

@implementation OldTheme

- (UIColor *)shadowColor
{
    return nil;
}

- (UIColor *)backgroundColor
{
    return nil;
}

- (UIColor *)baseTintColor
{
    return nil;
}

- (UIColor *)accentTintColor
{
    return nil;
}

- (UIColor *)switchThumbColor
{
    return nil;
}

- (UIColor *)switchOnColor
{
    return nil;
}

- (UIColor *)switchTintColor
{
    return nil;
}

- (CGSize)shadowOffset
{
    return CGSizeZero;
}

- (UIImage *)topShadow
{
    return nil;
}

- (UIImage *)bottomShadow
{
    return nil;
}

- (UIImage *)toolbarBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    return nil;
}

- (UIImage *)searchBackground
{
    return nil;
}

- (UIImage *)searchFieldImage
{
    return nil;
}

- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state
{
    return nil;
}

- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state
{
    return nil;
}

- (UIImage *)searchScopeButtonDivider
{
    return nil;
}

- (UIImage *)segmentedBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
{
    return nil;
}

- (UIImage *)segmentedDividerForBarMetrics:(UIBarMetrics)barMetrics
{
    return nil;
}

- (UIImage *)tableBackground
{
    return nil;
}

- (UIImage *)onSwitchImage
{
    return nil;
}

- (UIImage *)offSwitchImage
{
    return nil;
}

- (UIImage *)sliderThumbForState:(UIControlState)state
{
    return nil;
}

- (UIImage *)sliderMinTrack
{
    return nil;
}

- (UIImage *)sliderMaxTrack
{
    return nil;
}

- (UIImage *)speedSliderMinImage
{
    return nil;
}

- (UIImage *)speedSliderMaxImage
{
    return nil;
}

- (UIImage *)progressTrackImage
{
    return nil;
}

- (UIImage *)progressProgressImage
{
    return nil;
}

- (UIImage *)stepperBackgroundForState:(UIControlState)state
{
    return nil;
}

- (UIImage *)stepperDividerForState:(UIControlState)state
{
    return nil;
}

- (UIImage *)stepperIncrementImage
{
    return nil;
}

- (UIImage *)stepperDecrementImage
{
    return nil;
}

- (UIImage *)tabBarBackground
{
    return nil;
}

- (UIImage *)tabBarSelectionIndicator
{
    return nil;
}

- (UIImage *)imageForTab:(SSThemeTab)tab
{
    return nil;
}

- (UIImage *)finishedImageForTab:(SSThemeTab)tab selected:(BOOL)selected
{
    return nil;
}

#pragma mark --- Soj

-(UIFont *)fontForDemoMapView
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0];
}


- (UIColor *)mainColor
{
    return [UIColor blackColor];
}

- (UIColor *)highlightColor
{
    return [UIColor darkGrayColor];
}

- (UIColor *)titleShadowColor
{
    return [UIColor whiteColor];
}

- (UIColor *)backButtonTitleColor
{
    return [self mainColor];
}

- (UIColor *)backButtonPressedTitleColor
{
    return [UIColor whiteColor];
}

-(UIImage *)demoMapViewBackgroundImage
{
    UIImage *image = [UIImage imageNamed:@"background.png"];
    return image;
}

-(UIColor *)demoMapViewBackgroundColor
{
    UIColor *color = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    return [color autorelease];
}

-(UIFont*)navigationTitleFont
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:20.0];
}

-(UIFont*)settingsTableViewFont
{
    return [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
}

//-(UIFont*)settingsTableViewFontColor
//{
//    return [UIFont fontWithName:@"MyriadPro-Regular" size:18.0];
//}

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    UIImage *image = [[UIImage imageNamed: @"grey_top_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)];
    return image;
}

-(UIFont *)backbuttonTitleFont
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:14.0];
}

- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"backButtonBG.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"backButtonBGPressed.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 18.0, 0.0, 10.0)];
    return image;
}

- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"backButtonBG.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"backButtonBGPressed.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 18.0, 0.0, 10.0)];
    return image;
}

- (UIImage *)buttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"demo_buy.png";
        //        name = @"newdesBuyMapButtonPattern.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"demo_buy_pressed.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    //    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 16.0, 10.0, 16.0)];
    return image;
}

- (UIImage *)firstAndLastCellSettingsTableImageNormal
{
   return [UIImage imageNamed:@"first_and_last_cell_bg.png"];
}

- (UIImage *)firstAndLastCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"high_first_and_last_cell_bg.png"];
}

- (UIImage *)firstCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"first_cell_bg.png"];
}

- (UIImage *)firstCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"high_first_cell_bg.png"];
}

- (UIImage *)lastCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"last_cell_bg.png"];
}

- (UIImage *)lastCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"high_last_cell_bg.png"];
}

- (UIImage *)middleCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"middle_cell_bg.png"];
}

- (UIImage *)middleCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"high_middle_cell_bg.png"];
}

- (CGFloat)widthSettingsCellTableView
{
    return 304.0;
}

- (UIImage *)buybuttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"buy_button.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"high_buy_button.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

- (UIImage *)greenbuttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"green_button.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"high_green_button.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

- (UIImage *)bluebuttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"blue_button.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"blue_button.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIColor *)buyButtonFontColorInstalled
{
    return [UIColor whiteColor];
}

-(UIColor *)buyButtonFontColorAvailable
{
    return [UIColor blackColor];
}

-(UIFont *)buyButtonFont
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:15.0];
}

-(UIImage *)stationTextFieldBackgroung
{
    return [UIImage imageNamed:@"toolbar_text_bg.png"];
}

-(UIImage *)stationTextFieldBackgroungHighlighted
{
    return [UIImage imageNamed:@"toolbar_text_bg_lighted.png"];
}

-(UIImage *)stationTextFieldRightImageNormal
{
    return [UIImage imageNamed:@"openlist.png"];
}

-(UIImage *)stationTextFieldRightImageHighlighted
{
    return [UIImage imageNamed:@"openlist_highlight.png"];
}

-(UIImage*)topToolbarBackgroundImage
{
    return [UIImage imageNamed:@"toolbar_bg1.png"];
}

-(UIImage*)topToolbarBackgroundPathImage
{
    return [UIImage imageNamed:@"upper_path_bg.png"];
}


-(CGFloat)topToolbarHeight:(UIBarMetrics)metrics
{
    return 44.0;
}

-(CGFloat)toolbarFieldHeight
{
    return 44.0;
}

-(CGFloat)toolbarFieldDelta
{
    return 0.0;
}

-(UIImage*)topToolbarCrossImage:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"cross_red";
    } else if (state == UIControlStateHighlighted) {
        name = @"cross_opaq";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)topToolbarArrowPathImage
{
    return [UIImage imageNamed:@"arrowIcon.png"];
}

-(UIImage*)mapViewSettingsButton:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"settings_btn_normal";
    } else if (state == UIControlStateHighlighted) {
        name = @"settings_btn";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)mapViewEntryButton:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"src_button_normal";
    } else if (state == UIControlStateHighlighted) {
        name = @"src_button_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)mapViewExitButton:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"dst_button_normal";
    } else if (state == UIControlStateHighlighted) {
        name = @"dst_button_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)mapViewLabelView
{
    return [UIImage imageNamed:@"station_label"];    
}

-(CGFloat)topToolbarPathHeight:UIBarMetricsDefault
{
    return 26.0;
}

-(CGFloat)pathViewHeight:UIBarMetricsDefault
{
    return 40.0;
}

-(UIFont*)toolbarPathFont
{
    return [UIFont fontWithName:@"MyriadPro-Regular" size:15.0];
}

-(UIColor*)toolbarPathFontColor
{
    return [UIColor blackColor];
}

-(void)decorMapViewMainLabel:(UILabel*)label
{
    label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:21.0];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.5f, 1.f);
}

-(void)decorMapViewLineLabel:(UILabel*)label
{
    label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:21.f];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    label.text = @"1";
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.5f, 1.f);   
}

-(void)decorMapViewCircleLabel:(UIView*)label
{
    
}

-(UIImage*)horizontalPathViewBackground
{
    return [UIImage imageNamed:@"lower_path_bg.png"];
}

-(CGRect)horizontalPathViewRect
{
    return CGRectMake(0.0, 26.0, 320.0, [self pathViewHeight:UIBarMetricsDefault]);
}

-(CGFloat)horizontalPathSwitchButtonY
{
    return 66.0f;
}


-(CGFloat)stationTextFieldRightAdjust
{
    return 7.0f;
}

-(CGFloat)stationTextFieldDrawTextInRectAdjust
{
    return 3.0f;
}

-(BOOL)isNewTheme
{
    return NO;
}

-(CGFloat)pathBarViewWidth
{
    return 305.0f;
}

-(UIImage*)pathBarViewDestinationIcon
{
    return [UIImage imageNamed:@"flag.png"];
}

-(UIImage*)switchButtonImage:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"switch_to_path";
    } else if (state == UIControlStateHighlighted) {
        name = @"switch_to_path_high";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)vertScrollViewBackground
{
    return nil;
}

-(CGFloat)vertScrollViewStartY
{
    return 66.0f;
}

-(CGFloat)statusViewWidth
{
    return 320.0f;
}

-(UIImage*)statusViewBackground
{
    return [UIImage imageNamed:@"statusViewBG.png"];
}

-(UIColor*)statusViewFontColor
{
    return [UIColor blackColor];
}

-(CGFloat)statusViewStartX
{
    return 0.0f;
}

-(CGFloat)statusViewTextY
{
    return 60.0f;
}

-(CGFloat)statusViewUpdateY
{
    return 60.0f;
}

-(CGFloat)fastAccessTableViewStartY
{
    return [self topToolbarHeight:UIBarMetricsDefault];
}

-(UIImage*)stationsTableViewBackground
{
    UIImage *image = [UIImage imageNamed:@"background.png"];
    return image;
}

-(UIColor*)stationsTableViewBackgroundColor
{
    return nil;
}

-(UIImage*)stationsTabBarBottomBackgroundStations
{
    return nil;
}



@end
