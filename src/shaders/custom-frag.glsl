#version 300 es

// Custom Fragment Shader

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// Interpolated values out of the rasterizer
in vec4 fs_Pos;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; 


vec3 noise3D( vec3 p ) 
{
    float val1 = fract(sin((dot(p, vec3(127.1, 311.7, 191.999)))) * 43758.5453);

    float val2 = fract(sin((dot(p, vec3(191.999, 127.1, 311.7)))) * 3758.5453);

    float val3 = fract(sin((dot(p, vec3(311.7, 191.999, 127.1)))) * 758.5453);

    return vec3(val1, val2, val3);
}


// Interpolate in 3 dimensions
vec3 interpNoise3D(float x, float y, float z) 
{

    
    int intX = int(floor(x));
    float fractX = fract(x);
    int intY = int(floor(y));
    float fractY = fract(y);
    int intZ = int(floor(z));
    float fractZ = fract(z);

    vec3 v1 = noise3D(vec3(intX, intY, intZ));
    vec3 v2 = noise3D(vec3(intX + 1, intY, intZ));
    vec3 v3 = noise3D(vec3(intX, intY + 1, intZ));
    vec3 v4 = noise3D(vec3(intX + 1, intY + 1, intZ));

    vec3 v5 = noise3D(vec3(intX, intY, intZ + 1));
    vec3 v6 = noise3D(vec3(intX + 1, intY, intZ + 1));
    vec3 v7 = noise3D(vec3(intX, intY + 1, intZ + 1));
    vec3 v8 = noise3D(vec3(intX + 1, intY + 1, intZ + 1));

    vec3 i1 = mix(v1, v2, fractX);
    vec3 i2 = mix(v3, v4, fractX);

    vec3 i3 = mix(i1, i2, fractY);

    vec3 i4 = mix(v5, v6, fractX);
    vec3 i5 = mix(v7, v8, fractX);

    vec3 i6 = mix(i4, i5, fractY);

    vec3 i7 = mix(i3, i6, fractZ);

    return i7;

}


// 3D Fractal Brownian Motion
vec3 fbm(float x, float y, float z) 
{
    vec3 total = vec3(0.f, 0.f, 0.f);

    
    float persistence = 0.5f;
    int octaves = 8;

    for(int i = 1; i <= octaves; i++) 
    {
        float freq = pow(2.f, float(i));
        float amp = pow(persistence, float(i));

        total += interpNoise3D(x * freq, y * freq, z * freq) * amp;
    }
    
    return total;
}


void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

        vec3 val = fbm(fs_Pos[0], fs_Pos[1], fs_Pos[2]);

        out_Col += vec4(val, 1.0) / 2.0;

        out_Col /= ((val[0] + val[1] + val[2]) / 3.0);
}

