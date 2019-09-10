package com.bytedance.labcv.effectsdk;

import android.content.Context;
import android.util.Log;

import java.nio.ByteBuffer;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC;
import static com.bytedance.labcv.effectsdk.BytedEffectConstants.FaceDetectType.BEF_FACE_PARAM_MAX_FACE_NUM;

public class FaceCluster {
    private long mNativeClusterPtr;

    private volatile boolean mInited = false;

    static {
        System.loadLibrary("effect_proxy");
    }

    /**
     * 初始化人脸聚类
     * Initialize face clustering
     * @param context   上下文
     * @param license   Path to the license file 授权文件的路径
     * @return          success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int init(Context context, String license){
        int ret = nativeCreateHandle();
        if (ret != BEF_RESULT_SUC){
            mInited = false;
            return ret;
        }

        ret = nativeCheckLicense(context, license);
        if (ret != BEF_RESULT_SUC){
            mInited = false;
            return ret;
        }

        mInited = true;
        return ret;
    }

    /**
     * 设置人脸聚类参数
     * @param paramType     参数类型
     * @param paramValue    参数值
     * @return              success return BEF_RESULT_SUC，Otherwise the corresponding error code is returned
     */
    public int setDetectParam(int paramType , int paramValue) {
        return nativeSetParam(paramType, paramValue);
    }

    /**
     * Face clustering interface
     *
     * @param features  Face feature vector 人脸特征向量
     * @param numSize   Amount of face feature 人脸特征个数
     * @return          聚类结果，每个特征所属类别的数组
     *                  Clustering results, an array of categories to which each feature belongs
     */
    public int[] cluster(float[][] features, int numSize) {
        float[] featuresList;
        int[] cluster = new int[numSize];
        //计算总长度
        int len = 0;
        for (float[] feature : features) {
            len += feature.length;
        }
        //将二维数组拉成一维
        featuresList = new float[len];
        int index = 0;
        for (float[] feature : features) {
            for (float element : feature) {
                featuresList[index++] = element;
            }
        }
        int ret = nativeCluster(featuresList, numSize, cluster);
        if (ret != BEF_RESULT_SUC){
            Log.e(BytedEffectConstants.TAG, "nativeCluster return "+ret);
            return null;
        }

        return cluster;
    }

    /**
     * 销毁人脸聚类句柄
     * Destroy the face clustering handle
     */
    public void release() {
        if (mInited) {
            nativeRelease();
        }
        mInited = false;
    }

    private native int nativeCreateHandle();
    private native int nativeCheckLicense(Context context, String license);
    private native int nativeSetParam(int type, int value);
    private native int nativeCluster(float[] features, int numSize, int[] cluster);
    private native void nativeRelease();
}
