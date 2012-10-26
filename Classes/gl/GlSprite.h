//
//  GlSprite.h
//  tube
//
//  Created by Vasiliy Makarov on 26.10.12.
//
//

#import <Foundation/Foundation.h>

@interface GlSprite : NSObject {
    unsigned int gltex, vertexBuffer;
}

-(id)initWithImage:(CGImageRef)image andRect:(CGRect)rect;
-(id)initWithPicture:(NSString*)pictureFile;
-(void) draw;
-(void)setRect:(CGRect)rect;

@end
