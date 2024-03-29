//
//  Shader.vsh
//  test
//
//  Created by Vasiliy Makarov on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;
attribute vec2 uv;

varying lowp vec4 colorVarying;
varying lowp vec2 textureUV;

uniform mat4 modelViewProjectionMatrix;
//uniform mat3 normalMatrix;
uniform sampler2D sampler;
uniform vec4 color;

void main()
{
//    vec3 eyeNormal = normalize(normalMatrix * normal);
//    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
//    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
    
//    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = color;// * nDotVP;
    textureUV = uv;
    
    gl_Position = modelViewProjectionMatrix * position;
}
