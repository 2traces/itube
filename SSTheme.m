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
    [navigationBarAppearance setBackgroundColor:[UIColor blackColor]];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[theme highlightColor], UITextAttributeTextColor, [theme navigationTitleFont], UITextAttributeFont, [theme titleShadowColor],UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil];
    
    [navigationBarAppearance setTitleTextAttributes:textTitleOptions];
    
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    
#if defined(NEW_THEME)
    [barButtonItemAppearance setBackButtonBackgroundVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f) forBarMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsDefault];
  
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ( 6 >= [[vComp objectAtIndex:0] intValue] ) {
        // iOS-6 code and above 
        [barButtonItemAppearance setTitlePositionAdjustment:UIOffsetMake(0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    } else {        
        // iOS-5 code
        [barButtonItemAppearance setTitlePositionAdjustment:UIOffsetMake(0.0f, 3.0f) forBarMetrics:UIBarMetricsDefault];
    }
#else
    [navigationBarAppearance setTitleVerticalPositionAdjustment:4.0f forBarMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f) forBarMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setTitlePositionAdjustment:UIOffsetMake(0.0f, 5.0f) forBarMetrics:UIBarMetricsDefault];
#endif
    
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBorderedBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBorderedBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBorderedBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBorderedBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted  barMetrics:UIBarMetricsLandscapePhone];
    
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme titleShadowColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonPressedTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme titleShadowColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateDisabled];
    [barButtonItemAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[theme backButtonPressedTitleColor], UITextAttributeTextColor, [theme backbuttonTitleFont], UITextAttributeFont, [theme backButtonTitleColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset, nil] forState:UIControlStateHighlighted];
    
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
    } else if (backgroundColor) {
        [tableView setBackgroundView:nil];
        [tableView setBackgroundColor:backgroundColor];
    }
    
    imageView.image=[theme overlayShadowImage];
    searchBar.tintColor=[UIColor lightGrayColor];    
}

@end
