package co.jjapp.homelesshelper;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.GeolocationPermissions;

public class HomelessHelperActivity extends Activity {
	
	WebView mWebView;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        mWebView = (WebView) findViewById(R.id.webview);
        mWebView.setWebChromeClient(new WebChromeClient() {
        	 public void onGeolocationPermissionsShowPrompt(String origin, GeolocationPermissions.Callback callback) {
        	    callback.invoke(origin, true, false);
        	 }
        	});
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.loadUrl("http://homelesshelper.us/mobile");
    }
}



