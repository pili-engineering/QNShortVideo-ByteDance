// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
package com.bytedance.labcv.effectsdk;

import android.content.Context;
import android.util.Log;

import java.nio.ByteBuffer;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.*;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.FaceDetectType.BEF_FACE_PARAM_MAX_FACE_NUM;

/**
 * 人脸检测入口
 * Face detection entrance
 */
public class FaceDetect {

    private long mNativePtr;

    private long mAttriNativePtr;

    private volatile boolean mInited = false;

    private volatile boolean mInitedExtra = false;

    private volatile boolean mInitedAttri = false;

    // 106关键点检测配置
    // 106 key detection configuration
    private int mFaceDetectConfig = -1;

    // 属性检测配置
    // Attribute detection configuration
    private int mFaceAttriConfig = -1; // for jni detect get

    private static final int MaxFaceNum = 10;

    static {
        System.loadLibrary("effect_proxy");
    }

    /**
     * 初始化人脸106关键点检测句柄
     * Initialize face 106 key detection handle
     * @param modelPath the model path 模型文件路径
     * @param config  Face detection algorithm configuration 人脸检测算法的配置
     *       config = 模型类型（必须设置,目前只有一种模式BytedEffectConstants.BEF_DETECT_SMALL_MODEL）
     *               |检测模式（缺省值为BEF_DETECT_MODE_VIDEO,参考{@link BytedEffectConstants.DetectMode}）
     *               |可检测的特征（必须设置, 参考{@link BytedEffectConstants.FaceAction}）
     *       Config = model type (it should be set that there is currently only one mode, BytedEffectConstants.BEF_DETECT_SMALL_MODEL)
     *               | test mode (the default value is BEF_DETECT_MODE_VIDEO, see {@ link BytedEffectConstants. DetectMode})
     *               | detectable characteristics (must be set, reference {@ link BytedEffectConstants. FaceAction})
     * @param license license file path 授权文件
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */

    public int init(Context context, String modelPath, int config, String license) {
        int ret = nativeInit(config, modelPath);
        if (ret != BEF_RESULT_SUC) {
            mInited = false;
            return ret;
        }

        if (ret != BEF_RESULT_SUC) {
            mInited = false;
        }

        ret = nativeCheckLicense(context, license);
        if (ret != BEF_RESULT_SUC) {
            mInited = false;
            return ret;
        }

        ret = setDetectParam(BEF_FACE_PARAM_MAX_FACE_NUM, MaxFaceNum);
        if (ret != BEF_RESULT_SUC) {
            mInited = false;
            return ret;
        }
        mInited = true;
        return ret;
    }

    /**
     * 设置240/280关键点检测模型
     * Set the 240/280 key detection model
     * @param context Android context 上下文内容
     * @param extraModelpath model file path模型文件路径
     * @param extraType 算法配置，支持以下四种
     *              Config-240，BEF_MOBILE_FACE_240_DETECT
     *              Config-280，BEF_MOBILE_FACE_280_DETECT
     *              Config-240 快速模式, BEF_MOBILE_FACE_240_DETECT | BEF_DETECT_FACE_240_DETECT_FASTMODE
     *              Config-280 快速模式, BEF_MOBILE_FACE_280_DETECT | BEF_DETECT_FACE_240_DETECT_FASTMODE
     *            Algorithm configuration，Support the following four type
     *              Config-240，BEF_MOBILE_FACE_240_DETECT
     *              Config-280，BEF_MOBILE_FACE_280_DETECT
     *              Config-240 fast mode, BEF_MOBILE_FACE_240_DETECT | BEF_DETECT_FACE_240_DETECT_FASTMODE
     *              Config-280 fast mode, BEF_MOBILE_FACE_280_DETECT | BEF_DETECT_FACE_240_DETECT_FASTMODE
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码，查看{@link BytedEffectConstants.BytedResultCode}
     */
    public int initExtra(Context context, String extraModelpath, int extraType)
    {
        int ret =  mInited ?BEF_RESULT_SUC : BEF_RESULT_FAIL;
        if(BEF_RESULT_SUC == ret)
        {
            ret = nativeInitExtra(extraType, extraModelpath);
        }
         mInitedExtra = true;
        return ret;
    }

