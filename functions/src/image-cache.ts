import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sharp from 'sharp';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import * as fs from 'fs-extra';

admin.initializeApp();

exports.generateThumbnail = functions.https.onRequest(async (req, res) => {

    // TODO: リクエストヘッダの認証

    const filePath = req.query.key as string | undefined;
    const widthString = req.query.w as string | undefined;
    const heightString = req.query.h as string | undefined;

    if (filePath === undefined) {
        res.status(400).send('No file path defined');
        return;
    }
    if (widthString === undefined && heightString === undefined) {
        res.status(400).send('w,h or both must be defined');
        return;
    }

    const w = widthString !== undefined ? Number(widthString) : undefined;
    const h = heightString !== undefined ? Number(heightString) : undefined;
    const cachePath = makeCacheFileName(filePath, w, h);

    const bucket = admin.storage().bucket();
    const tempLocalFile = join(tmpdir(), filePath);
    const tempLocalDir = dirname(tempLocalFile);

    // キャッシュが存在する場合はそのまま返す
    const cacheFile = bucket.file(cachePath);
    const exists = await cacheFile.exists();
    if (exists[0]) {
        res.sendFile(cachePath);
        return;
    }

    // 元画像のサムネイルを作成
    await fs.ensureDir(tempLocalDir);
    await bucket.file(filePath).download({ destination: tempLocalFile });

    await sharp(tempLocalFile)
        .resize(w, h)
        .toFile(tempLocalFile);

    await bucket.upload(tempLocalFile, { destination: cachePath });

    // ファイルをローカル上からunlinkした後、レスポンスを返す
    fs.unlinkSync(tempLocalFile);

    res.sendFile(tempLocalFile);
});


function makeCacheFileName(key: string, w: number | undefined, h: number | undefined) {
    const sizePart = []
    const extension = key.split('.').pop()
    sizePart.push(w?.toString() ?? 'auto')
    sizePart.push(h?.toString() ?? 'auto')
    return `/_cache/${key}_${sizePart.join(':')}.${extension}`

}
