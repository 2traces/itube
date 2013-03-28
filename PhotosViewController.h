//
//  PhotosViewController.h
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "Slide3DImageView.h"


@class Station;

@interface PhotosViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView *scrollPhotos;
    UIButton *buttonCategories;
    UIView *disappearingView;
    UIView *panelView;
    NSInteger currentPage;
    UILabel *placeNameHeader;
    UILabel *placeNamePanel;
    UILabel *placeDescriptionBg;
    UILabel *placeDescription;
    UIButton *btAddToFavorites;
    UIButton *btShowHideBookmarks;
    UILabel *distanceLabel;
    UIView *distanceContainer;
    UIButton *btPanel;
    UIImageView *directionImage;
    NSMutableArray *moviePlayers;
}

@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UIView *distanceContainer;
@property (nonatomic, retain) IBOutlet UILabel *placeNameHeader;
@property (nonatomic, retain) IBOutlet UILabel *placeNamePanel;
@property (nonatomic, retain) IBOutlet UILabel *placeDescriptionBg;
@property (nonatomic, retain) IBOutlet UILabel *placeDescription;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic, retain) IBOutlet UIButton *btAddToFavorites;
@property (nonatomic, retain) IBOutlet UIButton *buttonCategories;
@property (nonatomic, retain) IBOutlet UIButton *btShowHideBookmarks;
@property (nonatomic, retain) IBOutlet UIButton *btPanel;
@property (nonatomic, retain) IBOutlet UIView *disappearingView;
@property (nonatomic, retain) IBOutlet UIView *panelView;
@property (nonatomic, retain) IBOutlet UIImageView *directionImage;
@property (nonatomic, assign) id<NavigationDelegate> navigationDelegate;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) NSArray *currentPhotos;
@property (nonatomic, retain) NSMutableArray *moviePlayers;
@property (retain, nonatomic) IBOutlet UIButton *btSwitchMode;
@property (nonatomic, retain) IBOutlet UIView *upperPanel;
@property (nonatomic, retain) IBOutlet UIPanGestureRecognizer *upperPanGestureRecognizer;
@property (nonatomic, retain) Slide3DImageView *current3DView;

- (IBAction)showCategories:(id)sender;
- (IBAction)showHidePhotos:(id)sender;
- (IBAction)showBookmarks:(id)sender;
- (IBAction)switchMapMetro:(id)sender;
- (IBAction)addToFavorites:(id)sender;
- (IBAction)centerMapOnUser:(id)sender;
- (IBAction)handleUpperPan:(UIPanGestureRecognizer*)tapper;
- (void)updateInfoForCurrentPage;
- (Station*)stationForCurrentPhoto;
- (void)reloadScrollView;

- (void) loadPlaces:(NSArray*)places;

@end
