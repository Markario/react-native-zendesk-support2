import {
	NativeModules,
	NativeEventEmitter,
	DeviceEventEmitter,
	NativeAppEventEmitter,
	Platform,
} from 'react-native';

const Emitter = new NativeEventEmitter(NativeModules.RNZenDeskSupport2);

export default NativeModules.RNZenDeskSupport2 || {}
export const zendeskEvents = {
	submitRequestCompletedSet: (callback) => {
		this.successListener = Emitter.addListener('submitRequestCompleted', (notification) => {
			if(callback) {
				callback(notification)
			}
		});
	},
	submitRequestCompletedClean: () => {
		this.successListener.remove();
	},
}