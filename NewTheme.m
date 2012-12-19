//
//  NewTheme.m
//  tube
//
//  Created by Sergey Mingalev on 30.11.12.
//
//

#import "NewTheme.h"

@implementation NewTheme

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
    return [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1.0];
}

- (UIColor *)highlightColor
{
    return [UIColor colorWithRed:115.0/255.0 green:46.0/255.0 blue:22.0/255.0 alpha:1.0];
//    return [UIColor colorWithRed:99.0/255.0 green:37.0/255.0 blue:17.0/255.0 alpha:1.0];
}

- (UIColor *)titleShadowColor
{
    return [UIColor colorWithRed:215.0/255.0 green:158.0/255.0 blue:120.0/255.0 alpha:1.0];
}

- (UIColor *)backButtonTitleColor
{
    return [self highlightColor];
}

- (UIColor *)backButtonPressedTitleColor
{
    return [self titleShadowColor];
}

-(UIImage *)demoMapViewBackgroundImage
{
    return nil;
}

-(UIColor *)demoMapViewBackgroundColor
{
    UIColor *color = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"newdesBackground.png"]];
    return [color autorelease];
}

-(UIFont*)navigationTitleFont
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:20.0];
}

-(UIFont*)settingsTableViewFont
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:18.0];
}

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    UIImage *image = [[UIImage imageNamed: @"newdesNavbarSettingsBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)];
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
        name = @"newdes_back_button.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_back_button_pressed.png";
    }
   UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 18.0, 0.0, 10.0)];
    return image;
}

- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_back_button.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_back_button_pressed.png";
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 18.0, 0.0, 10.0)];
    return image;
}

- (UIImage *)buttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_demo_buy.png";
        //        name = @"newdesBuyMapButtonPattern.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_demo_buy_pressed.png";
    }
    UIImage *image = [UIImage imageNamed:name];
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 16.0, 10.0, 16.0)];
    return image;
}

- (UIImage *)firstAndLastCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg.png"];
}

- (UIImage *)firstAndLastCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg_high.png"];
}

- (UIImage *)firstCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg.png"];
}

- (UIImage *)firstCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg_high.png"];
}

- (UIImage *)lastCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg.png"];
}

- (UIImage *)lastCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg_high.png"];
}

- (UIImage *)middleCellSettingsTableImageNormal
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg.png"];
}

- (UIImage *)middleCellSettingsTableImageHighlighted
{
    return [UIImage imageNamed:@"newdes_settings_cell_bg_high.png"];
}

- (CGFloat)widthSettingsCellTableView
{
    return 320.0;
}

- (UIImage *)buybuttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_buy_button.png";
    } else if (state == UIControlStateHighlighted) {
//        name = @"newdes_demo_buy_pressed.png";
        return nil;
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

- (UIImage *)greenbuttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_green_button.png";
    } else if (state == UIControlStateHighlighted) {
        //        name = @"newdes_demo_buy_pressed.png";
        return nil;
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

- (UIImage *)bluebuttonBackgroundForState:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_blue_button.png";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_blue_button.png";
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
    return [UIColor colorWithRed:81.0/255.0 green:79.0/255.0 blue:78.0/255.0 alpha:1.0];
}

-(UIFont *)buyButtonFont
{
    return [UIFont fontWithName:@"MyriadPro-Semibold" size:15.0];
}

-(UIImage *)stationTextFieldBackgroung
{
    return [UIImage imageNamed:@"newdes_toolbar_text_bg.png"];
}

-(UIImage *)stationTextFieldBackgroungHighlighted
{
    return [UIImage imageNamed:@"newdes_toolbar_text_bg_lighted.png"];
}

-(UIImage *)stationTextFieldRightImageNormal
{
    return [UIImage imageNamed:@"newdes_openlist.png"];
}

-(UIImage *)stationTextFieldRightImageHighlighted
{
    return [UIImage imageNamed:@"newdes_openlist_highlight.png"];
}

-(UIImage*)topToolbarBackgroundImage
{
    return [UIImage imageNamed:@"newdes_top_toolbar_bg.png"];
}

-(UIImage*)topToolbarBackgroundPathImage
{
    return [UIImage imageNamed:@"newdes_top_toolbar_path_bg.png"];
}

-(CGFloat)topToolbarHeight:(UIBarMetrics)metrics
{
    return 87.0;
}

-(CGFloat)toolbarFieldHeight
{
    return 40.0;
}

-(CGFloat)toolbarFieldDelta
{
    return 8.0;
}

-(UIImage*)topToolbarCrossImage:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_cross_button";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_cross_button_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)topToolbarArrowPathImage
{
    return [UIImage imageNamed:@"newdes_arrow_icon"];
}

-(UIImage*)mapViewSettingsButton:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_settings_button";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_settings_button_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)mapViewEntryButton:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_button_enter";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_button_enter_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)mapViewExitButton:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_button_exit";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_button_exit_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)mapViewLabelView
{
    return [UIImage imageNamed:@"newdes_label_bg"];
}

-(CGFloat)topToolbarPathHeight:UIBarMetricsDefault
{
    return 67.0;
}

-(CGFloat)pathViewHeight:UIBarMetricsDefault
{
    return 61.0;
}

-(UIFont*)toolbarPathFont
{
    return [UIFont fontWithName:@"MyriadPro-Regular" size:17.0];
}

-(UIColor*)toolbarPathFontColor
{
    return [self highlightColor];
}

-(void)decorMapViewMainLabel:(UILabel*)label
{
    label.frame = CGRectMake(50, 10, 115, 25); //
    label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:19.0];
    label.textColor = [self highlightColor];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor colorWithRed:215.0/255.0 green:158.0/255.0 blue:120.0/255.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0.5f, 1.f); 
}

-(void)decorMapViewLineLabel:(UILabel*)label
{
    label.frame = CGRectMake(165, 10, 40, 25); //
    label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:19.f];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    label.text = @"1";
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.5f, 1.f);
}

-(void)decorMapViewCircleLabel:(UIView*)label
{
    label.frame = CGRectMake(25, 9, 21, 21); //
}

-(UIImage*)horizontalPathViewBackground
{
    return [UIImage imageNamed:@"newdes_pathbar_bg.png"];
}

-(CGRect)horizontalPathViewRect
{
    return CGRectMake(10.0, 40, 300.0, [self pathViewHeight:UIBarMetricsDefault]);
}

-(CGFloat)horizontalPathSwitchButtonY
{
    return 40.0f;
}

-(CGFloat)stationTextFieldRightAdjust
{
    return 1.0f;
}

-(CGFloat)stationTextFieldDrawTextInRectAdjust
{
    return 7.0f;
}

-(BOOL)isNewTheme
{
    return YES;
}

-(CGFloat)pathBarViewWidth
{
    return 223.0f;
}

-(UIImage*)pathBarViewDestinationIcon
{
    return [UIImage imageNamed:@"newdes_pathbar_destination_icon"];
}

-(UIImage*)switchButtonImage:(UIControlState)state
{
    NSString *name;
    if (state == UIControlStateNormal) {
        name = @"newdes_switch_button";
    } else if (state == UIControlStateHighlighted) {
        name = @"newdes_switch_button_pressed";
    }
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

-(UIImage*)vertScrollViewBackground
{
    return [UIImage imageNamed:@"newdes_vert_path_bg"];
}


@end

