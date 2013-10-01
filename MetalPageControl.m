//
//  MetalPageControl.m
//  tube
//
//  Created by sergey on 16.12.12.
//
//

#import "MetalPageControl.h"

@interface MetalPageControl (Private)
- (void) updateDots;
@end

@implementation MetalPageControl

@synthesize imageNormal = mImageNormal;
@synthesize imageCurrent = mImageCurrent;

- (void) dealloc
{
    [mImageNormal release], mImageNormal = nil;
    [mImageCurrent release], mImageCurrent = nil;
    
	[super dealloc];
}


/** override to update dots */
- (void) setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    
    // update dot views
    [self updateDots];
}

/** override to update dots */
- (void) setNumberOfPages:(NSInteger)number
{
    [super setNumberOfPages:number];
    
    // update dot views
    [self updateDots];
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
    [super updateCurrentPageDisplay];
    
    // update dot views
    [self updateDots];
}

/** Override setImageNormal */
- (void) setImageNormal:(UIImage*)image
{
    [mImageNormal release];
    mImageNormal = [image retain];
    
    // update dot views
    [self updateDots];
}

/** Override setImageCurrent */
- (void) setImageCurrent:(UIImage*)image
{
    [mImageCurrent release];
    mImageCurrent = [image retain];
    
    // update dot views
    [self updateDots];
}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self updateDots];
}

#pragma mark - (Private)

- (void) updateDots
{
    if(mImageCurrent || mImageNormal)
    {
        // Get subviews
        NSArray* dotViews = self.subviews ;
        
        for (int i = 0; i < dotViews.count; i++)
        {
            UIView* dotView = [self.subviews objectAtIndex:i];
            UIImageView* dot = nil;
            
            for (UIView* subview in dotView.subviews)
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    dot = (UIImageView*)subview;
                    break;
                }
            }
            
            if (dot == nil)
            {
                dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
                [dotView addSubview:dot];
            }
            
            dot.image = (i == self.currentPage) ? mImageCurrent : mImageNormal;        }
    }
}



@end

    
 