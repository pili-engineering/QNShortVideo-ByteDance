package com.bytedance.labcv.effectsdk;

import android.content.Context;

import android.util.Log;

import java.nio.ByteBuffer;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_FAIL;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.HumanDistanceParamType.BEF_HumanDistanceCameraFov;

public class HumanDistance {


    static {
        System.loadLibrary("effect_proxy");
    }

    private long mNativeFacePtr;
    private long mNativeFaceAttrPtr;
    private long mNativeDistPtr;
    private boolean inited = false;

    /**
     * 初始化距离估计句柄
     * Initializes the distance estimation handle
     * @param context android context 应用上下文
     * @param modelPath model file path 人脸106点模型
     * @param fov camera params 相机参数
     * @param licensePath license file path 授权文件绝对路径
     * @return 成功返回BEF_RESULT_SUC，其他返回值参考{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int init(Context context,String modelPath, String faceAttrModel,float fov, String licensePath) {
        int retStatus = BEF_RESULT_FAIL;
        if (!inited) {
            retStatus = nativeCreateHandle(modelPath,faceAttrModel);
            if (retStatus != BEF_RESULT_SUC) {
                Log.e(BytedEffectConstants.TAG, "nativeCreateHandle fail!! return "+retStatus);
                return retStatus;
            }
            retStatus = nativeCheckLicense(context, licensePath);

            if (retStatus != BEF_RESULT_SUC) {
                Log.e(BytedEffectConstants.TAG, "nativeCheckLicense fail!! return "+retStatus);
                return retStatus;
            }
            retStatus = nativeSetParam(BEF_HumanDistanceCameraFov.getValue(), fov);
            if (retStatus != BEF_RESULT_SUC) {
                Log.e(BytedEffectConstants.TAG, "nativeSetParam fail!! return "+retStatus);
                return retStatus;
            }

            inited = (retStatus == BEF_RESULT_SUC);
        }
        return retStatus;
    }

    /**
     * 释放距离估计句柄
     * release distance estimation
     */
    public void release() {
        if (inited) {
            nativeRelease();
        }
        inited = false;
    }

    /**
     * 距离估计接口
     * distance estimation interface
     * @param imgdata       image data 输入图像数据
     * @param pixel_format  image format 输入图像数据格式
     * @param width         image width 输入图像宽
     * @param height        image height 输入图像高
     * @param stride        image stride 输入图像步长
     * @param orientation   image orientation 输入图像方向
     * @return @link MattingMask Matting 结果， 单通道灰度图
     *          result, Single channel grayscale
     */
    public BefDistanceInfo detectDistance(ByteBuffer imgdata, BytedEffectConstants.PixlFormat pixel_format,
                                                      int width, int height, int stride, BytedEffectConstants.Rotation orientation) {
        int result = BEF_RESULT_FAIL;
        BefDistanceInfo humanDistanceResult = new BefDistanceInfo();
        result = nativeDetect(imgdata, pixel_format.getValue(), width, height, stride, orientation.id, humanDistanceResult);
        if (result != BEF_RESULT_SUC) {
            Log.e(BytedEffectConstants.TAG, "nativeDetect return " + result);
            return null;
        }
        return humanDistanceResult;
    }


    private native int nativeCreateHandle(String faceModel,String faceAttrModel);

    private native int nativeSetParam(int paramType, float value);


    private native int nativeCheckLicense(Context context, String licensePath);

    private native int nativeDetect(ByteBuffer imgdata, int pixelformat,
                                    int width, int height, int stride, int orientation, BefDistanceInfo mattingMask);


    private native void nativeRelease();


}
