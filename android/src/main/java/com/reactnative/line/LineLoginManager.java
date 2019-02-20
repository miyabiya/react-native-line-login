package com.reactnative.line;

import android.app.Activity;
import android.content.Intent;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.linecorp.linesdk.LineAccessToken;
import com.linecorp.linesdk.LineApiResponse;
import com.linecorp.linesdk.LineProfile;
import com.linecorp.linesdk.Scope;
import com.linecorp.linesdk.api.LineApiClient;
import com.linecorp.linesdk.api.LineApiClientBuilder;
import com.linecorp.linesdk.auth.LineAuthenticationParams;
import com.linecorp.linesdk.auth.LineLoginApi;
import com.linecorp.linesdk.auth.LineLoginResult;

import java.util.Collections;
import java.util.Objects;

import io.reactivex.Single;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by vunguyen on 9/13/16.
 */
public class LineLoginManager extends ReactContextBaseJavaModule implements ActivityEventListener {
    private static final int REQUEST_CODE = 0x1234;

    @Nullable
    private String channelId;

    @Nullable
    private LineApiClient lineApiClient;

    public LineLoginManager(ReactApplicationContext reactContext) {
        super(reactContext);

        channelId = reactContext.getString(R.string.line_channel_id);

        reactContext.addActivityEventListener(this);

        assert channelId != null;
        LineApiClientBuilder apiClientBuilder = new LineApiClientBuilder(getReactApplicationContext(), channelId);
        lineApiClient = apiClientBuilder.build();
    }

    @Override
    public void onNewIntent(Intent intent) {

    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            LineLoginResult lineLoginResult = LineLoginApi.getLoginResultFromIntent(data);

            switch (lineLoginResult.getResponseCode()) {

                case SUCCESS:
                    LineAccessToken lineAccessToken = Objects.requireNonNull(lineLoginResult.getLineCredential()).getAccessToken();
                    LineProfile lineProfile = lineLoginResult.getLineProfile();

                    WritableMap result = Arguments.createMap();

                    result.putString("access_token", lineAccessToken.getTokenString());

                    if (lineProfile != null) {
                        result.putString("user_id", lineProfile.getUserId());
                        result.putString("display_name", lineProfile.getDisplayName());
                        result.putString("picture_url", Objects.requireNonNull(lineProfile.getPictureUrl()).toString());
                        result.putString("status_message", lineProfile.getStatusMessage());
                    }

                    loginPromise.resolve(result);
                    break;
                case CANCEL:
                    if (loginPromise != null) {
                        loginPromise.reject(new Exception(lineLoginResult.getErrorData().getMessage()));
                    }
                    break;
                case NETWORK_ERROR:
                    if (loginPromise != null) {
                        loginPromise.reject(new Exception(lineLoginResult.getErrorData().getMessage()));
                    }
                    break;
                case SERVER_ERROR:
                    if (loginPromise != null) {
                        loginPromise.reject(new Exception(lineLoginResult.getErrorData().getMessage()));
                    }
                    break;
                case AUTHENTICATION_AGENT_ERROR:
                    if (loginPromise != null) {
                        loginPromise.reject(new Exception(lineLoginResult.getErrorData().getMessage()));
                    }
                    break;
                case INTERNAL_ERROR:
                    if (loginPromise != null) {
                        loginPromise.reject(new Exception(lineLoginResult.getErrorData().getMessage()));
                    }
                    break;
                default:
                    if (loginPromise != null) {
                        loginPromise.reject(new Exception(lineLoginResult.getErrorData().getMessage()));
                    }
                    break;
            }
        } else {
            Log.d("xxxxxx", "Illegal response : onActivityResult(" + requestCode + ", " + resultCode + ", " + data + ")");
        }
    }

    @Override
    public String getName() {
        return "RNLineLoginManager";
    }

    private Promise loginPromise = null;

    @ReactMethod
    public void login(final Promise promise) {
        loginPromise = promise;

        try {
            assert channelId != null;
            Intent loginIntent = LineLoginApi.getLoginIntent(
                    getReactApplicationContext(),
                    channelId,
                    new LineAuthenticationParams.Builder()
                            .scopes(Collections.singletonList(Scope.PROFILE))
                            .build());
            Objects.requireNonNull(getCurrentActivity()).startActivityForResult(loginIntent, REQUEST_CODE);
        } catch (Exception e) {
            if (loginPromise != null) {
                loginPromise.reject(e);
            }
        }
    }

    @ReactMethod
    public void getUserProfile(final Promise promise) {
        startApiAsyncTask("getProfile", () -> {
            assert lineApiClient != null;
            return lineApiClient.getProfile();
        }, promise);
    }

    @ReactMethod
    public void logout() {
        startApiAsyncTask("logout", () -> {
            assert lineApiClient != null;
            return lineApiClient.logout();
        }, null);
    }

    @FunctionalInterface
    public interface FunctionWithApiResponse {
        LineApiResponse<?> method();
    }


    private Disposable startApiAsyncTask(String apiName, FunctionWithApiResponse function, Promise promise) {
        return Single.just(apiName)
                .subscribeOn(Schedulers.io())
                .map(name -> function.method())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe((Consumer<LineApiResponse<?>>) lineApiResponse -> {
                    switch (lineApiResponse.getResponseCode()) {

                        case SUCCESS:
                            switch (apiName) {
                                case "getProfile":
                                    if (promise != null) {
                                        LineProfile lineProfile = (LineProfile) lineApiResponse.getResponseData();

                                        WritableMap result = Arguments.createMap();


                                        result.putString("user_id", lineProfile.getUserId());
                                        result.putString("display_name", lineProfile.getDisplayName());
                                        result.putString("picture_url", Objects.requireNonNull(lineProfile.getPictureUrl()).toString());
                                        result.putString("status_message", lineProfile.getStatusMessage());

                                        promise.resolve(result);
                                    }
                                    break;
                                case "logout":
                                    if (promise != null) {
                                        promise.resolve(null);
                                    }
                                    break;
                                default:
                                    if (promise != null) {
                                        promise.reject(new Exception("Can not deal"));
                                    }
                                    break;
                            }
                            break;
                        case CANCEL:
                            if (promise != null) {
                                promise.reject(new Exception(lineApiResponse.getErrorData().getMessage()));
                            }
                            break;
                        case NETWORK_ERROR:
                            if (promise != null) {
                                promise.reject(new Exception(lineApiResponse.getErrorData().getMessage()));
                            }
                            break;
                        case SERVER_ERROR:
                            if (promise != null) {
                                promise.reject(new Exception(lineApiResponse.getErrorData().getMessage()));
                            }
                            break;
                        case AUTHENTICATION_AGENT_ERROR:
                            if (promise != null) {
                                promise.reject(new Exception(lineApiResponse.getErrorData().getMessage()));
                            }
                            break;
                        case INTERNAL_ERROR:
                            if (promise != null) {
                                promise.reject(new Exception(lineApiResponse.getErrorData().getMessage()));
                            }
                            break;
                        default:
                            if (promise != null) {
                                promise.reject(new Exception(lineApiResponse.getErrorData().getMessage()));
                            }
                            break;
                    }
                });
    }


}
