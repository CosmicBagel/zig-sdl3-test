struct VertexInput
{
    float3 position : POSITION;
    float4 color: COLOR;
};

[[vk::binding(0, 3)]]
cbuffer VertexUniform : register(b0, space3)
{
    float2 world_position;
    float2 scale;
    float rotation;
};

struct VertexOutput
{
    float4 position : SV_Position;
    float4 color: COLOR;
};

VertexOutput vert_shader(VertexInput input) {
    VertexOutput output;

    float c = cos(rotation);
    float s = sin(rotation);
    float2x2 rot_matrix = {c, s, 
                           -s, c};
    float2 rotated_pos = mul(rot_matrix, input.position.xy);

    float2 scaled_pos = rotated_pos * scale;

    output.position = float4(scaled_pos.xy, input.position.z, 1.0) + float4(world_position, 0.0, 0.0);

    //output.position = float4(rotated_pos.xy, input.position.z, 1.0);
    output.color = input.color;

    return output;
}
