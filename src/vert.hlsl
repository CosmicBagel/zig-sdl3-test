struct VertexInput
{
    float3 position : POSITION;
    float3 scale: SCALE;
    float4 rotation: ROTATION;
    float4 color: COLOR;
};

struct VertexOutput
{
    float4 position : SV_Position;
    float4 color: COLOR;
};

VertexOutput vert_shader(VertexInput input) {
    VertexOutput output;
    output.position = float4(input.position, 1.0);
    output.color = input.color;

    return output;
}
