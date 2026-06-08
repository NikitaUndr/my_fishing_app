package com.example.fishing_app2;

import android.app.Application;
import com.yandex.mapkit.MapKitFactory;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        MapKitFactory.setApiKey("516f5bc5-0c47-4d03-941a-095048ce5816");
    }
}