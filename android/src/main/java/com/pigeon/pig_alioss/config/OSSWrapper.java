package com.pigeon.pig_alioss.config;


import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.common.auth.OSSAuthCredentialsProvider;
import com.pigeon.pig_alioss.PigAliOssApplication;

public class OSSWrapper {

    private static final OSSWrapper WRAPPER = new OSSWrapper();
    private OSSClient mClient = null;
//    private static final String STS_INFO_URL = "http://192.168.3.92:7080/sts/getsts";
    private static final String STS_INFO_URL = "http://*.*.*.*:****/sts/getsts";
    private static final String OSS_ENDPOINT = "http://oss-cn-beijing.aliyuncs.com";

    private OSSWrapper() {
        OSSAuthCredentialsProvider authCredentialsProvider = new OSSAuthCredentialsProvider(STS_INFO_URL);
        mClient = new OSSClient(PigAliOssApplication.getActivity(), OSS_ENDPOINT, authCredentialsProvider);
    }

    public static OSSWrapper sharedWrapper() {
        return WRAPPER;
    }

    public OSSClient getClient() {
        return mClient;
    }
}
