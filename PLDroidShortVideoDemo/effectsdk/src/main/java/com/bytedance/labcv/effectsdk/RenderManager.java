// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
package com.bytedance.labcv.effectsdk;

import android.content.Context;

import java.nio.ByteBuffer;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC;

/**
 * 特效（包括滤镜、美颜、贴纸、美妆）入口
 * Special effects (including filters, beauty, stickers, makeup) entry
 */
public class RenderManager {

    private long mNativePtr;

    private volatile boolean mInited;

    static {
        System.loadLibrary("effect");
        System.loadLibrary("effect_proxy");
    }

    /**
     * 初始化特效句柄
     * Initializes the effects handle
     * @param context android context 应用上下文
     * @param modelDir 模型文件的根目录，注意不是模型文件的绝对路径，该目录下文件层次和目录名称必须和Demo中提供的完全一致
     *                 The root directory of the model file, note that it is not an absolute path to the model file,
     *                 and the file hierarchy and directory names in this directory must be exactly the same as those provided in the Demo
     * @param licensePath license file path 授权文件绝对路径
     * @param width 人像转为正后 输入图片/纹理的宽度
     *              Enter the width of the image/texture after the portrait is converted to positive
     * @param height 人像转为正后 输入图片/纹理的高度
     *               Enter the height of the image/texture after the portrait is converted to positive
     * @return 成功返回BEF_RESULT_SUC，其他返回值参考{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     *
     */
    public int init(Context context, String modelDir, String licensePath, int width, int height) {

        int ret = BEF_RESULT_SUC;
        if (!mInited) {
            ret = nativeInit(context, modelDir, licensePath, width, height);
            mInited = (ret == BEF_RESULT_SUC);
        }
        return ret;
    }

    /**
     * 释放特效相关句柄
     * Releases effect-related handles
     */
    public void release() {
        if (mInited) {
            nativeRelease();
        }
        mInited = false;
    }

