var port = null;
var state = 'connecting';
var devices = null;

var _pendingHandler = null;
var _nextMessageID = 1;


function connect() {
    port = chrome.runtime.connectNative('com.github.misterfifths.cloudtabs_host');
    port.onMessage.addListener(onNativeMessage);
    port.onDisconnect.addListener(onDisconnected);

    state = 'connected';
    console.log('Connected to native host');
}

function onNativeMessage(message) {
    _pendingHandler(message);
    _pendingHandler = null;
}

function onDisconnected() {
    console.log('Disconnected from native host');
    state = 'disconnected';

    if(_pendingHandler) {
        _pendingHandler({ 'error': 'Disconnected' });
        _pendingHandler = null;
    }
}

function sendNativeMessage(message, handler) {
    message.id = _nextMessageID++;
    _pendingHandler = handler;
    port.postMessage(message);
}

function fetchTabs(callback) {
    sendNativeMessage({ 'message': 'getTabs' }, response => {
        if(response.error) { if(callback) callback(response); return; }

        devices = response.devices;
        console.log('Fetched tabs (' + devices.length + ' devices)');
        if(callback) callback(devices);
    });
}

function deviceForID(deviceUUID) {
    if(!devices) return undefined;

    for(const device of devices) {
        if(device.uuid == deviceUUID) return device;
    }

    return undefined;
}

function tabForID(device, tabUUID) {
    for(const tab of device.tabs) {
        if(tab.uuid == tabUUID) return tab;
    }

    return undefined;
}

function closeTab(device, tab, callback) {
    const message = {
        'message': 'closeTab',
        'deviceName': device.name,
        'tabUUID': tab.uuid
    };

    sendNativeMessage(message, response => {
        if(response.error) { if(callback) callback(response); return; }

        if(response.success) {
            device.tabs.splice(device.tabs.indexOf(tab), 1);
        }

        if(callback) callback(response.success);
    });
}

function closeTabByID(deviceUUID, tabUUID, callback) {
    const device = deviceForID(deviceUUID);
    if(!device) { if(callback) callback(false); return; }

    const tab = tabForID(device, tabUUID);
    if(!tab) { if(callback) callback(false); return; }

    closeTab(device, tab, callback);
}

function closeAllTabs(device, callback) {
    const message = {
        'message': 'closeAllTabs',
        'deviceName': device.name
    };

    sendNativeMessage(message, response => {
        if(response.error) { if(callback) callback(response); return; }

        if(response.success) {
            device.tabs = [];
        }

        if(callback) callback(response.success);
    });
}

function closeAllTabsByID(deviceUUID, callback) {
    const device = deviceForID(deviceUUID);
    if(!device) { if(callback) callback(false); return; }

    closeAllTabs(device, callback);
}

chrome.runtime.onConnect.addListener(port => {
    console.log('Connected with tab client');

    function sendResponse(message) {
        port.postMessage(message);
    }

    port.onMessage.addListener(message => {
        switch(message.message) {
            case 'refreshTabs':
                fetchTabs(result => sendResponse(result));
                break;

            case 'getTabs':
                if(state == 'disconnected') sendResponse({ 'error': 'Disconnected' });
                else sendResponse(devices);
                break;

            case 'closeTab':
                closeTabByID(message.deviceUUID, message.tabUUID, result => {
                    if(result.error) sendResponse(result);
                    else sendResponse({ success: result })
                });
                break;

            case 'closeAllTabs':
                closeAllTabsByID(message.deviceUUID, result => {
                    if(result.error) sendResponse(result);
                    else sendResponse({ success: result })
                });

            default:
                sendResponse({ error: 'Unknown message' });
        }
    });
});

chrome.runtime.onInstalled.addListener(function () {
    connect();
    fetchTabs();

    chrome.alarms.create('BackgroundRefresh', {
        periodInMinutes: 10
    });

    chrome.alarms.onAlarm.addListener(alarm => {
        console.log('Triggering background refresh');
        fetchTabs();
    });
});