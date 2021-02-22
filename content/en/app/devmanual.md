---
title: Developer Manual
linktitle: Developer Manual
description: B00M uses TI's Simplelink AP provisioning.
date: 2020-01-18
publishdate: 2020-01-18
lastmod: 2020-01-18
categories: [app]
keywords: [app]
menu:
  docs:
    parent: "app"
    weight: 150
weight: 150	#rem
draft: false
aliases: [/app/prov/, /app/smartconfig]
toc: true
---

### Provisioning Process

Please see the [User Manual](/app/usermanual) for step-by-step instructions on using the app.

Briefly, the device starts up in Access Point (AP) mode and receives from the mobile app the SSID/password of the WiFi router to which it should connect. When the device connects to the WiFi router, its broadcast can be detected by the mobile phone app on the router as the mobile phone also connects to the router after it sends the SSID/password of the router to the device. On most modern WiFi routers this should work. 

### SmartConfig

SmartConfig is not used in ordinary provisioning scenarios. 

SmartConfig is a specific type of provisioning which is used in B00M only if the provisioning process as described above fails for whatever reason (usually because of the WiFi router blocking MDNS broadcasts). In SmartConfig, the device listens to communication between the mobile phone and the WiFi router and retrieves the SSID/password of the WiFi router using a [covert channel][].   

### Android 10

The starting point for this app is [WIFI-STARTER-PRO-ANDROID-SOURCE][] but the following changes have been made to it:

When targetting Android SDK versions >= 29, the following classes used in the app are deprecated:

```
android.net.ConnectivityManager.getActiveNetworkInfo()
android.net.Network.getType()
android.os.Environment.getExternalStorageDirectory()
android.net.wifi.WifiConfiguration
```

Now when connecting to a local Wifi AP (without internet) such as a new Simplelink device, a `WifiNetworkSpecifier.Builder` must now be used along with a `NetworkRequest.Builder` which results in a dialog prompting the user to pick the local Wifi AP to use with the app. 

When connecting to a Wifi AP with internet capability, a `List<WifiNetworkSuggestion>` can be added to `WifiManager.addNetworkSuggestion(...)` prior to making a `NetworkRequest`. The SSID/PSWD of the Wifi AP can be supplied when building the `WifiNetworkSuggestion`

### [Components](#components){#components}

Android annotations (org.androidannotations.annotations)

#### [MainActivity](#main){#main}

Android apps start in a class specified in `AndroidManifest.xml`. In this app `MainActivity` is this class. 

This Activity checks whether the required permissions are granted to the app and if not prompts the user via dialogs for said permissions. It then displays the `Help` screens.  It then creates the android.support.v4.app.FragmentTabHost and the individual `android.widget.TabWidget`s. Both the `support` libraries and `TabWidget` have been deprecated so need to be replaced. 


#### [DeviceConfiguration](#deviceconfig){#deviceconfig}

`DeviceConfiguration` is the class where  most of the logic is contained. 

Relvant code path in succesful device configuration :  