    /**
     * 验证测试素材的license
     * Verify the license of test material
     * @param context
     * @param modelDir
     * @param licensePath
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码，参考{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int initTest(Context context, String modelDir, String licensePath, int width, int height) {

        int ret = BEF_RESULT_SUC;
        ret = nativeInitTest(context, modelDir, licensePath, width, height);
        mInited = (ret == BEF_RESULT_SUC);

        return ret;
    }

    /**
     * 设置美颜素材
     * Set beauty material
     * @param resourcePath 素材绝对路径 如果传null或者空字符，则取消美颜效果
     *                     Material absolute path if pass null or null character, then cancel beauty effect
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean setBeauty(String resourcePath) {
        if (!mInited) {
            return false;
        }
        if (resourcePath == null) {
            resourcePath = "";
        }
        return nativeSetBeauty(resourcePath) == BEF_RESULT_SUC;
    }
    /**
     * 设置塑形素材
     * Set shaping materials
     * @param resourcePath 素材绝对路径 如果传null或者空字符，则取消塑形效果
     *                     Material absolute path
     *                     If null or null characters are passed, the shaping effect is cancelled
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean setReshape(String resourcePath) {
        if (!mInited) {
            return false;
        }
        if (resourcePath == null) {
            resourcePath = "";
        }
        return nativeSetReshape(resourcePath) == BEF_RESULT_SUC;
    }

    /**
     * 设置滤镜素材
     * Set the filter material
     * @param resourcePath 素材绝对路径 如果传null或者空字符，则取消滤镜效果
     *                     Material absolute path,
     *                     If null or null characters are passed, the filter effect is cancelled
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean setFilter(String resourcePath) {
        if (!mInited) {
            return false;
        }
        if (resourcePath == null) {
            resourcePath = "";
        }
        return nativeSetFilter(resourcePath) == BEF_RESULT_SUC;
    }

    /**
     * 设置美妆素材
     * Set the makeup material
     * @param resourcePath 素材绝对路径 如果传null或者空字符，则取消美妆效果
     *                     Material absolute path,
     *                     If null or null characters are passed, the makeup effect is cancelled
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean setMakeUp(String resourcePath) {
        if (!mInited) {
            return false;
        }
        if (resourcePath == null) {
            resourcePath = "";
        }
        return nativeSetMakeUp(resourcePath) == BEF_RESULT_SUC;
    }

    /**
     * 设置贴纸素材
     * Set the sticker material
     * @param resourcePath 素材绝对路径 如果传null或者空字符，则取消贴纸效果
     *                     Material absolute path,
     *                     If null or null characters are passed, the sticker effect is cancelled
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean setSticker(String resourcePath) {
        if (!mInited) {
            return false;
        }
        if (resourcePath == null) {
            resourcePath = "";
        }
        return nativeSetSticker(resourcePath) == BEF_RESULT_SUC;
    }

    /**
     * 处理纹理 processTexture texture
     * @param srcTextureId input texture id 输入纹理ID
     * @param dstTextureId output texture id 输出纹理ID
     * @param width texture width纹理宽度
     * @param height texture height 纹理高度
     * @param rotation texture rotation 纹理旋转角，参考{@link BytedEffectConstants.Rotation}
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean processTexture(int srcTextureId, int dstTextureId, int width, int height, BytedEffectConstants.Rotation rotation, double timestamp) {
        if (!mInited) {
            return false;
        }
        return nativeProcess(srcTextureId, dstTextureId, width, height, rotation.id, timestamp) == BEF_RESULT_SUC;
    }

    /**
     * 处理像素数据
     * Processing pixel data
     * @param inputdata input data输入数据
     * @param orient orientation 旋转角，参考{@link BytedEffectConstants.Rotation}
     * @param in_pixformat data format 数据格式 参考{@link BytedEffectConstants}
     * @param imagew image width 图片宽度
     * @param imageh image height 图片高度
     * @param imagestride image stride 图片步长
     * @param outdata ouput data 输出结果
     * @param out_pixformat output format 输出结果格式 参考{@link BytedEffectConstants}
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean processBuffer(ByteBuffer inputdata, BytedEffectConstants.Rotation orient, int in_pixformat, int imagew, int imageh, int imagestride, byte[] outdata, int out_pixformat) {
        if (!mInited) {
            return false;
        }
        double timestamp = System.nanoTime();
        int retStatus = nativeProcessBuffer(inputdata, orient.id, in_pixformat, imagew, imageh, imagestride, outdata, out_pixformat, timestamp);
        return retStatus == BEF_RESULT_SUC;
    }

    /**
     * 设置强度
     * Set the intensity
     * @param intensitytype type 类型
     * @param intensity
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public boolean updateIntensity(int intensitytype, float intensity) {
        return nativeUpdateIntensity(intensitytype, intensity) == BEF_RESULT_SUC;
    }

    /**
     * 设置塑形参数
     * Set shaping parameters
     * @param cheekintensity The intensity of thin face 瘦脸强度 0-1
     * @param eyeintensity The intensity of bigger eye 大眼参数 0-1
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    @Deprecated
    public boolean updateReshape(float cheekintensity, float eyeintensity) {
        return nativeUpdateReshape(cheekintensity, eyeintensity) == BEF_RESULT_SUC;
    }

    /**
     * 设置叠加美妆特效的初始化设置
     * Set the initialization Settings for overlay beauty effects
     * @param composerPath
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int setComposer(String composerPath){
        return nativeSetComposer(composerPath);

    }

    /**
     * 设置叠加美妆特效
     * Set overlay beauty effects
     * @param composerNodes
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int setComposerNodes(String[] composerNodes){
        return nativeSetComposerNodes(composerNodes);

    }

    /**
     * 设置某一个 Composer 的强度
     * Set the strength of Composer
     * @param path Composer path 对应路径
     * @param key KEY
     * @param value strength 强度值，0～1
     * @return 成功返回BEF_RESULT_SUC， 其他返回值查看{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int updateComposerNodes(String path, String key, float value) {
        return nativeUpdateComposer(path, key, value);
    }




    private native int nativeInitTest(Context context, String algorithmResourceDir, String license, int width, int height);

    private native int nativeInit(Context context, String algorithmResourceDir, String license, int width, int height);

    private native void nativeRelease();

    private native int nativeSetBeauty(String beautyType);

    private native int nativeSetReshape(String reshapeType);

    private native int nativeSetFilter(String filterPath);

    private native int nativeSetMakeUp(String filterPath);

    private native int nativeSetSticker(String filterPath);

    private native int nativeUpdateIntensity(int itype, float intensity);

    private native int nativeUpdateReshape(float cheekintensity, float eyeintensity);

    private native int nativeSetComposer(String composerPath);

    private native int nativeSetComposerNodes(String[] nodes);

    private native int nativeUpdateComposer(String path, String key, float value);

    private native int nativeProcess(int srcTextureId, int dstTextureId, int width, int height, int rotation, double timeStamp);

    private native int nativeProcessBuffer(ByteBuffer inputdata, int rotation, int in_pixformat, int imagew, int imageh, int imagestride, byte[] outdata, int out_pixformat, double timestamp);

}
