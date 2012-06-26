//
//  GalleryFullscreenViewController.m
//  tube
//
//  Created by Alexey Starovoitov on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryFullscreenViewController.h"

@interface GalleryFullscreenViewController ()

@end

@implementation GalleryFullscreenViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize delegate;
@synthesize itemID;
@synthesize label;

- (IBAction)goBack:(id)sender {
    [delegate closeFullscreenItem];
}

- (IBAction)showOnMap:(id)sender {
    [delegate showItemOnMapWithID:itemID];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)title image:(UIImage*)image itemID:(NSInteger)itemId {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        itemID = itemId;
        self.imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        itemName = title;
    }
    return self;   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.minimumZoomScale = self.scrollView.frame.size.width / self.imageView.frame.size.width;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.contentSize = self.imageView.frame.size;
    [self.scrollView addSubview:self.imageView];

    self.scrollView.delegate = self;

    self.label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:17.0];
    self.label.text = itemName;
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
    self.scrollView.contentMode = (UIViewContentModeScaleAspectFit);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.frame = [self centeredFrameForScrollView:self.scrollView andUIView:self.imageView];                               
}

@end
