//
//  render.metal
//  Cutter
//
//  Created by Гаджиев Казим on 25.01.2024.
//

#include <metal_stdlib>
using namespace metal;

// Структура для вершин
struct Vertex {
    float4 position [[position]];
    float2 textureCoordinate;
};

// Вершинный шейдер
vertex Vertex renderVertex(uint vertexID [[vertex_id]]) {
    float2 positions[4] = {
        float2(-1.0, -1.0),
        float2(-1.0, 1.0),
        float2(1.0, -1.0),
        float2(1.0, 1.0)
    };

    // Определяем, нужно ли применять поворот на 90 градусов
    float2 texCoords[4];
    texCoords[0] = float2(0.0, 1.0);
    texCoords[1] = float2(0.0, 0.0);
    texCoords[2] = float2(1.0, 1.0);
    texCoords[3] = float2(1.0, 0.0);

    Vertex out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.textureCoordinate = texCoords[vertexID];
    return out;
}

// Фрагментный шейдер
fragment half4 renderFragment(Vertex in [[stage_in]],
                              texture2d<half> texture [[texture(0)]],
                              sampler textureSampler [[sampler(0)]]) {
    half4 color = texture.sample(textureSampler, in.textureCoordinate);
    return color;
}
