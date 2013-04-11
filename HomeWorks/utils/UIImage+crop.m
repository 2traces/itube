//
// Created by bsideup on 4/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIImage+crop.h"


@implementation UIImage (crop)

- (UIImage *)crop:(CGRect)rect {
	if (self.scale > 1.0f) {
		rect = CGRectMake(rect.origin.x * self.scale,
				rect.origin.y * self.scale,
				rect.size.width * self.scale,
				rect.size.height * self.scale);
	}

	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
	UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
	CGImageRelease(imageRef);
	return result;
}

@end