//
//  Slide3DImageView.h
//  tube
//
//  Created by alex on 22.03.13.
//
//

#import <UIKit/UIKit.h>

@interface Slide3DImageView : UIView

@property int currentSlideNumber;
@property int slidesCount;
@property int lastTranslation;
@property (retain) NSString *photosPrefix;
@property (retain) NSString *photosExt;
@property (retain) UIPanGestureRecognizer *panGR;
@property (retain) UITapGestureRecognizer *tapGR;
@property (retain) UIImageView *mainImageView;

- (id)initWithImage:(UIImage *)image withFrame:(CGRect)frame withPrefix:(NSString*)prefix withExt:(NSString*)ext withSlidesCount:(int)count;
- (void) handleRotation:(UIPanGestureRecognizer *)recognizer;
- (void) handleTap:(UITapGestureRecognizer *)recognizer;
    
@end
