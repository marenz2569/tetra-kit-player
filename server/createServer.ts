import { Parcel } from "@parcel/core";
import * as express from 'express';
import * as http from 'http';
import * as https from 'https';
import * as fs from 'fs';
import { Server as SocketIOServer } from 'socket.io';
import { createProxyMiddleware } from 'http-proxy-middleware';

import {
    tetraKitRawPath,
    webAudioPathPrefix,
    isDev,
    serverPort,
		parcelPort,
} from './settings';

export default async (serverReadyCallback: (app: express.Express, io: SocketIOServer) => void): Promise<void> => {
    const app = express();

    const bundler = new Parcel({
			  entries: './client/index.html',
        mode: isDev ? 'development' : 'production',
				serveOptions: {
					port: Number(parcelPort)
				}
    });

		await bundler.watch();

    app.use(webAudioPathPrefix, express.static(tetraKitRawPath));
		const parcelMiddleware = createProxyMiddleware({
			  target: `http://localhost:${parcelPort}/`,
		});

		app.use('/', parcelMiddleware);

    let httpServer: http.Server;

		httpServer = http.createServer(app);

    const io = new SocketIOServer(httpServer);

    httpServer.listen(serverPort, () => {
        const port = (<any>httpServer.address()).port;
        console.log(`Server started: http://localhost:${port}`);
        serverReadyCallback(app, io);
    });
}
