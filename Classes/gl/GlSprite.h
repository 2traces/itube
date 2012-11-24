//
//  GlSprite.h
//  tube
//
//  Created by Vasiliy Makarov on 26.10.12.
//
//

#import <Foundation/Foundation.h>

@interface GlSprite : NSObject {
    unsigned int gltex, vertexBuffer, width, height, owidth, oheight;
    float alpha, mU, mV;
}
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, readonly) unsigned int origWidth;
@property (nonatomic, readonly) unsigned int origHeight;
@property (nonatomic, assign) float alpha;

-(id)initWithImage:(CGImageRef)image andRect:(CGRect)rect;
-(id)initWithPicture:(NSString*)pictureFile;
-(void) draw;
-(void)setRect:(CGRect)rect;

@end
