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


float noise2D( vec2 p ) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) *
                 43758.5453);
}




// Interpolate in 2 dimensions
float interpNoise2D(float x, float y) 
{
    int intX = int(floor(x));
    float fractX = fract(x);
    int intY = int(floor(y));
    float fractY = fract(y);

    float v1 = noise2D(vec2(intX, intY));
    float v2 = noise2D(vec2(intX + 1, intY));
    float v3 = noise2D(vec2(intX, intY + 1));
    float v4 = noise2D(vec2(intX + 1, intY + 1));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);
    return mix(i1, i2, fractY);
}


// 2D Fractal Brownian Motion
float fbm(float x, float y) 
{
    float total = 0.f;

    
    float persistence = 0.5f;
    int octaves = 8;

    for(int i = 1; i <= octaves; i++) 
    {
        float freq = pow(2.f, float(i));
        float amp = pow(persistence, float(i));

        total += interpNoise2D(x * freq,
                               y * freq) * amp;
    }
    
    total += interpNoise2D(x, y);

    return total;
}


void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0); //u_Color;

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

        // Output position
        out_Col = fs_Pos;



        float val = fbm(fs_Pos[0], fs_Pos[1]);

        out_Col = vec4(val, val, val, 1.0);
}

