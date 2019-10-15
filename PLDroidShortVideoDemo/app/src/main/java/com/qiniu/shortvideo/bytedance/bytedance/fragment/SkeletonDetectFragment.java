package com.qiniu.shortvideo.bytedance.bytedance.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.activity.VideoRecordActivity;
import com.qiniu.shortvideo.bytedance.bytedance.base.IPresenter;
import com.qiniu.shortvideo.bytedance.bytedance.utils.CommonUtils;
import com.qiniu.shortvideo.bytedance.bytedance.utils.ToasUtils;
import com.qiniu.shortvideo.bytedance.bytedance.view.ButtonView;


/**
 * 人体
 */
public class SkeletonDetectFragment
        extends BaseFeatureFragment<IPresenter, SkeletonDetectFragment.ISkeletonCallback>
        implements View.OnClickListener, VideoRecordActivity.OnCloseListener {
    private ButtonView bvSkeleton;

    public interface ISkeletonCallback {
        void skeletonDetectOn(boolean on);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return LayoutInflater.from(getActivity()).inflate(R.layout.fragment_skeleton, null);
    }

    @Override
    public void onViewCreated(final View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        bvSkeleton = view.findViewById(R.id.bv_skeleton);

        bvSkeleton.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (CommonUtils.isFastClick()) {
            ToasUtils.show("too fast click");
            return;
        }
        switch (v.getId()) {
            case R.id.bv_skeleton:
                boolean isSkeletonOn = !bvSkeleton.isOn();
                getCallback().skeletonDetectOn(isSkeletonOn);
                bvSkeleton.change(isSkeletonOn);
                break;
        }
    }

    @Override
    public void onClose() {
        getCallback().skeletonDetectOn(false);

        bvSkeleton.off();
    }
}
