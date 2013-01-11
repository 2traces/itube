//
//  NewTheme.m
//  tube
//
//  Created by Sergey Mingalev on 30.11.12.
//
//

#import "NewTheme.h"
#import "tubeAppDelegate.h"

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
    return [UIImage imageNamed:@"newdes_toolbar_text_bg_high.png"];
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
    if (IS_IPAD) {
        return nil;
    } else {
    return [UIImage imageNamed:@"newdes_pathbar_bg.png"];
    }
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
    if (IS_IPAD) {
        return 250.0f;
    } else {
        return 223.0f;
    }
}

-(UIImage*)pathBarViewDestinationIcon
{
    return [UIImage imageNamed:@"newdes_pathbar_destination_icon"];
}

-(UIImage*)pathBarViewClockIcon
{
    if (IS_IPAD) {
        return [UIImage imageNamed:@"newdes_ipad_stations_clock"];
    } else {
        return [UIImage imageNamed:@"clock"];
    }
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
    if (IS_IPAD) {
        return [UIImage imageNamed:@"newdes_ipad_left_background"];
    } else {
        return [UIImage imageNamed:@"newdes_vert_path_bg"];
    }
}

-(CGFloat)vertScrollViewStartY
{
    return 40.0f;
}

-(CGFloat)statusViewWidth
{
    return 300.0f;
}

-(UIImage*)statusViewBackground
{
    return [UIImage imageNamed:@"newdes_status_view_bg.png"];
}

-(UIColor*)statusViewFontColor
{
    return [self mainColor];
}

-(CGFloat)statusViewStartX
{
    return 10.0f;
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
    return 60.0f;
}

-(UIImage*)stationsTableViewBackground
{
    return nil;
}

-(UIColor*)stationsTableViewBackgroundColor
{
    UIColor *color = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"newdesBackground"]];
    return [color autorelease];
}

-(UIImage*)stationsTabBarBottomBackgroundStations
{
        return [UIImage imageNamed:@"newdes_stations_bottom_bg"];
}

-(UIImage*)stationsTabBarBookmarkButtonForState:(UIControlState)state
{
    NSString *name;
    if (IS_IPAD) {
        if (state == UIControlStateNormal) {
            name = @"newdes_ipad_stations_bookmarks";
        } else  {
            name = @"newdes_ipad_stations_bookmarks_pressed";
        }
        
    } else {
    if (state == UIControlStateNormal) {
        name = @"newdes_stations_bookmarks";
    } else  {
        name = @"newdes_stations_bookmarks_pressed";
    }
    }
    
    UIImage *image = [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 45, 0, 5)];
    return image;

}

-(UIImage*)stationsTabBarHistoryButtonForState:(UIControlState)state
{
    NSString *name;
    if (IS_IPAD) {
        if (state == UIControlStateNormal) {
            name = @"newdes_ipad_stations_history";
        } else  {
            name = @"newdes_ipad_stations_history_pressed";
        }
        
    } else {
    if (state == UIControlStateNormal) {
        name = @"newdes_stations_history";
    } else  {
        name = @"newdes_stations_history_pressed";
    }
    }
    
    UIImage *image = [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 45, 0, 5)];
    return image;

}

-(UIImage*)stationsTabBarSettingsButtonForState:(UIControlState)state
{
    NSString *name;
    if (IS_IPAD) {
        if (state == UIControlStateNormal) {
            name = @"newdes_ipad_stations_settings";
        } else  {
            name = @"newdes_ipad_stations_settings_pressed";
        }
        
    } else {

    if (state == UIControlStateNormal) {
        name = @"newdes_stations_settings";
    } else  {
        name = @"newdes_stations_settings_pressed";
    }
    }
    UIImage *image = [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 45, 0, 5)];
    return image;

}

-(UIImage*)stationsTabBarTopBackgroundStations
{
        return [UIImage imageNamed:@"newdes_stations_background"];
}

-(UIImage*)stationsTabBarTopBackgroundLines
{
        return [UIImage imageNamed:@"newdes_lines_background"];
}

