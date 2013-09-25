//
//  NavigationViewController.h
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "GlViewController.h"

@class CategoriesViewController;
@class GlViewController;
@class HCBookmarksViewController;
@class ReaderViewController;

@protocol NavigationDelegate <NSObject>

- (void) showCategories:(id)sender;
- (void) showBookmarks:(id)sender;
- (void) showRasterMap;
- (void) showBookmarksLayer;
- (void) hideBookmarksLayer;
- (void) showReaderWithItems:(NSArray*)items activePage:(NSInteger)activePage;
- (void) selectCategoryWithIndex:(NSInteger)index;
- (CGFloat) selectPlaceWithIndex:(NSInteger)index;
- (CGFloat) radialDirectionOffsetToPlaceWithIndex:(NSInteger)index;
- (void) showSettings;
- (BOOL) categoriesOpen;
- (void) centerMapOnUser;
- (void) reloadCategories;
- (void) showPurchases:(int)index;

@end

typedef enum {
    HCOSMLayer,
    HCBookmarksLayer,
} HCLayerMode;

@interface NavigationViewController : UIViewController <NavigationDelegate> {
    CategoriesViewController *categoriesController;
    HCBookmarksViewController *bookmarksController;
    ReaderViewController *readerController;
    GlViewController *glController;
    UIView *separatingView;
    BOOL categoriesOpen;
    HCLayerMode layerMode;
    NSInteger currentPlacePin;
    UIImageView *shadow;

    CGRect rectMapFull, rectMapCut;
    
    BOOL returningFromLandscape; //another freaking dummy flag to keep old and new UI consistent and synchronized...
}

-(IBAction)searchButton:(UIButton*)sender;
-(IBAction)searchText:(UITextField*)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil glViewController:(GlViewController*)glViewController;

- (void)transitToPathMode;
- (void)transitToNormalMode;

- (void) centerMapOnPlace:(MPlace*)place;


@property (nonatomic, retain) IBOutlet UIView *separatingView;
@property (nonatomic, retain) IBOutlet UIImageView *shadow;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) CategoriesViewController *categoriesController;
@property (nonatomic, retain) ReaderViewController *readerController;
@property (nonatomic, retain) HCBookmarksViewController *bookmarksController;
@property (nonatomic, retain) GlViewController *glController;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
