#version 440 core

in vec3 fragPos;
in vec3 fragNorm;

layout(location = 0) out vec4 FragColor;

layout(location = 3) uniform int mode;
layout(location = 4) uniform vec3 color;

layout(location = 5) uniform vec3 viewPos;

vec3 lightPos = vec3(3.0, 3.0, 0.0);
vec3 lightColor = vec3(1.0, 0.0, 0.0);

bool closeToStep(vec3 v, float interval) {
    vec3 sc = v/interval;
    if(min(min(abs(sc.x) - abs(trunc(sc.x)), abs(sc.y) - abs(trunc(sc.y))), abs(sc.z) - abs(trunc(sc.z))) < 0.05) return true;
    // if(distance(v/interval, trunc(v/interval)) < 0.1) return true;
    // if(abs(v/interval) - abs(trunc(v/interval)) < 0.01) return true;
    return false;
}

void main()
{
    if(mode == 0) { // main coloring (Blinn-Phong)
        vec3 norm = normalize(fragNorm);
        if(!gl_FrontFacing)
            norm = -norm;

        float ambientStrength = 0.2;
        vec3 ambient = ambientStrength * lightColor;


        vec3 lightDir = normalize(lightPos - fragPos);
        vec3 viewDir = normalize(viewPos - fragPos);
        vec3 reflectDir = reflect(-lightDir, norm);
        vec3 halfway = normalize(lightDir + viewDir);

        float diffuseStrength = 0.3;
        float diff = max(dot(norm, lightDir), 0.0);
        vec3 diffuse = diffuseStrength * diff * lightColor;

        float specularStrength = 1.0;
        float spec = pow(max(dot(norm, halfway), 0.0), 256.0); // last: shininess
        vec3 specular = specularStrength * spec * lightColor;

        FragColor = vec4(ambient + diffuse + specular, 1.0);
    
    } else if(mode == 1){ // debug front face
        if(gl_FrontFacing){
            if(closeToStep(fragPos, 0.1)) {
            // if(closeToStep(fragPos.x, 0.1) || closeToStep(fragPos.y, 0.1) || closeToStep(fragPos.z, 0.1)){
                FragColor = vec4(0.1, 0.1, 0.1, 1.0);
            }
            else {
                FragColor = vec4(fragNorm*0.5 + 0.5, 1.0);
            }
        } else {
            FragColor = vec4(0.2, 0.2, 0.2, 1.0);
        }
    } else { // debug back face
        FragColor = vec4(1.0);
    }
    
    
    //FragColor = 0.5 + 0.5*dot(vec3(1, 1, -1),outNorm)*vec4(1.0, 1.0, 1.0, 1.0);
}