#version 440 core
// layout(location = 0) in vec3 pos;

// layout(location = 0) uniform mat4 view;
layout(location = 2) uniform vec3 color;

out vec4 FragColor;

void main()
{
    FragColor = vec4(color, 1.0);
}