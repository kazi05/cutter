//
//  process.metal
//  Cutter
//
//  Created by Гаджиев Казим on 18.02.2024.
//

#include <metal_stdlib>
using namespace metal;

kernel void bg_erase(texture2d<float, access::read>  inputTexture  [[ texture(0) ]],
                     texture2d<float, access::read>  maskTexture   [[ texture(1) ]],
                     texture2d<float, access::write> outputTexture [[ texture(2) ]],
                     uint2 gid [[ thread_position_in_grid ]]) {
    // Чтение и применение маски аналогично, с использованием адаптированных координат rotatedGid
    float4 color = inputTexture.read(gid);
    float4 maskColor = maskTexture.read(gid);

    if (maskColor.r > 0.01f) {
        outputTexture.write(color, gid);
    } else {
        outputTexture.write(float4(0.6078431373, 1.0, 0.4705882353, 1.0), gid); // Цвет хромакея
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

