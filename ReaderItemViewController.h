//
//  ReaderItemViewController.h
//  tube
//
//  Created by Alexey on 16/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface ReaderItemViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *scrollPhotos;
    UITextView *textView;
    MPlace *place;
    NSInteger currentPage;

}

- (id)initWithPlaceObject:(MPlace*)_place;
- (NSInteger)currentPage;

@property (nonatomic, retain) MPlace *place;
@property (nonatomic, retain) NSArray *currentPhotos;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIImageView *separator;

@end
