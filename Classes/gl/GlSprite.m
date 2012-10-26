//
//  GlSprite.m
//  tube
//
//  Created by Vasiliy Makarov on 26.10.12.
//
//

#import "GlSprite.h"
#import <GLKit/GLKit.h>
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GlSprite

-(id)initWithPicture:(NSString *)pictureFile
{
    if((self = [super init])) {
        UIImage *img = [UIImage imageNamed:pictureFile];
        CGImageRef image = [img CGImage];

        size_t width = CGImageGetWidth(image);
        size_t height = CGImageGetHeight(image);
        GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                           CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
        CGContextRelease(spriteContext);
        
        glGenTextures(1, &gltex);
        glBindTexture(GL_TEXTURE_2D, gltex);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        
        free(spriteData);

        glGenBuffers(1, &vertexBuffer);
    }
    return self;
}

-(id)initWithImage:(CGImageRef)image andRect:(CGRect)rect
{
    if((self = [super init])) {
        size_t width = CGImageGetWidth(image);
        size_t height = CGImageGetHeight(image);
        GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                           CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
        CGContextRelease(spriteContext);
        
        glGenTextures(1, &gltex);
        glBindTexture(GL_TEXTURE_2D, gltex);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        
        free(spriteData);
        
        //coords = (float*)calloc(4*4, sizeof(float));
        //uv = (float*)calloc(4*4, sizeof(float));
        int bufSize = (3*4 + 2*4) * sizeof(float);
        float *buf = (float*)calloc(bufSize, 1);
        
        buf[0] = rect.origin.x;
        buf[1] = rect.origin.y;
        buf[2] = 0.f; //z
        buf[3] = 0.f; //u
        buf[4] = 0.f; //v
        buf[5] = rect.origin.x+rect.size.width;
        buf[6] = rect.origin.y;
        buf[7] = 0.f; //z
        buf[8] = 1.f; //u
        buf[9] = 0.f; //v
        buf[10] = rect.origin.x;
        buf[11] = rect.origin.y+rect.size.height;
        buf[12] = 0.f; //z
        buf[13] = 0.f; //u
        buf[14] = 1.f; //v
        buf[15] = rect.origin.x+rect.size.width;
        buf[16] = rect.origin.y+rect.size.height;
        buf[17] = 0.f; //z
        buf[18] = 1.f; //u
        buf[19] = 1.f; //v
        
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, bufSize, buf, GL_STATIC_DRAW);
        
        free(buf);
    }
    return self;
}

-(void)dealloc
{
    if(vertexBuffer != 0) glDeleteBuffers(1, &vertexBuffer);
    if(gltex != 0) glDeleteTextures(1, &gltex);
    //if(image) CGImageRelease(image);
    [super dealloc];
}

-(void)setRect:(CGRect)rect
{
    int bufSize = (3*4 + 2*4) * sizeof(float);
    float *buf = (float*)calloc(bufSize, 1);
    
    buf[0] = rect.origin.x;
    buf[1] = rect.origin.y;
    buf[2] = 0.f; //z
    buf[3] = 0.f; //u
    buf[4] = 0.f; //v
    buf[5] = rect.origin.x+rect.size.width;
    buf[6] = rect.origin.y;
    buf[7] = 0.f; //z
    buf[8] = 1.f; //u
    buf[9] = 0.f; //v
    buf[10] = rect.origin.x;
    buf[11] = rect.origin.y+rect.size.height;
    buf[12] = 0.f; //z
    buf[13] = 0.f; //u
    buf[14] = 1.f; //v
    buf[15] = rect.origin.x+rect.size.width;
    buf[16] = rect.origin.y+rect.size.height;
    buf[17] = 0.f; //z
    buf[18] = 1.f; //u
    buf[19] = 1.f; //v

    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, bufSize, buf, GL_STATIC_DRAW);
    free(buf);
}

-(void) draw
{
    glColor4f(1.f, 1.f, 1.f, 1.f);
    glActiveTexture( GL_TEXTURE0 );
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, gltex);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(12));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}



@end
