//
//  Slide3DImageView.h
//  tube
//
//  Created by alex on 22.03.13.
//
//

#import <UIKit/UIKit.h>

@interface Slide3DImageView : UIImageView

@property int currentSlideNumber;
@property int slidesCount;
@property int lastTranslation;
@property (retain) NSString *photosPrefix;
@property (retain) NSString *photosExt;

- (id)initWithImage:(UIImage *)image withPrefix:(NSString*)prefix withExt:(NSString*)ext withSlidesCount:(int)count;
- (void) handleRotation:(UIPanGestureRecognizer *)recognizer;
    
@end