{{< code file="DeviceConfiguration.java" >}}
public class DeviceConfiguration extends Fragment {
    void tab_device_configuration_start_button() {
        // *1 [c.t.s.DeviceConfiguration]-[1267] *AP* Executing AddProfileAST to set a new wifi profile to SL device
        new AddProfileAsyncTask(mAddProfileAsyncTaskCallback).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, passing);
    }
    private AddProfileAsyncTaskCallback mAddProfileAsyncTaskCallback = new AddProfileAsyncTaskCallBack() {
        public void addProfileCompleted() {
            connectToWifi (ssidToAdd) ... 
                public void successfullyConnectedToNetwork(String ssid) {
                    // *2 [c.t.s.DeviceConfiguration]-[1442] *AP* Connected to SSID in profile added to SL device: "B00M". Searching for new SL devices in the local network for cfg verification: Activating Ping Bcast + UDPBcastServer + mDNS discovery
                    ((MainActivity) getActivity()).restartUdp();
                }
        }
    }
    class GetCFGResult extends AsyncTask<Boolean, Void, String> {
        ...
        protected void onPostExecute(String result) {
            // *14 [c.t.s.DeviceConfiguration]-[1526] *AP* Cfg result text: Provisioning Successful
        }

        protected String doInBackground(Boolean... params) { 
            // *11 [c.t.s.DeviceConfiguration]-[1566] GetCFGResult doInBackground called
            resultString = NetworkUtil.getCGFResultFromDevice(baseUrl, deviceVersion);
            // *12 [c.t.s.u.NetworkUtil]-[984] CFG result returned: 5
            // *13 [c.t.s.DeviceConfiguration]-[1576] *AP* Got cfg result from SL device: 5
        }
    }
    public BroadcastReceiver deviceFoundReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent){
            // *3 [c.t.s.DeviceConfiguration]-[378] *AP* Detected a new SL device (jsonString: {"name":"Movprov","host":"192.168.1.101","age":0})
            // *4 [c.t.s.DeviceConfiguration]-[391] *AP* Checking if the SL device found is the correct SL device - does "Movprov" equal "Movprov"

            confirmResult(true);
            // *7 [c.t.s.DeviceConfiguration]-[418] Found the device, stopping M discovery
            // *8 [c.t.s.DeviceConfiguration]-[419] *AP* Name is valid - found the correct SL device, stopping M discovery + Ping
        }
    }
    private void getCFG(final Boolean viaWifi) {
        // *9 [c.t.s.DeviceConfiguration]-[441] *AP* Number of attempts previously made to retrieve cfg verification from SL device as STA: 0
        // *10 [c.t.s.DeviceConfiguration]-[460] *AP* Executing cfg verification attempt no.: 1
        ... new GetCFGResult().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, viaWifi);
    }
    private void confirmResult(final Boolean viaWifi) {
        // *5 [c.t.s.DeviceConfiguration]-[486] *AP* Cfg verification via SL device as STA process begins
        // *6 [c.t.s.DeviceConfiguration]-[489] confirmResult called
        ... getCFG(viaWifi);
    }
    // This path only used when error occurs
    void checkParams() {
        ... 
        confirmResult(true);
    }
}
{{< /code >}}

#### [Settings](#settings){#settings}

The `Settings` tab contains the `Login/Settings` fragments and once logged in, the ability to email logs.

#### [ExternalConfirmation](#extconf){#extconf}

### [Gotchas](#gotchas){#gotchas}

The SmartConfig app uses Android 5.0 APIs with targetSdkVersion 21 which has inbuilt support for Apache HTTP client. Android 6.0 (API Level 23) removes support for the Apache HTTP client so using targetSdkVersion higher than 21 will cause compile errors unless the following is added to build.gradle:

{{< code file="build.gradle" >}}
android {
    useLibrary 'org.apache.http.legacy'
}
{{< /code >}}

When calling `builder.build().getEncodedQuery` on the `android.net.Uri.Builder`, the builder needs to be populated with something like `builder.appendQueryParameter(...)` prior to calling builder.build() so that when building, the builder isn't null.

Following error may be encountered Android 10 onwards if Location permission hasn't been granted to the app:
```
E WifiService: Permission violation - getScanResults not allowed for uid=10022, packageName=com.google.android.gms, reason=java.lang.SecurityException: Location mode is disabled for the device
```
Wifi scans now require Location permissions! Fixed with toggling "Access my location" under Settings->Location.

Only during the provisioning process, the communication between the provisioning app and the B00MIN-SL device is in clear text. Android 10 onwards requires all communication to be encrypted. All communication between the app/device and the wider internet is encrypted so that's not an issue. But to facilitate the clear text between the app and the device while provisioning, the following needs to be added to `AndroidManifest.xml`
```
<application> android:usesCleartextTraffic="true" >
```