    /**
     * 初始化人脸属性检测句柄
     * Initializes the face property detection handle
     * @param context Android context 上下文
     * @param faceAttriModelPath Face property model file path 人脸属性模型文件路径
     * @param faceAttrLicense Face attribute detection authorization file 人脸属性检测授权文件
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码，查看{@link BytedEffectConstants.BytedResultCode}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int initAttri(Context context, String faceAttriModelPath, String faceAttrLicense)
    {
        int ret =  mInited ? BEF_RESULT_SUC : BEF_RESULT_FAIL;
        if(BEF_RESULT_SUC == ret)
        {
            // config 为预留字段 目前没有使用 传0即可
            ret = nativeInitAttri(0, faceAttriModelPath, context, faceAttrLicense);
        }
        mInitedAttri = true;
        return ret;
    }

    /**
     * 设置人脸属性检测参数
     * Set face property detection parameters
     * @param attriConfig
     */
    public void setAttriDetectConfig(int attriConfig)
    {
        mFaceAttriConfig =  attriConfig;
    }

    /**
     * 获取人脸属性检测配置
     * Get the face property detection configuration
     * @return 人脸属性检测配置 face property detection configuration
     */
    public int getFaceAttriConfig() {
        return mFaceAttriConfig;
    }

    /**
     * 获取人脸检测配置
     * Get the face detection configuration
     * @return 人脸检测配置 face detection configuration
     */
    public int getFaceDetectConfig() {
        return mFaceDetectConfig;
    }

    /**
     * 设置人脸检测算法配置，该配置必须是Init中使用的配置的子集
     * Sets the face detection algorithm configuration,
     * which must be a subset of the configuration used in Init
     * @param mFaceDetectConfig 人脸检测配置 Face detection configuration
     */
    public void setFaceDetectConfig(int mFaceDetectConfig) {
        this.mFaceDetectConfig = mFaceDetectConfig;
    }


    /**
     * 人脸检测器是否初始化
     * Whether the face detector is initialized
     * @return 已初始化返回true,否则返回false
     *          Initialized to return true, otherwise false
     */
    public boolean isInited() {
        return mInited;
    }

    /**
     * 是否已加载附加关键点模型
     * Whether additional critical point models have been loaded
     * @return 已加载返回true,否则返回false
     *          Loaded to return true, otherwise false
     */
    public boolean isInitedExtra() {
        return mInitedExtra;
    }

    /**
     * 是否已加载人脸属性检测模型
     * Whether the face attribute detection model has been loaded
     * @return 已加载返回true,否则返回false
     *          Loaded to return true, otherwise false
     */
    public boolean isInitedAttri() {return mInitedAttri;}

    /**
     * 检测人脸关键点
     * Face detection key points
     * @param buffer image date 图片数据
     * @param pixel_format image format 图片数据格式
     * @param image_width image width 图片宽度
     * @param image_height image height 图片高度
     * @param image_stride image stride 图片每一行的步长
     * @param orientation image orientation 图片旋转角度
     *
     * @return 人脸检测结果 detect result
     */
    public BefFaceInfo detectFace(ByteBuffer buffer, BytedEffectConstants.PixlFormat pixel_format, int image_width, int image_height, int image_stride, BytedEffectConstants.Rotation orientation) {
        if (!mInited) {
            return null;
        }
        BefFaceInfo info = new BefFaceInfo();
        int result = nativeDetect(buffer, pixel_format.getValue(), image_width,
                image_height, image_stride, orientation.id, mFaceDetectConfig, info);
        if (result != BEF_RESULT_SUC) {
            Log.e(BytedEffectConstants.TAG, "nativeDetect return "+result);
            return null;
        }
        return info;
    }

    /**
     * 销毁人脸关键点检测、人脸属性检测句柄
     * Destroy face key detection, face attribute detection handle
     */
    public void release() {
        if (mInited) {
            nativeRelease();
        }
        if(mInitedAttri)
        {
            nativeReleaseAttri();
        }
        mInited = false;
        mInitedExtra =false;
        mInitedAttri = false;
    }



    /**
     * 设置人脸检测参数
     * Set face detection parameters
     * @param paramType 参数类型
     * @param paramValue 参数值
     * @return 成功返回
     */
    public int setDetectParam(int paramType , int paramValue)
    {
        return nativeSetParam(paramType, paramValue);
    }


    private native int nativeInit(int config, String modelPath);
    private native int nativeInitExtra(int config, String modelPath);
    private native int nativeInitAttri(int config, String modelPath, Context context, String license);
    private native int nativeCheckLicense(Context context, String license);
    private native int nativeSetParam(int paramType, int value);
    private native int nativeDetect(ByteBuffer buffer, int pixel_format,
                                     int image_width,
                                     int image_height,
                                     int image_stride,
                                     int orientation,
                                     long detect_config,
                                     BefFaceInfo faceInfo);
    private native void nativeRelease();
    private native void nativeReleaseAttri();
}
