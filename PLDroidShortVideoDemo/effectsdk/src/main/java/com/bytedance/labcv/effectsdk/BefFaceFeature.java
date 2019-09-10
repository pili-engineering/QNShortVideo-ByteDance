package com.bytedance.labcv.effectsdk;

/**
 * 人脸特征结果
 * Face feature results
 */
public class BefFaceFeature {

    private int validFaceNum;
    private float[][] features;
    private BefFaceInfo.Face106[] baseInfo;

    public int getValidFaceNum() {
        return validFaceNum;
    }

    public float[][] getFeatures() {
        return features;
    }

    public BefFaceInfo.Face106[] getBaseInfo() {
        return baseInfo;
    }

    @Override
    public String toString() {
        return "BefFaceFeature{ validFaceNum =" + validFaceNum
                + " baseInfo = " + baseInfo.toString() +
                " features =" + features.toString();
    }
}


