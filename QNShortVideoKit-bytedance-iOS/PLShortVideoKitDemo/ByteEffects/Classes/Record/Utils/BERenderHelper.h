// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_public_define.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>

typedef struct be_rgba_color {
    float red;
    float green;
    float blue;
    float alpha;
}be_rgba_color;

typedef struct be_render_helper_line {
    float x1;
    float y1;
    float x2;
    float y2;
} be_render_helper_line;

@interface BERenderHelper : NSObject

- (void)setViewWidth:(int)iWidth height:(int)iHeight;
- (void)setResizeRatio:(float)ratio;

- (void) drawRect:(bef_ai_rect*)rect withColor:(be_rgba_color)color lineWidth:(float)lineWidth;

- (void) drawLines:(bef_ai_fpoint*) lines withCount:(int)count withColor:(be_rgba_color)color lineWidth:(float)lineWidth;

- (void) drawLinesStrip:(bef_ai_fpoint*) lines withCount:(int)count withColor:(be_rgba_color)color lineWidth:(float)lineWidth;

- (void) drawLine:(be_render_helper_line*)line withColor:(be_rgba_color)color lineWidth:(float)lineWidth;

- (void) drawPoint:(int)x y:(int)y withColor:(be_rgba_color)color pointSize:(float)pointSize;
- (void) drawPoints:(bef_ai_fpoint*)points count:(int)count color:(be_rgba_color)color pointSize:(float)pointSize;

- (void)drawTexture:(GLuint)texture;

- (void) drawMask:(unsigned char*)mask withColor:(be_rgba_color)color currentTexture:(GLuint)texture frameBuffer:(GLuint)frameBuffer size:(int*)size;
- (void) drawPortraitMask:(unsigned char*)mask withColor:(be_rgba_color)color currentTexture:(GLuint)texture frameBuffer:(GLuint)frameBuffer size:(int*)size;

- (void) textureToImage:(GLuint)texture withBuffer:(unsigned char*)buffer Width:(int)rWidth height:(int)rHeight;

+ (int) compileShader:(NSString *)shaderString withType:(GLenum)shaderType;
@end

