package com.bytedance.labcv.effectsdk;

import java.util.Arrays;

/**
 * 宠物脸检测结果定义
 * Result of Pet face detected
 */
public class BefPetFaceInfo extends BefFaceInfo{

    private int faceCount = 0;

    public int getFaceCount() {
        return faceCount;
    }

    public PetFace[] getFace90(){
        return (PetFace[]) getFace106s();
    }

    @Override
    public String toString() {
        return "BefPetFaceInfo{" +
                "faces=" + Arrays.toString(getFace106s()) +
                '}';
    }

    public static class PetFace extends Face106{
        int type;
        public int getType() {
            return type;
        }
        @Override
        public String toString() {
            return "PetFace{" +
                    "rect=" + rect +
                    ", score=" + score +
                    ", points_array=" + Arrays.toString(points_array) +
                    ", visibility_array=" + Arrays.toString(visibility_array) +
                    ", yaw=" + yaw +
                    ", pitch=" + pitch +
                    ", roll=" + roll +
                    ", eye_dist=" + eye_dist +
                    ", action=" + action +
                    ", type=" + type +
                    ", ID=" + ID +
                    '}';
        }

    }
}
