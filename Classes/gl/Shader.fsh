//
//  Shader.fsh
//  test
//
//  Created by Vasiliy Makarov on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 textureUV;

uniform sampler2D sampler;

void main()
{
    gl_FragColor = colorVarying * texture2D(sampler, textureUV);
}
