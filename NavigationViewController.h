//
//  NavigationViewController.h
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "GlViewController.h"

@class GlViewController;
@class SuggestionsViewController;
@class DownloadMapViewController;

@protocol NavigationDelegate <NSObject>

- (void) showCategories:(id)sender;
- (void) showRasterMap;
- (CGFloat) selectPlaceWithIndex:(NSInteger)index;
- (CGFloat) radialDirectionOffsetToPlaceWithIndex:(NSInteger)index;
- (void) showSettings;
- (BOOL) categoriesOpen;
- (void) centerMapOnUser;
- (void) showPurchases:(int)index;

@end

typedef enum {
    HCOSMLayer
} HCLayerMode;

@interface NavigationViewController : UIViewController <NavigationDelegate> {
    GlViewController *glController;
    UIView *separatingView;
    BOOL categoriesOpen;
    HCLayerMode layerMode;
    NSInteger currentPlacePin;
    UIImageView *shadow;

    CGRect rectMapFull, rectMapCut;
    
    BOOL returningFromLandscape; //another freaking dummy flag to keep old and new UI consistent and synchronized...
}

-(IBAction)doneSearching:(UITextField *)sender;
-(IBAction)searchButton:(UIButton*)sender;
-(IBAction)searchText:(UITextField*)sender;
-(IBAction)showSpotsList:(id)sender;
-(IBAction)distanceTapped:(id)sender;
-(IBAction)downloadOfflineMap:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil glViewController:(GlViewController*)glViewController;
- (void) centerMapOnPlace:(MPlace*)place;
- (void) endedSearching;

@property (nonatomic, retain) IBOutlet UITextField *suggestionField;
@property (nonatomic, retain) IBOutlet UIView *separatingView;
@property (nonatomic, retain) IBOutlet UIView *distanceView;
@property (nonatomic, retain) IBOutlet UIView *headingView;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UIButton *listButton;
@property (nonatomic, retain) IBOutlet UIButton *listSplitButton;
@property (nonatomic, retain) IBOutlet UIButton *downloadButton;
@property (nonatomic, retain) IBOutlet UIImageView *distanceBg;
@property (nonatomic, retain) IBOutlet UIImageView *directionArrow;
@property (nonatomic, retain) IBOutlet UIImageView *shadow;
@property (nonatomic, retain) IBOutlet UIImageView *headingBg;
@property (nonatomic, retain) IBOutlet UIImageView *textBg;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) GlViewController *glController;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) SuggestionsViewController *suggestionsVC;
@property (nonatomic, retain) DownloadMapViewController *downloadVC;

@end
