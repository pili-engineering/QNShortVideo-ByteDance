package com.qiniu.shortvideo.bytedance.bytedance.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


import com.qiniu.shortvideo.bytedance.R;
import com.qiniu.shortvideo.bytedance.bytedance.MainActivity;
import com.qiniu.shortvideo.bytedance.bytedance.adapter.StickerRVAdapter;
import com.qiniu.shortvideo.bytedance.bytedance.contract.StickerContract;
import com.qiniu.shortvideo.bytedance.bytedance.contract.presenter.StickerPresenter;
import com.qiniu.shortvideo.bytedance.bytedance.model.StickerItem;
import com.qiniu.shortvideo.bytedance.bytedance.utils.ToasUtils;

import java.io.File;

public class StickerFragment extends BaseFeatureFragment<StickerContract.Presenter, StickerFragment.IStickerCallback>
        implements StickerRVAdapter.OnItemClickListener, MainActivity.OnCloseListener, StickerContract.View {
    private RecyclerView rv;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        rv = (RecyclerView) inflater.inflate(R.layout.fragment_sticker, container, false);
        return rv;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setPresenter(new StickerPresenter());

        StickerRVAdapter adapter = new StickerRVAdapter(mPresenter.getItems(), this);
        rv.setLayoutManager(new GridLayoutManager(getContext(), 4));
        rv.setAdapter(adapter);
    }

    @Override
    public void onItemClick(StickerItem item) {
        if (item.hasTip()) {
            ToasUtils.show(item.getTip());
        }
        getCallback().onStickerSelected(new File(item.getResource()));
    }

    @Override
    public void onClose() {
        getCallback().onStickerSelected(null);

        ((StickerRVAdapter)rv.getAdapter()).setSelect(0);
    }

    public interface IStickerCallback {
        void onStickerSelected(File file);
    }
}
