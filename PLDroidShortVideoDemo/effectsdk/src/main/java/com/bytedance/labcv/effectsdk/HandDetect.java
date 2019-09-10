package com.bytedance.labcv.effectsdk;

import android.content.Context;
import android.util.Log;

import java.nio.ByteBuffer;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.*;

/**
 * 手势检测入口
 * Gesture detection entry
 */
public class HandDetect {
    final static String TAG = "HandDetect";

    private long mNativePtr;

    static {
        try {
            System.loadLibrary("effect_proxy");
        } catch (UnsatisfiedLinkError ule) {
            System.err.println("WARNING: Could not load library!");
            System.err.print(ule);
        }
    }


    /**
     * 创建收手势检测句柄并授权
     * Create the receive gesture detection handle and authorize it
     * @param context Android context 上下文
     * @param licensePath license file path 授权文件路径
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int createHandle(Context context,String licensePath) {
        int ret = nativeCreateHandler();
        if (ret != 0){
            return BEF_RESULT_INVALID_HANDLE;
        }
        return nativeCheckLicense(context,licensePath);
    }

    /**
     * 加载手势检测模型
     * Load the gesture detection model
     * @param modelType
     * @param modelPath
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int setModel(BytedEffectConstants.HandModelType modelType, String modelPath){
        return  nativeSetModel(modelType.getValue(), modelPath);
    }

    /**
     * 设置手势检测参数
     * @param paramType  参数类型
     * @param paramValue 参数值
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int setParam(BytedEffectConstants.HandParamType paramType, float paramValue){
        return nativeSetParam(paramType.getValue(), paramValue);
    }

    /**
     * 检测手势
     * detect hand
     * @param buffer image buffer 图片字节流
     * @param pixel_format image format 图片格式
     * @param image_width image width 图片宽度
     * @param image_height image height 图片长度
     * @param image_stride image stride 图片数据行宽
     * @param orientation image orientation图片方向
     * @param detectconfig 请求检测的模块，为 {@link BytedEffectConstants.HandModelType}的按位与操作
     *                      Request detection module for {@ link BytedEffectConstants. HandModelType} the bitwise and operator
     * @param delayFrameCount  每隔多少帧执行一次手势检测
     *                         Perform gesture detection in how many frames
     *
     *
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public BefHandInfo detectHand(ByteBuffer buffer, BytedEffectConstants.PixlFormat pixel_format, int image_width, int image_height, int image_stride, BytedEffectConstants.Rotation orientation, int  detectconfig, int delayFrameCount) {

        BefHandInfo info = new BefHandInfo();
        int result = nativeDetect( buffer, pixel_format.getValue(), image_width,
                image_height, image_stride, orientation.id, detectconfig, info, delayFrameCount);
        if (result != BEF_RESULT_SUC) {
            Log.e(BytedEffectConstants.TAG, "nativeDetect return "+result);
            return null;
        }
        return info;
    }

    /**
     * 销毁检测句柄
     * release detect handler
     */
    public void release() {
            nativeRelease();

    }

    private native int nativeCreateHandler();

    private native int nativeSetModel(long model_type, String param_path);

    private native int nativeCheckLicense(Context context, String license);

    private native int nativeSetParam(int paramType, float paramValue);

    private native int nativeDetect(ByteBuffer buffer, int pixel_format,
                                    int image_width,
                                    int image_height,
                                    int image_stride,
                                    int orientation,
                                    long detect_config,
                                    BefHandInfo handInfo,
                                    int delayFrameCount);

    private native void nativeRelease();
}
