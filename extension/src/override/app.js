var app = new Vue({
    el: '#app',

    data: {
        state: 'connecting',
        devices: null,
        prefs: {
            sendCloseRequestOnClick: false,
            truncateTabTitles: true,
            reverseTabOrder: false
        }
    },

    created() {
        // Non-observables
        this.port = null;
        this.pendingHandler = null;
        this.timeagoInstance = timeago();
    },

    beforeMount() {
        this.fetchPrefs();
        this.connect();
        this.fetchTabs();
    },

    methods: {
        connect() {
            // Doing one-shot chrome.runtime.sendMessage calls, while convenient, seems
            // to not play nice with interspersed native messaging calls. So we need
            // a dedicated port.

            this.port = chrome.runtime.connect();
            this.port.onMessage.addListener(message => {
                if(this.pendingHandler) this.pendingHandler(message);
                this.pendingHandler = null;
            });
        },

        fetchPrefs() {
            chrome.storage.sync.get(this.prefs, newPrefs => {
                this.prefs = newPrefs;
            });
        },

        storePrefs() {
            chrome.storage.sync.set(this.prefs, () => {
                console.log('Preferences stored');
            });
        },

        _sendMessage(message, handler) {
            this.pendingHandler = response => {
                if (response && response.error) {
                    console.log('Error from background script:', response);
                    this.state = 'disconnected';
                    return;
                }

                handler(response);
            };

            this.port.postMessage(message);
        },

        fetchTabs(forceRefresh) {
            const message = { 'message': forceRefresh ? 'refreshTabs' : 'getTabs' };
            this._sendMessage(message, response => {
                this.devices = response;
            });
        },

        closeTab(device, tab) {
            const message = {
                'message': 'closeTab',
                'deviceName': device.name,
                'tabUUID': tab.uuid
            };

            this._sendMessage(message, response => {
                if(response.success) {
                    device.tabs.splice(device.tabs.indexOf(tab), 1);
                }
            });
        },

        closeAllTabs(device) {
            const message = {
                'message': 'closeAllTabs',
                'deviceName': device.name
            };

            this._sendMessage(message, response => {
                if(response.success) {
                    device.tabs = [];
                }
            });
        },

        lastModifiedString(device) {
            return this.timeagoInstance.format(device.lastModified);
        },

        handleTabClick(device, tab) {
            console.log('clicked', tab);
            if(this.prefs.sendCloseRequestOnClick) {
                this.closeTab(device, tab);
            }
        },

        sortedTabs(device) {
            if(!this.prefs.reverseTabOrder) return device.tabs;

            let reversedTabs = device.tabs.slice();
            reversedTabs.reverse();
            return reversedTabs;
        }
    },

    computed: {
        loading() {
            // Connecting or connected, but no devices yet
            return this.devices === null && this.state != 'disconnected';
        },

        loaded() {
            return this.devices !== null;
        },

        connectionError() {
            // We didn't get any devices, but we're not connecting either
            return this.devices === null && this.state == 'disconnected';
        },

        anyTabs() {
            if(!this.loaded) return false;

            for(const device of this.devices) {
                if(device.tabs && device.tabs.length > 0) return true;
            }

            return false;
        }
    }
});
