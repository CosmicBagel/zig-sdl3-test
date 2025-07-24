cbuffer TimeCB : register(b0, space3)
{
    float time : packoffset(c0);
};

struct FragInput
{
    float4 color: COLOR;
};

struct FragOutput
{
    float4 color: COLOR;
};

FragOutput frag_shader(FragInput input) {
    FragOutput output;

    const float pi = 3.141592653589793238462643383279502884;
    output.color.r = 0.5 + 0.5 * sin(time + pi * input.color.r);
    output.color.g = 0.5 + 0.5 * sin(time + pi * (2/3 + input.color.g));
    output.color.b = 0.5 + 0.5 * sin(time + pi * (4/3 + input.color.b));
    output.color.a = input.color.r * 1/3 + input.color.g * 1/3 + input.color.b * 1/3;

    return output;
}