The following errors still occur and needs resolution: 
```
E InputDispatcher: Window handle Window{850d188 u0 <package-name>/<package-name>.MainActivity_} has no registered input channel
```
Another error to do with non-SDK interfaces (certain fields have been made private since Android 10) 
```
02-07 20:57:20.436  6042  6042 W 00m.smartconfi: Accessing hidden field Landroid/net/ConnectivityManager;->mService:Landroid/net/IConnectivityManager; (greylist-max-p, reflection, denied)
02-07 20:57:20.436  6042  6042 W System.err: java.lang.NoSuchFieldException: No field mService in class Landroid/net/ConnectivityManager; (declaration of 'android.net.ConnectivityManager' appears in /system/framework/framework.jar!classes2.dex)                                                                         
```
#### [grant-uri-permission](){}

A work-around is required for `android.support.v4.content.FileProvider`. Even if the `FileProvider` is granted Uri permissions using the [grant-uri-permission](https://developer.android.com/guide/topics/manifest/grant-uri-permission-element) element in `AndroidManifest.xml`, it doesn't function in the same way Android 10 onwards. The following error is encountered.

```
02-07 12:59:14.958 10340 10377 E DatabaseUtils: Writing exception to parcel                                                                    
02-07 12:59:14.958 10340 10377 E DatabaseUtils: java.lang.SecurityException: Permission Denial: reading android.support.v4.content.FileProvider uri content://<package-name>.fileprovider/external_files/Android/data/in.b00m.smartconfig/files/logs/log.txt from pid=10875, uid=1000 requires the provider be exported, or grantUriPermission() 
02-07 12:59:14.958 10340 10377 E DatabaseUtils:         at android.content.ContentProvider.enforceReadPermissionInner(ContentProvider.java:729)                                                       
02-07 12:59:14.958 10340 10377 E DatabaseUtils:         at android.content.ContentProvider$Transport.enforceReadPermission(ContentProvider.java:602)                                                   
02-07 12:59:14.958 10340 10377 E DatabaseUtils:         at android.content.ContentProvider$Transport.query(ContentProvider.java:231)                  
02-07 12:59:14.958 10340 10377 E DatabaseUtils:         at android.content.ContentProviderNative.onTransact(ContentProviderNative.java:104)
02-07 12:59:14.958 10340 10377 E DatabaseUtils:         at android.os.Binder.execTransactInternal(Binder.java:1021)                                                                                       
02-07 12:59:14.958 10340 10377 E DatabaseUtils:         at android.os.Binder.execTransact(Binder.java:994)                                                                                            
```
The temporary work-around to this involves getting a list of `ResolveInfo` from `queryIntentActivities(...)` and granting each matching package Uri permission by calling `Context.grantUriPermission(packageName, path, Intent.FLAG_GRANT_WRITE_URI_PERMISSION)`

### [References](#references){#references}

+ [android.os.Environment](https://developer.android.com/reference/android/os/Environment?hl=en#getExternalStorageDirectory())

[WIFI-STARTER-PRO-ANDROID-SOURCE]: http://www.ti.com/tool/wifistarterpro

### [Appendix](#appendix){#appendix}

```
""2019-06-01 13:48:47,959 INFO  [c.t.s.u.ScanResultsPopUpView]-[610] *AP* Starting to retrieve list of access points SSIDs from SL device, for a list of available access points to choose from to send to SL device as profile to connect to
""2019-06-01 13:48:48,075 INFO  [c.t.s.u.ScanResultsPopUpView]-[612] *AP* Got SL device version with value: R2
""2019-06-01 13:48:48,077 INFO  [c.t.s.u.NetworkUtil]-[743] *AP* Getting list of available access points from SL device, from url: http://mysimplelink.net/netlist.txt
""2019-06-01 13:48:48,114 INFO  [c.t.s.u.NetworkUtil]-[759] *AP* Got netlist with results: 2B00M;2Beautiful Offices WiFi;2Beautiful Offices WiFi;2PlusnetWirelessC0548F;2Beautiful Offices WiFi;2bs_wifi;0National Express Coach;0airtame-oob-U8vGkd;2PlusnetWirelessC054F1;2Beautiful Offices WiFi;2BS_WIFI;2Michelle;0National Express Coach;X;X;X;X;X;X;X;X;X;X;X;X;X;X;X;X;X;
""2019-06-01 13:48:48,115 INFO  [c.t.s.u.ScanResultsPopUpView]-[615] *AP* Got list of networks: [2B00M, 2Beautiful Offices WiFi, 2Beautiful Offices WiFi, 2PlusnetWirelessC0548F, 2Beautiful Offices WiFi, 2bs_wifi, 0National Express Coach, 0airtame-oob-U8vGkd, 2PlusnetWirelessC054F1, 2Beautiful Offices WiFi, 2BS_WIFI, 2Michelle, 0National Express Coach]
""2019-06-01 13:48:48,116 INFO  [c.t.s.u.ScanResultsPopUpView]-[621] *AP* duplicate SSIDs removed list of networks: [2B00M, 2Beautiful Offices WiFi, 2PlusnetWirelessC0548F, 2bs_wifi, 0National Express Coach, 0airtame-oob-U8vGkd, 2PlusnetWirelessC054F1, 2BS_WIFI, 2Michelle]
""2019-06-01 13:48:48,117 INFO  [c.t.s.u.ScanResultsPopUpView]-[661] scan result list: [B00M, Beautiful Offices WiFi, PlusnetWirelessC0548F, bs_wifi, National Express Coach, airtame-oob-U8vGkd, PlusnetWirelessC054F1, BS_WIFI, Michelle]
""2019-06-01 13:48:59,684 INFO  [c.t.s.u.ScanResultsPopUpView]-[345] Chosen SSID from list to send to SL device in profile to connect to: 
SSID: B00M
PASS LEN: 8
SECURITY: WPA2
""2019-06-01 13:48:59,740 INFO  [c.t.s.u.NetworkUtil]-[129] Network state: 1
""2019-06-01 13:49:05,716 INFO  [c.t.s.DeviceConfiguration]-[1242] *AP* *** Starting SL device configuration in AP mode - "start configuration" button pressed ***
""2019-06-01 13:49:05,725 INFO  [c.t.s.DeviceConfiguration]-[1267] *AP* Executing AddProfileAST to set a new wifi profile to SL device
***
Send
SL device name: Movprov
SSID to add: B00M
Pass len: 8
***
""2019-06-01 13:49:06,026 INFO  [c.t.s.DeviceConfiguration]-[1389] *AP* Wifi profile addition to SL device in progress, msg: Set a new device name Movprov
""2019-06-01 13:49:06,029 INFO  [c.t.s.DeviceConfiguration]-[1389] *AP* Wifi profile addition to SL device in progress, msg: Device name was changed to Movprov
""2019-06-01 13:49:06,031 INFO  [c.t.s.DeviceConfiguration]-[1389] *AP* Wifi profile addition to SL device in progress, msg: Set a new Wifi configuration
""2019-06-01 13:49:07,046 INFO  [c.t.s.DeviceConfiguration]-[1389] *AP* Wifi profile addition to SL device in progress, msg: Starting configuration verification
""2019-06-01 13:49:07,558 INFO  [c.t.s.DeviceConfiguration]-[1417] *AP* Wifi profile addition to SL device completed successfully
""2019-06-01 13:49:07,563 INFO  [c.t.s.DeviceConfiguration]-[1418] *AP* Requested SL device restart and move state to STA for cfg verification
""2019-06-01 13:49:07,567 INFO  [c.t.s.DeviceConfiguration]-[1434] *AP* Connecting to "B00M" in order to obtain cfg verification
""2019-06-01 13:49:07,594 INFO  [c.t.s.u.WifiNetworkUtils]-[138] Connecting (Lollipop and up) to "B00M" With Timer: true
""2019-06-01 13:49:07,601 INFO  [c.t.s.u.WifiNetworkUtils]-[141] Disconnect: true
""2019-06-01 13:49:07,808 INFO  [c.t.s.u.WifiNetworkUtils]-[148] found config in list - connect from list
""2019-06-01 13:49:07,810 INFO  [c.t.s.u.WifiNetworkUtils]-[149] Connecting to ""B00M"" from list
""2019-06-01 13:49:07,876 INFO  [c.t.s.u.WifiNetworkUtils]-[178] Starting wifi connection short timer (40000ms)
""2019-06-01 13:49:07,882 INFO  [c.t.s.u.WifiNetworkUtils]-[225] State: DISCONNECTED Network:"null"
""2019-06-01 13:49:08,234 INFO  [c.t.s.u.WifiNetworkUtils]-[225] State: CONNECTED Network:"mobile.o2.co.uk"
""2019-06-01 13:49:10,573 INFO  [c.t.s.u.UdpBcastServer]-[139] Bcast SL dev found to app, name: Movprov
""2019-06-01 13:49:10,575 INFO  [c.t.s.MainActivity]-[814] SL Dev found PB: {"name":"Movprov","host":"192.168.1.101","age":0}
""2019-06-01 13:49:10,615 INFO  [c.t.s.u.UdpBcastServer]-[139] Bcast SL dev found to app, name: Movprov
""2019-06-01 13:49:10,618 INFO  [c.t.s.MainActivity]-[814] SL Dev found PB: {"name":"Movprov","host":"192.168.1.101","age":0}
""2019-06-01 13:49:11,061 INFO  [c.t.s.u.WifiNetworkUtils]-[225] State: DISCONNECTED Network:"mobile.o2.co.uk"
""2019-06-01 13:49:11,082 INFO  [c.t.s.u.UdpBcastServer]-[139] Bcast SL dev found to app, name: Movprov
""2019-06-01 13:49:11,085 INFO  [c.t.s.MainActivity]-[814] SL Dev found PB: {"name":"Movprov","host":"192.168.1.101","age":0}
""2019-06-01 13:49:11,286 INFO  [c.t.s.u.NetworkUtil]-[129] Network state: 1
""2019-06-01 13:49:11,302 INFO  [c.t.s.u.WifiNetworkUtils]-[225] State: CONNECTED Network:"null"
""2019-06-01 13:49:11,353 INFO  [c.t.s.u.WifiNetworkUtils]-[241] Connected to desired network: "B00M"
""2019-06-01 13:49:11,356 ERROR [c.t.s.u.WifiNetworkUtils]-[381] We are in WIFI
""2019-06-01 13:49:11,358 INFO  [c.t.s.DeviceConfiguration]-[1442] *AP* Connected to SSID in profile added to SL device: "B00M". Searching for new SL devices in the local network for cfg verification: Activating Ping Bcast + UDPBcastServer + mDNS discovery
""2019-06-01 13:49:11,368 INFO  [c.t.s.MainActivity]-[276] UDPBcastServer - restarted
""2019-06-01 13:49:11,376 INFO  [c.t.s.u.NetworkUtil]-[129] Network state: 1
""2019-06-01 13:49:12,019 INFO  [c.t.s.u.UdpBcastServer]-[139] Bcast SL dev found to app, name: Movprov
""2019-06-01 13:49:12,025 INFO  [c.t.s.MainActivity]-[814] SL Dev found PB: {"name":"Movprov","host":"192.168.1.101","age":0}
""2019-06-01 13:49:12,055 INFO  [c.t.s.DeviceConfiguration]-[378] *AP* Detected a new SL device (jsonString: {"name":"Movprov","host":"192.168.1.101","age":0})
""2019-06-01 13:49:12,057 INFO  [c.t.s.DeviceConfiguration]-[391] *AP* Checking if the SL device found is the correct SL device - does "Movprov" equal "Movprov"
""2019-06-01 13:49:12,059 INFO  [c.t.s.MainActivity]-[782] Ping - stopped
""2019-06-01 13:49:12,061 INFO  [c.t.s.DeviceConfiguration]-[486] *AP* Cfg verification via SL device as STA process begins
""2019-06-01 13:49:12,062 INFO  [c.t.s.DeviceConfiguration]-[489] confirmResult called
""2019-06-01 13:49:12,064 INFO  [c.t.s.DeviceConfiguration]-[418] Found the device, stopping M discovery
""2019-06-01 13:49:12,066 INFO  [c.t.s.DeviceConfiguration]-[419] *AP* Name is valid - found the correct SL device, stopping M discovery + Ping
""2019-06-01 13:49:12,066 INFO  [c.t.s.MainActivity]-[801] PB - Completed
""2019-06-01 13:49:14,381 INFO  [c.t.s.DeviceConfiguration]-[1223] *AP* Going to show progress dialog for mDNS scan
""2019-06-01 13:49:15,064 INFO  [c.t.s.DeviceConfiguration]-[441] *AP* Number of attempts previously made to retrieve cfg verification from SL device as STA: 0
""2019-06-01 13:49:15,067 INFO  [c.t.s.DeviceConfiguration]-[460] *AP* Executing cfg verification attempt no.: 1
""2019-06-01 13:49:15,070 INFO  [c.t.s.DeviceConfiguration]-[1566] GetCFGResult doInBackground called
""2019-06-01 13:49:15,299 INFO  [c.t.s.u.NetworkUtil]-[984] CFG result returned: 5
""2019-06-01 13:49:15,301 INFO  [c.t.s.DeviceConfiguration]-[1576] *AP* Got cfg result from SL device: 5
""2019-06-01 13:49:15,303 INFO  [c.t.s.DeviceConfiguration]-[1526] *AP* Cfg result text: Provisioning Successful
""2019-06-01 13:49:15,307 INFO  [c.t.s.MainActivity]-[814] SL Dev found PB: {"name":"Movprov","host":"192.168.1.101","age":0}
""2019-06-01 13:49:15,314 INFO  [c.t.s.DeviceConfiguration]-[1540] *AP* Entered IP into SP: 192.168.1.101
""2019-06-01 13:49:15,446 INFO  [c.t.s.DeviceConfiguration]-[996] *AP* *** SL device AP mode provisioning process complete. Success: true - SL device is connected to the network: true ***
""2019-06-01 13:49:15,449 INFO  [c.t.s.DeviceConfiguration]-[1004] *AP* Connecting to initial network: "Beautiful Offices WiFi"
""2019-06-01 13:49:15,466 INFO  [c.t.s.u.WifiNetworkUtils]-[138] Connecting (Lollipop and up) to "Beautiful Offices WiFi" With Timer: true
""2019-06-01 13:49:15,469 INFO  [c.t.s.u.WifiNetworkUtils]-[141] Disconnect: true
""2019-06-01 13:49:15,536 INFO  [c.t.s.u.WifiNetworkUtils]-[148] found config in list - connect from list
""2019-06-01 13:49:15,537 INFO  [c.t.s.u.WifiNetworkUtils]-[149] Connecting to ""Beautiful Offices WiFi"" from list
""2019-06-01 13:49:15,558 INFO  [c.t.s.u.WifiNetworkUtils]-[178] Starting wifi connection short timer (40000ms)
""2019-06-01 13:49:15,756 INFO  [c.t.s.MainActivity]-[782] Ping - stopped
""2019-06-01 13:49:15,767 INFO  [c.t.s.MainActivity]-[801] PB - Completed
```

[covert channel]: https://crypto.stackexchange.com/questions/10977/encoding-information-in-packet-lengths-to-actively-sidestep-encryption/11170#11170
