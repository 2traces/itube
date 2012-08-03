//
//  GalleryViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "ManagedObjects.h"
#import <QuartzCore/QuartzCore.h>
#import "GalleryItemView.h"
#import "GalleryFullscreenViewController.h"
#import "tubeAppDelegate.h"
#import "MainViewController.h"
#import "MainView.h"
#import "tubeAppDelegate.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController

@synthesize label;
@synthesize scrollView;
@synthesize loadingView;
@synthesize lowerShadowImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initPhotos];
    }
    return self;
}

- (void)initPhotos {
    NSMutableArray *tempItems = [NSMutableArray arrayWithCapacity:15];
    images = [[[MHelper sharedHelper] getPhotoList] retain];

    CGFloat offset = 0;
    NSInteger index = 0;
    for (MPhoto *photo in images) {
        
        GalleryItemView *view = [[GalleryItemView alloc] init];
        
        tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *mapName = [appDelegate nameCurrentMap];
        
        NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"vector" ofType:nil inDirectory:[NSString stringWithFormat:@"maps/%@", mapName]];
        NSString *fn = [NSString stringWithFormat:@"%@/photos/%@", rasterPath, photo.fileName];
        UIImage *image = [UIImage imageWithContentsOfFile:fn];
        
        view.imageView = [[UIImageView alloc] initWithImage:image];
        
        //The easiest way to set a border is to do that with UIImageView, but in
        //this case we will need to adjust its height/width manually, to fit in
        //gallery item view
        [view.imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
        [view.imageView.layer setBorderWidth: 3.0];
        
        view.itemID = index;
        view.delegate = self;
        
        CGRect frame = view.frame;
        frame.origin.x = offset;
        frame.origin.y = 3.0f;
        frame.size.width = 170.0f;
        frame.size.height = 140.0f;
        view.frame = frame;
        
        frame = view.imageView.frame;
        CGFloat aspectToFit = (frame.size.height > frame.size.width) ?
        frame.size.height / view.frame.size.height : frame.size.width / view.frame.size.width;
        
        frame.size.height = frame.size.height / aspectToFit;
        frame.size.width = frame.size.width / aspectToFit;
        
        view.imageView.frame = frame;
        
        [view setOriginalImageSize:view.imageView.frame.size];
        [view centerImage];
        [view addSubview:view.imageView];
        
        offset += self.scrollView.frame.size.width;
        index++;
        
        UIImage *shadow = [UIImage imageNamed:@"gallery_item_shadow.png"];
        view.shadowView = [[UIImageView alloc] initWithImage:shadow];
        CGRect shadowFrame = view.shadowView.frame;
        view.shadowView.contentMode = UIViewContentModeScaleToFill;
        shadowFrame.size.width = frame.size.width;
        shadowFrame.origin.x = frame.origin.x;
        shadowFrame.origin.y = frame.origin.y + frame.size.height;
        view.shadowView.frame = shadowFrame;
        [view addSubview:view.shadowView];
        
        [view.imageView autorelease];
        [tempItems addObject:view];
        [view autorelease];
    }
    
    galleryItems = [[NSArray arrayWithArray:tempItems] retain];
}

- (void)setupScrollView {
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [images count], self.scrollView.frame.size.height-2.0f);
    self.scrollView.pagingEnabled = YES;
    CGFloat offset = 0;

    for (GalleryItemView *view in galleryItems) {
        CGRect frame = view.frame;
        frame.origin.x = offset;
        frame.origin.y = 3.0f;
        frame.size.width = 170.0f;
        frame.size.height = 140.0f;
        view.frame = frame;
        
        offset += self.scrollView.frame.size.width;

        [self.scrollView addSubview:view];

    }
    [self scrollViewDidScroll:self.scrollView];
    [self scrollViewDidEndDecelerating:self.scrollView];
    self.loadingView.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16.0f];
    self.label.text = @"";
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    //self.loadingView.hidden = NO;
    [UIView commitAnimations];
    [self setupScrollView];
    //[self performSelectorInBackground:@selector(setupScrollView) withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [images release];
    images = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
    CGFloat pageWidth = _scrollView.frame.size.width;
    currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    for (UIView *subview in [_scrollView subviews]) {
        if ([subview isKindOfClass:[GalleryItemView class]]) {
            CGFloat delta = _scrollView.contentOffset.x - subview.frame.origin.x;
            CGFloat percent = delta/ (_scrollView.frame.size.width*3.0f);
            
            if (percent < 0) {
                percent = -percent;
            }
            
            percent = 1 - percent;
                    
            CGRect frame = ((GalleryItemView*)subview).imageView.frame;
            CGSize imageSize = [(GalleryItemView*)subview originalImageSize];
            frame.size = CGSizeMake(imageSize.width*percent, imageSize.height*percent);
            ((GalleryItemView*)subview).imageView.frame = frame;
            
            frame = ((GalleryItemView*)subview).shadowView.frame;
            
            frame.size.width = imageSize.width*percent;
            ((GalleryItemView*)subview).shadowView.frame = frame;
            
            
            [(GalleryItemView*)subview centerImage];
            
            
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    MPhoto *photo = [images objectAtIndex:currentPage];

    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    MainView* mainView = (MainView*)appDelegate.mainViewController.view;    

    CGFloat distance = [mainView distanceToItemWithID:[photo.theItem.index integerValue]];
    [mainView centerGalleryShiftedMapOnItemWithID:[photo.theItem.index integerValue]];

    [mainView removePin:activePin];
    activePin = [appDelegate.mainViewController setPinForItem:[photo.theItem.index integerValue]];    
    
    //[mainView shiftMapForGalleryView];
    
    self.label.text = [NSString stringWithFormat:@"%@, ~ %i km", photo.theItem.name, (int)distance];
}

- (void)bookmarkItemWithID:(NSInteger)itemID {
    MPhoto *photo = [images objectAtIndex:itemID];
    MItem *item = photo.theItem;
    [item setIsFavorite:[NSNumber numberWithInt:1]];
    
    UIImageView *bookmarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gallery_bookmark.png"]];
    
    for (GalleryItemView *view in galleryItems) {
        if (view.itemID == itemID) {
            [view showBookmarkImage];
        }
    }
    
}

- (void)showFullscreenItemWithID:(NSInteger)itemID {

    
    MPhoto *photo = [images objectAtIndex:itemID];
    
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *mapName = [appDelegate nameCurrentMap];
    
    NSString *rasterPath = [[NSBundle mainBundle] pathForResource:@"vector" ofType:nil inDirectory:[NSString stringWithFormat:@"maps/%@", mapName]];    NSString *fn = [NSString stringWithFormat:@"%@/photos/%@", rasterPath, photo.fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:fn];
    
    GalleryFullscreenViewController *vc = [[GalleryFullscreenViewController alloc] initWithNibName:@"GalleryFullscreenViewController" bundle:[NSBundle mainBundle] title:photo.theItem.name image:image itemID:itemID];
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.delegate = self;
    vc.itemID = itemID;
    
    [appDelegate.mainViewController presentModalViewController:vc animated:YES];
    
    [vc autorelease];
}

- (void)showItemOnMapWithID:(NSInteger)itemID {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MPhoto *photo = [images objectAtIndex:itemID];
    
    [appDelegate.mainViewController returnFromSelection:[NSArray arrayWithObject:photo.theItem]];
}

- (void)closeFullscreenItem {
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.mainViewController dismissModalViewControllerAnimated:YES];
}


@end
