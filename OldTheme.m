//
//  OldTheme.m
//  tube
//
//  Created by sergey on 30.11.12.
//
//

#import "OldTheme.h"

@implementation OldTheme

- (UIColor *)mainColor
{
    return nil;
}

- (UIColor *)highlightColor
{
    return nil;
}

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

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    return nil;
}

- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics
{
    return nil;
}

- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
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

- (UIImage *)buttonBackgroundForState:(UIControlState)state
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
    NSString *name = nil;
    if (tab == SSThemeTabDoor) {
        name = @"defaultDoorTab";
    } else if (tab == SSThemeTabPower) {
        name = @"defaultPowerTab";
    } else if (tab == SSThemeTabControls) {
        name = @"defaultControlsTab";
    }
    return (name ? [UIImage imageNamed:name] : nil);
}

- (UIImage *)finishedImageForTab:(SSThemeTab)tab selected:(BOOL)selected
{
    return nil;
}

- (UIImage *)doorImageForState:(UIControlState)state
{
    NSString *name = nil;
    if (state == UIControlStateNormal) {
        name = @"doorClosed";
    } else if (state == UIControlStateSelected) {
        name = @"doorOpen";
    }
    if (name) {
        UIImage *image = [UIImage imageNamed:name];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(16.0, 0.0, 15.0, 0.0)];
        return image;
    } else {
        return nil;
    }
}

@end
