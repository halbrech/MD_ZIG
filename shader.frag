#version 440 core

in vec3 outNorm;
layout(location = 0) out vec4 FragColor;



void main()
{
    FragColor = vec4(outNorm*0.5 + 0.5, 1.0);
    //FragColor = 0.5 + 0.5*dot(vec3(1, 1, -1),outNorm)*vec4(1.0, 1.0, 1.0, 1.0);
}