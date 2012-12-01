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

+ (void)customizeDoorButton:(UIButton *)button
{
    id <SSTheme> theme = [SSThemeManager sharedTheme];
}

@end
