#version 440 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 norm;

out vec3 outNorm;

layout(location = 0) uniform mat4 model;
layout(location = 1) uniform mat4 view;
layout(location = 2) uniform mat4 proj;

void main()
{
    outNorm = norm;
    gl_Position = proj * view * model * vec4(pos.xyz, 1.0);
}
