#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SSThemeTab) {
    SSThemeTabDoor,
    SSThemeTabPower,
    SSThemeTabControls,
};

@protocol SSTheme <NSObject>

- (UIColor *)mainColor;
- (UIColor *)highlightColor;
- (UIColor *)shadowColor;
- (UIColor *)backgroundColor;

- (UIColor *)baseTintColor;
- (UIColor *)accentTintColor;

- (UIColor *)switchThumbColor;
- (UIColor *)switchOnColor;
- (UIColor *)switchTintColor;

- (CGSize)shadowOffset;

- (UIImage *)topShadow;
- (UIImage *)bottomShadow;

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;
- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

- (UIImage *)toolbarBackgroundForBarMetrics:(UIBarMetrics)metrics;

- (UIImage *)searchBackground;
- (UIImage *)searchFieldImage;
- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state;
- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state;
- (UIImage *)searchScopeButtonDivider;

- (UIImage *)segmentedBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)segmentedDividerForBarMetrics:(UIBarMetrics)barMetrics;

- (UIImage *)tableBackground;

- (UIImage *)onSwitchImage;
- (UIImage *)offSwitchImage;

- (UIImage *)progressTrackImage;
- (UIImage *)progressProgressImage;

- (UIImage *)tabBarBackground;
- (UIImage *)tabBarSelectionIndicator;

// One of these must return a non-nil image for each tab:
- (UIImage *)imageForTab:(SSThemeTab)tab;
- (UIImage *)finishedImageForTab:(SSThemeTab)tab selected:(BOOL)selected;

//Soj

-(UIFont *)fontForDemoMapView;
-(UIImage *)demoMapViewBackgroundImage;
-(UIColor *)demoMapViewBackgroundColor;
-(UIFont *)navigationTitleFont;
-(UIFont *)backbuttonTitleFont;
-(UIFont*)settingsTableViewFont;
- (UIColor *)backButtonTitleColor;
- (UIColor *)backButtonPressedTitleColor;
- (UIImage *)buttonBackgroundForState:(UIControlState)state;
//-(UIFont*)fontForDemoBuyButton;
- (UIImage *)firstAndLastCellSettingsTableImageNormal;
- (UIImage *)firstAndLastCellSettingsTableImageHighlighted;
- (UIImage *)firstCellSettingsTableImageNormal;
- (UIImage *)firstCellSettingsTableImageHighlighted;
- (UIImage *)lastCellSettingsTableImageNormal;
- (UIImage *)lastCellSettingsTableImageHighlighted;
- (UIImage *)middleCellSettingsTableImageNormal;
- (UIImage *)middleCellSettingsTableImageHighlighted;

- (CGFloat)widthSettingsCellTableView;
- (UIColor*)titleShadowColor;

- (UIImage *)buybuttonBackgroundForState:(UIControlState)state;
- (UIImage *)greenbuttonBackgroundForState:(UIControlState)state;
- (UIImage *)bluebuttonBackgroundForState:(UIControlState)state;

-(UIColor *)buyButtonFontColorInstalled;
-(UIColor *)buyButtonFontColorAvailable;
-(UIFont *)buyButtonFont;

-(UIImage *)stationTextFieldBackgroung;
-(UIImage *)stationTextFieldBackgroungHighlighted;
-(UIImage *)stationTextFieldRightImageNormal;
-(UIImage *)stationTextFieldRightImageHighlighted;

-(UIImage*)topToolbarBackgroundImage;
-(UIImage*)topToolbarBackgroundPathImage;
-(CGFloat)topToolbarHeight:(UIBarMetrics)metrics;
-(CGFloat)toolbarFieldHeight;
-(CGFloat)toolbarFieldDelta;
-(UIImage*)topToolbarCrossImage:(UIControlState)state;
-(UIImage*)topToolbarArrowPathImage;
-(CGFloat)pathViewHeight:UIBarMetricsDefault;
-(CGFloat)topToolbarPathHeight:UIBarMetricsDefault;

-(UIImage*)mapViewSettingsButton:(UIControlState)state;
-(UIImage*)mapViewEntryButton:(UIControlState)state;
-(UIImage*)mapViewExitButton:(UIControlState)state;
-(UIImage*)mapViewLabelView;

-(UIFont*)toolbarPathFont;
-(UIColor*)toolbarPathFontColor;

-(void)decorMapViewMainLabel:(UILabel*)label;
-(void)decorMapViewLineLabel:(UILabel*)label;
-(void)decorMapViewCircleLabel:(UIView*)label;

-(UIImage*)horizontalPathViewBackground;
-(CGRect)horizontalPathViewRect;
-(CGFloat)horizontalPathSwitchButtonY;

-(CGFloat)stationTextFieldRightAdjust;
-(CGFloat)stationTextFieldDrawTextInRectAdjust;
-(BOOL)isNewTheme;

-(CGFloat)pathBarViewWidth;
-(UIImage*)pathBarViewDestinationIcon;
-(UIImage*)switchButtonImage:(UIControlState)state;

-(UIImage*)vertScrollViewBackground;

@end

@interface SSThemeManager : NSObject

+ (id <SSTheme>)sharedTheme;

+ (void)customizeAppAppearance;
+ (void)customizeView:(UIView *)view;
+ (void)customizeTableView:(UITableView *)tableView;
+ (void)customizeTabBarItem:(UITabBarItem *)item forTab:(SSThemeTab)tab;

@end
