#version 440 core

in vec3 outNorm;
layout(location = 0) out vec4 FragColor;


layout(location = 3) uniform int fill;

void main()
{
    if(fill == 1){
        if(gl_FrontFacing){
            FragColor = vec4(outNorm*0.5 + 0.5, 0.8);
        } else {
            FragColor = vec4(0.2, 0.2, 0.2, 1.0);
        }
    } else {
        FragColor = vec4(1.0);
    }
    
    
    //FragColor = 0.5 + 0.5*dot(vec3(1, 1, -1),outNorm)*vec4(1.0, 1.0, 1.0, 1.0);
}