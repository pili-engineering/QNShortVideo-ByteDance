package com.qiniu.shortvideo.bytedance.bytedance.contract;



import com.qiniu.shortvideo.bytedance.bytedance.base.BasePresenter;
import com.qiniu.shortvideo.bytedance.bytedance.base.IView;
import com.qiniu.shortvideo.bytedance.bytedance.model.StickerItem;

import java.util.List;

/**
 * Created by QunZhang on 2019-07-21 12:24
 */
public interface StickerContract {
    interface View extends IView {

    }

    abstract class Presenter extends BasePresenter<View> {
        public abstract List<StickerItem> getItems();
    }
}
