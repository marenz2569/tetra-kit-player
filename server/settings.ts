export const webAudioPathPrefix = '/audio';

export const tetraKitLogPath = process.env.TETRA_KIT_LOG_PATH || '';
export const tetraKitRawPath = process.env.TETRA_KIT_RAW_PATH || '';
export const rawExtension = '.raw';
export const processedExtension = '.done';
export const undecodedExtention = '.out';

export const serverPort = process.env.SERVER_PORT;
export const parcelPort = process.env.PARCEL_PORT;

export const isDev = process.env.TS_NODE_DEV === 'true' ? true : false;

export const maxHistoryItems = 2000;
export const minimumFilesSize = 10000;
