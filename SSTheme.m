#import "SSTheme.h"
#import "OldTheme.h"
#import "NewTheme.h"

@implementation SSThemeManager

+ (id <SSTheme>)sharedTheme
{
    static id <SSTheme> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme:

#if defined(NEW_THEME)
        sharedTheme = [[NewTheme alloc] init];
        NSLog(@"New Theme");
#else
        sharedTheme = [[OldTheme alloc] init];
        NSLog(@"Old Theme");
#endif

    });
    
    return sharedTheme;
}

+ (void)customizeAppAppearance
{
    id <SSTheme> theme = [self sharedTheme];
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
//    if ([navigationBarAppearance respondsToSelector:@selector(setShadowImage:)]) {
//        [navigationBarAppearance setShadowImage:[theme topShadow]];
//    }
    
    [navigationBarAppearance setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[theme highlightColor], UITextAttributeTextColor, [theme navigationTitleFont], UITextAttributeFont, [theme titleShadowColor],UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil];
    
    [navigationBarAppearance setTitleTextAttributes:textTitleOptions];
    
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];

    
#if defined(NEW_THEME)
    [barButtonItemAppearance setBackButtonBackgroundVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleVerticalPositionAdjustment:3.0f forBarMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f) forBarMetrics:UIBarMetricsDefault];
#else
    [navigationBarAppearance setTitleVerticalPositionAdjustment:4.0f forBarMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f) forBarMetrics:UIBarMetricsDefault];
#endif

    
//    [barButtonItemAppearance setBackButtonBackgroundVerticalPositionAdjustment:-3.0f forBarMetrics:UIBarMetricsDefault];

//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone];
//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone];
    
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme titleShadowColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonPressedTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme titleShadowColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateDisabled];
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonPressedTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme backButtonTitleColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateHighlighted];
    
//    [barButtonItemAppearance setTitlePositionAdjustment:UIOffsetMake(0.0, 3.0f) forBarMetrics:UIBarMetricsDefault];

//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone];
//    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone];

    

    
}

+ (void)customizeView:(UIView *)view
{
    id <SSTheme> theme = [self sharedTheme];
}

+ (void)customizeTableView:(UITableView *)tableView
{
    id <SSTheme> theme = [self sharedTheme];
    UIImage *backgroundImage = [theme tableBackground];
    UIColor *backgroundColor = [theme backgroundColor];
    if (backgroundImage) {
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
        [tableView setBackgroundView:background];
    } else if (backgroundColor) {
        [tableView setBackgroundView:nil];
        [tableView setBackgroundColor:backgroundColor];
    }
}

+ (void)customizeTabBarItem:(UITabBarItem *)item forTab:(SSThemeTab)tab
{
    id <SSTheme> theme = [self sharedTheme];
    UIImage *image = [theme imageForTab:tab];
    if (image) {
        // If we have a regular image, set that
        [item setImage:image];
    } else {
        // Otherwise, set the finished images
        UIImage *selectedImage = [theme finishedImageForTab:tab selected:YES];
        UIImage *unselectedImage = [theme finishedImageForTab:tab selected:NO];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
    }
}

+ (void)customizeSettingsTableView:(UITableView*)tableView imageView:(UIImageView*)imageView searchBar:(UISearchBar*)searchBar
{
    id <SSTheme> theme = [self sharedTheme];
    UIImage *backgroundImage = [theme stationsTableViewBackground];
    UIColor *backgroundColor = [theme stationsTableViewBackgroundColor];
    if (backgroundImage) {
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
        [tableView setBackgroundView:background];
        imageView.image=nil;
    } else if (backgroundColor) {
        [tableView setBackgroundView:nil];
        [tableView setBackgroundColor:backgroundColor];
        imageView.image=nil;
    }
    
    searchBar.tintColor=[UIColor lightGrayColor];
    
    
    
    //    if ([[SSThemeManager sharedTheme] stationTableViewBackgroundImage]) {
    //        self.imageView.image = [[SSThemeManager sharedTheme] stationTableViewBackgroundImage]; //[UIImage imageNamed:@"lines_shadow.png"];
    //        [self.mytableView setBackgroundColor:[UIColor clearColor]];
    //    } else {
    //        self.imageView.image = nil;
    //        self.mytableView.backgroundColor= [[SSThemeManager sharedTheme] stationTableViewBackgroundColor];
    //    }
    


}

@end
