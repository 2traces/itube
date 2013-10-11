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

-(IBAction)searchButton:(UIButton*)sender;
-(IBAction)searchText:(UITextField*)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil glViewController:(GlViewController*)glViewController;
- (void) centerMapOnPlace:(MPlace*)place;


@property (nonatomic, retain) IBOutlet UIView *separatingView;
@property (nonatomic, retain) IBOutlet UIImageView *shadow;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) GlViewController *glController;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
