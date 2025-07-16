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
    output.color = input.color;

    return output;
}
