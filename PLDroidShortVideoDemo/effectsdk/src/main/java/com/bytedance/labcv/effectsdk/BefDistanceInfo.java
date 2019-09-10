package com.bytedance.labcv.effectsdk;

/**
 * 人体距离估计结果 最多支持10人
 * The human distance estimation results. Support up to 10 people
 */
public class BefDistanceInfo {
    private BefFaceInfo.FaceRect[] faceRects;
    private float[] dists;
    private int faceCount;

    public BefFaceInfo.FaceRect[] getFaceRects() {
        return faceRects;
    }

    public float[] getDists() {
        return dists;
    }

    public int getFaceCount() {
        return faceCount;
    }
    public BefDistance[] getBefDistance(){
        BefDistance[] results =  new BefDistance[faceCount];

        for (int i =0; i < faceCount; i++){
            results[i] = new BefDistance(faceRects[i],  dists[i]);
        }
        return results;
    }
    @Override
    public String toString() {
        return "";
    }

    /**
     * 单个人体距离
     * Individual body distance
     */
    public static class BefDistance{
        public BefDistance(BefFaceInfo.FaceRect faceRect, float dis) {
            this.faceRect = faceRect;
            this.dis = dis;
        }

        private BefFaceInfo.FaceRect faceRect;
        private float dis;

        public BefFaceInfo.FaceRect getFaceRect() {
            return faceRect;
        }

        public float getDis() {
            return dis;
        }
    }
}
