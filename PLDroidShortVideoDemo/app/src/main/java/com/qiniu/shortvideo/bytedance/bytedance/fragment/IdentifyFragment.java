package com.qiniu.shortvideo.bytedance.bytedance.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.activity.VideoRecordActivity;
import com.qiniu.shortvideo.bytedance.bytedance.adapter.FragmentVPAdapter;
import com.qiniu.shortvideo.bytedance.bytedance.base.IPresenter;

import java.util.ArrayList;
import java.util.List;

import static com.qiniu.shortvideo.bytedance.bytedance.fragment.FaceClusterFragment.REQUEST_CODE_CHOOSE;

public class IdentifyFragment extends BaseFeatureFragment<IPresenter, IdentifyFragment.IIdentifyCallback>
        implements VideoRecordActivity.OnCloseListener {
    private TabLayout tl;
    private ViewPager vp;

    public Fragment mFaceClusterFragment;
    private List<Fragment> mFragmentList;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_identify, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        tl = view.findViewById(R.id.tl_identify);
        vp = view.findViewById(R.id.vp_identify);

        initVP();
    }

    private void initVP() {
        mFragmentList = new ArrayList<>();
        List<String> titleList = new ArrayList<>();

        // 添加人脸 Fragment
        mFragmentList.add(new FaceDetectFragment().setCallback(getCallback()));
        titleList.add(getString(R.string.tab_face));
        // 添加人脸 Fragment
        mFragmentList.add(new PetFaceDetectFragment().setCallback(getCallback()));
        titleList.add(getString(R.string.tab_pet_face));
        // 添加手势 Fragment
        mFragmentList.add(new HandDetectFragment().setCallback(getCallback()));
        titleList.add(getString(R.string.tab_hand));
        // 添加人体 Fragment
        mFragmentList.add(new SkeletonDetectFragment().setCallback(getCallback()));
        titleList.add(getString(R.string.tab_body));
        // 添加分割 Fragment
        mFragmentList.add(new SegmentationFragment().setCallback(getCallback()));
        titleList.add(getString(R.string.tab_segmentation));
        // 添加人像对比 Fragment
        mFragmentList.add(new FaceVerifyFragment().setCallback(getCallback()));
        titleList.add(getString(R.string.tab_face_verify));
        mFaceClusterFragment = new FaceClusterFragment().setCallback(getCallback());
        mFragmentList.add(mFaceClusterFragment);
        titleList.add(getString(R.string.tab_face_cluster));

        // 添加距离检测 Fragment
//        mFragmentList.add(new HumanDistanceFragment().setCallback(getCallback()));
//        titleList.add(getString(R.string.setting_human_dist));

        FragmentVPAdapter adapter = new FragmentVPAdapter(
                getChildFragmentManager(), mFragmentList, titleList);
        vp.setAdapter(adapter);
        vp.setOffscreenPageLimit(mFragmentList.size());
        tl.setupWithViewPager(vp);
    }

    @Override
    public void onClose() {
        for (Fragment f : mFragmentList) {
            if (f instanceof VideoRecordActivity.OnCloseListener) {
                ((VideoRecordActivity.OnCloseListener) f).onClose();
            }
        }
    }


    public interface IIdentifyCallback extends
            FaceDetectFragment.IFaceCallback,
            PetFaceDetectFragment.IFaceCallback,
            HandDetectFragment.IHandCallBack,
            SkeletonDetectFragment.ISkeletonCallback,
            SegmentationFragment.IPortraitMattingCallback,
            FaceVerifyFragment.IFaceVerifyCallback,
            HumanDistanceFragment.IDistCallback {
    }
}
