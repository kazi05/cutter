//
//  process.metal
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

#include <metal_stdlib>
using namespace metal;

struct RenderParameters {
    bool convertToBGRA;
    bool shouldRotate;
};

kernel void bg_erase(texture2d<float, access::read>  inputTexture  [[ texture(0) ]],
                     texture2d<float, access::read>  maskTexture   [[ texture(1) ]],
                     texture2d<float, access::write> outputTexture [[ texture(2) ]],
                     constant RenderParameters& params [[buffer(0)]],
                     uint2 gid [[ thread_position_in_grid ]]) {
    // Чтение и применение маски аналогично, с использованием адаптированных координат rotatedGid
    float4 color = inputTexture.read(gid);
    float4 maskColor = maskTexture.read(gid);

    if (maskColor.r > 0.4f) {
        if (params.convertToBGRA) {
            outputTexture.write(float4(color.b, color.g, color.r, color.a), gid);
        } else {
            outputTexture.write(color, gid);
        }
    } else {
        outputTexture.write(float4(0.0, 1.0, 0.0, 1.0), gid); // Записываем прозрачный цвет
    }
}

kernel void resize_image(texture2d<float, access::read>  inputTexture  [[ texture(0) ]],
                         texture2d<float, access::write> outputTexture [[ texture(1) ]],
                         uint2 gid [[ thread_position_in_grid ]]) {
    float2 inputCoord = float2(gid) / float2(outputTexture.get_width(), outputTexture.get_height());
    inputCoord *= float2(inputTexture.get_width(), inputTexture.get_height());

    float4 color = inputTexture.read(uint2(inputCoord));
    outputTexture.write(color, gid);
}

