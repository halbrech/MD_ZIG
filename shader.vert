#version 440 core

layout(location = 0) in dvec3 pos;
// layout(location = 1) in vec3 norm;

// layout(location = 0) uniform mat4 model;
// layout(location = 1) uniform mat4 view;
// layout(location = 2) uniform mat4 proj;


void main()
{
    // gl_Position = proj * view * model * vec4(pos.xyz, 1.0);
    gl_Position = vec4(pos.xyz, 1.0);
}
