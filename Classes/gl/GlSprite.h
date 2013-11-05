//
//  GlSprite.h
//  tube
//
//  Created by Vasiliy Makarov on 26.10.12.
//
//

#import <Foundation/Foundation.h>

@interface TexCache : NSObject {
@public
    GLuint texID;
    NSInteger width, height, origWidth, origHeight;
    CGFloat mU, mV;
}

-(id)initWithTexID:(GLuint)tid width:(NSInteger)w height:(NSInteger)h originalWidth:(NSInteger)ow originalHeight:(NSInteger)oh mU:(CGFloat)u mV:(CGFloat)v;

@end

@interface GlSprite : NSObject {
    unsigned int gltex, vertexBuffer, width, height, owidth, oheight;
    float alpha, mU, mV;
    BOOL texCached;
}
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, readonly) unsigned int origWidth;
@property (nonatomic, readonly) unsigned int origHeight;
@property (nonatomic, assign) float alpha;

+(TexCache*)getTexture:(NSString*)textureName;
+(void)setTexture:(TexCache*)texCache forName:(NSString*)textureName;
-(id)initWithImage:(CGImageRef)image andRect:(CGRect)rect;
-(id)initWithPicture:(NSString*)pictureFile;
-(void) draw;
-(void)setRect:(CGRect)rect;
-(void)setRect:(CGRect)rect withRotation:(double)rotation;

@end
