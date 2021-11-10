#version 440 core
layout(location = 0) in vec3 pos;

layout(location = 0) uniform mat4 view;
layout(location = 1) uniform mat4 proj;
// layout(location = 0) uniform vec3 color;

void main()
{
    gl_Position = proj * view * vec4(pos.xyz, 1.0);
}