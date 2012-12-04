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
    UIImage *image = [UIImage imageNamed:@"backButtonBG.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 18.0, 0.0, 10.0)];
    return image;
}

- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    UIImage *image = [UIImage imageNamed:@"backButtonBG.png"];
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

@end
