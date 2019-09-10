package com.bytedance.labcv.effectsdk;

import android.content.Context;
import android.util.Log;

import java.nio.ByteBuffer;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC;

public class PetFaceDetect {
    public static final int MAX_PET_FACE_NUM = 10;
    static {
        System.loadLibrary("effect_proxy");
    }
    private long mNativePtr;

    private volatile boolean mInited = false;


    /**
     * 初始化宠物关键点检测句柄
     * Initialize the pet key detection handle
     * @param  context      android context 上下文
     * @param modelPath     model file path 模型文件路径
     * @param config        Configuration of pet face detection algorithm 宠物脸检测算法的配置
     *       config = 可检测的特征（必须设置, 参考{@link BytedEffectConstants.PetFaceAction}）
     *       Config = detectable characteristics (must be set, reference {@ link BytedEffectConstants. PetFaceAction})
     * @param license       license file path 授权文件
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
     */

    public int init(Context context, String modelPath, int config, String license) {
        int ret = nativeCreateHandle(modelPath, config, MAX_PET_FACE_NUM);
        if (ret != BEF_RESULT_SUC) {
            mInited = false;
            return ret;
        }

        ret = nativeCheckLicense(context, license);
        if (ret != BEF_RESULT_SUC) {
            mInited = false;
            return ret;
        }

        mInited = true;
        return ret;
    }

    /**
     * 检测宠物脸关键点
     * Detect key points on your pet's face
     * @param buffer image data 图片数据
     * @param pixel_format image format 图片数据格式
     * @param image_width image width 图片宽度
     * @param image_height image height 图片高度
     * @param image_stride image stride 图片每一行的步长
     * @param orientation image orientation 图片旋转角度
     *
     * @return 宠物脸检测结果
     *          Pet face detected results
     */
    public BefPetFaceInfo detectFace(ByteBuffer buffer, BytedEffectConstants.PixlFormat pixel_format, int image_width, int image_height, int image_stride, BytedEffectConstants.Rotation orientation) {
        if (!mInited) {
            return null;
        }
        BefPetFaceInfo info = new BefPetFaceInfo();
        int result = nativeDetect(buffer, pixel_format.getValue(), image_width,
                image_height, image_stride, orientation.id, info);
        if (result != BEF_RESULT_SUC) {
            Log.e(BytedEffectConstants.TAG, "nativeDetect return "+result);
            return null;
        }
        return info;
    }

    /**
     * 销毁宠物脸关键点检测、宠物脸属性检测句柄
     * Destroy key points detection of pet face, pet face attribute detection handle
     */
    public void release() {
        if (mInited) {
            nativeRelease();
        }
        mInited = false;
    }

    private native int nativeCreateHandle(String faceModelPath,long config, int maxfaceNum);
    private native int nativeDetect(ByteBuffer buffer, int pixel_format,
                                    int image_width,
                                    int image_height,
                                    int image_stride,
                                    int orientation,
                                    BefPetFaceInfo faceInfo);
    private native int nativeCheckLicense(Context context, String license);
    private native void nativeRelease();

    public boolean isInited() {
        return mInited;
    }
}
