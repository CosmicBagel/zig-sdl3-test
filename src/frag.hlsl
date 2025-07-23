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

    float pulse = sin(time * 2.0) * 0.5 + 0.5; // range [0, 1]
    output.color = input.color * pulse;

    return output;
}