-(UIImage*)stationsTabBarStationButtonForState:(UIControlState)state type:(int)type
{
    NSString *name;
    
    if (IS_IPAD) {
        if (state == UIControlStateNormal) {
                name = @"newdes_ipad_s_stationsbutton";
        } else  {
                name = @"newdes_ipad_s_stationsbutton_pressed";
        }
    } else {
        if (state == UIControlStateNormal) {
            if (!type) {
                name = @"newdes_s_stationsbutton";
            } else {
                name = @"newdes_l_stationsbutton";
            }
        } else  {
            if (!type) {
                name = @"newdes_s_stationsbutton";
            } else {
                name = @"newdes_l_stationsbutton_pressed";
            }
        }
    }

    UIImage *image = [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    return image;
}

-(UIImage*)stationsTabBarLineButtonForState:(UIControlState)state type:(int)type
{
    NSString *name;
    if (IS_IPAD) {
        if (state == UIControlStateNormal) {
            name = @"newdes_ipad_s_linesbutton";
        } else  {
            name = @"newdes_ipad_s_linesbutton_pressed";
        }
        
    } else {
        if (state == UIControlStateNormal) {
        if (!type) {
            name = @"newdes_s_linesbutton";
        } else {
            name = @"newdes_l_linesbutton";
        }
    } else  {
        if (!type) {
            name = @"newdes_s_linesbutton_pressed";
        } else {
            name = @"newdes_l_linessbutton";
        }
    }
    }
    UIImage *image = [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    return image;
    
}

-(UIImage*)stationsTabBarBackButtonForState:(UIControlState)state type:(int)type
{
    NSString *name;
    if (state == UIControlStateNormal) {
        if (!type) {
            name = @"newdes_s_backbutton";
        } else {
            name = @"newdes_l_backbutton";
        }
    } else  {
        if (!type) {
            name = @"newdes_s_backbutton_pressed";
        } else {
            name = @"newdes_l_backbutton_pressed";
        }
    }
    
    UIImage *image = [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    return image;    
}

-(UIColor*)stationsBottomButtonsColor
{
    if (IS_IPAD) {
        return [UIColor colorWithRed:250.0/255.0 green:232.0/255.0 blue:206.0/255.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:115.0/255.0 green:46.0/255.0 blue:22.0/255.0 alpha:1.0];
    }
}

-(UIColor*)stationsBottomButtonsPressedColor
{
    if (IS_IPAD) {
        return [UIColor colorWithRed:217.0/255.0 green:152.0/255.0 blue:114.0/255.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:217.0/255.0 green:152.0/255.0 blue:114.0/255.0 alpha:1.0];
    }
}

-(UIColor*)stationsBottomButtonsShadowColor
{
    if (IS_IPAD) {
        return [UIColor blackColor];
    } else {
        return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    }
}

-(UIColor*)stationsBottomButtonsPressedShadowColor
{
    if (IS_IPAD) {
        return [UIColor blackColor];
//        return [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:193.0/255.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    }
}

-(UIImage*)mapLabelEmbossedCircleImage
{
    return [UIImage imageNamed:@"newdes_label_bubble"];
}

-(UIColor*)stationsTopButtonsColor
{
    if (IS_IPAD) {
        return [UIColor colorWithRed:195.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:195.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0];
    }
}

-(UIColor*)stationsTopButtonsPressedColor
{
    if (IS_IPAD) {
        return [UIColor whiteColor];
    } else {
        return [UIColor whiteColor];
    }
}

-(UIColor*)stationsTopButtonsShadowColor
{
    if (IS_IPAD) {
        return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75];
    } else {
        return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75];
    }
}

-(UIColor*)stationsTopButtonsPressedShadowColor
{
    if (IS_IPAD) {
        return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75];
    } else {
        return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75];
    }
}

-(UIFont*)pathBarViewFont;
{
    if (IS_IPAD) {
        return  [UIFont fontWithName:@"MyriadPr-Bold" size:18.0];
    } else {
        return  [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
    }
}

-(UIColor*)pathBarViewFontColor1;
{
    if (IS_IPAD) {
        return [self highlightColor];
    } else {
        return [UIColor darkGrayColor];
    }
}

-(UIColor*)pathBarViewFontColor2;
{
    if (IS_IPAD) {
        return [self highlightColor];
    } else {
        return [UIColor darkGrayColor];
    }
}

-(UIColor*)pathBarViewFontShadowColor;
{
    if (IS_IPAD) {
        return [UIColor colorWithRed:0.84 green:0.62 blue:0.47 alpha:1.0];
    } else {
        return [UIColor whiteColor];
    }

}

@end

