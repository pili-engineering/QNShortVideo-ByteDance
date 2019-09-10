package com.bytedance.labcv.effectsdk;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.nio.ByteBuffer;
import java.util.Arrays;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_FAIL;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC;

/**
 * 头发分割
 * hair split
 */
public class HairParser {

    static {
        System.loadLibrary("effect_proxy");
    }

    /**
     * 头发分割结果
     * split results
     */
    public class HairMask {
        private int width;
        private int height;
        private byte[] buffer;
        private int channel;

        public byte[] getBuffer() {
            return buffer;
        }

        public int getWidth() {
            return width;
        }

        public int getHeight() {
            return height;
        }

        @Override
        public String toString() {
            return String.format("l: %d w:%d, h:%d", buffer.length, width, height);
        }
    }

    private long mNativePtr;
    private boolean inited = false;

    /**
     * 初始化头发分割句柄
     * Initializes hair split handle
     * @param context     android context 应用上下文
     * @param modelpath   model file path 模型文件绝对路径
     *
     * @param licensePath license file path 授权文件绝对路径
     * @return 成功返回BEF_RESULT_SUC，其他返回值参考{@link BytedEffectConstants}
     *        success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int init(Context context, String modelpath, String licensePath) {
        int retStatu = BEF_RESULT_FAIL;
        if (!inited) {
            retStatu = nativeCreateHandle();
            if (retStatu == BEF_RESULT_SUC)
                retStatu = nativeCheckLicense(context, licensePath);
            if (retStatu == BEF_RESULT_SUC) {
                retStatu = nativeInit(modelpath);
            }

            inited = retStatu == BEF_RESULT_SUC;
        }
        return retStatu;
    }

    /**
     * 释放头发分割句柄
     * release hair split handle
     */
    public void release() {
        if (inited) {
            nativeRelease();
        }
        inited = false;
    }

    /**
     * 头发分割
     * hair split
     * @param imgdata image data 输入图像数据
     * @param pixel_format image format输入数据格式
     * @param width image width 输入图像宽度
     * @param height image height 输入图像高度
     * @param stride image stride 输入图像步长
     * @param orientation image orientation 图像旋转角
     * @param needFlipAlpha Whether the output image needs to be flipped 输出图像是否需要翻转
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码，参考{@link BytedEffectConstants}
     *          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public HairMask parseHair(ByteBuffer imgdata, BytedEffectConstants.PixlFormat pixel_format,
                         int width, int height, int stride, BytedEffectConstants.Rotation orientation,
                         boolean needFlipAlpha) {
        HairParser.HairMask hairMask = new HairParser.HairMask();
        int[] shape = new int[3];
        int ret = nativeGetShape(shape);
        if (ret == BEF_RESULT_SUC) {
            hairMask.width = shape[0];
            hairMask.height = shape[1];
            hairMask.channel = shape[2];
            hairMask.buffer = new byte[ hairMask.width * hairMask.height *  hairMask.channel];
            Arrays.fill( hairMask.buffer, (byte)0);
        }else {
            Log.e(BytedEffectConstants.TAG, "nativeDetect return "+ret);
            return null;
        }
        ret = nativeParse(imgdata, pixel_format.getValue(), width, height, stride, orientation.id, needFlipAlpha, hairMask.buffer);
        if (ret != BEF_RESULT_SUC) {
            Log.e(BytedEffectConstants.TAG, "nativeDetect return "+ret);
            return null;
        }
        return hairMask;
    }

    /**
     * 设置SDK参数
     * set sdk params
     * @param width Algorithm module method input width 算法模块法输入的宽度 算法模块法输入的宽度
     * @param height Algorithm module method input height算法模块法输入的高度
     * @param useTracking whether to track 是否跟踪 传入true
     * @param useBlur Whether the fuzzy 是否模糊 传入true
     * @return 成功返回BEF_RESULT_SUC，否则返回对应的错误码，参考{@link BytedEffectConstants}
     *           success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int setParam(int width, int height, boolean useTracking, boolean useBlur) {
        return nativeSetParam(width, height, useTracking, useBlur);
    }


    private native int nativeCreateHandle();

    private native int nativeInit(String modelPath);

    private native int nativeCheckLicense(Context context, String licensePath);

    private native int nativeGetShape(int[] shape);

    private native int nativeParse(ByteBuffer imgData, int pixelFormat,
                                   int width, int height, int stride, int orientation,
                                   boolean needFlipAlpha, byte[] mask);

    private native int nativeSetParam(int netInputWidth, int netInputHeight, boolean useTracking, boolean useBlur);

    private native int nativeRelease();
}
