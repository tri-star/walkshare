import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as sharp from "sharp";
import {tmpdir} from "os";
import {join, dirname, basename} from "path";
import * as fs from "fs-extra";

export const generateThumbnail = functions.runWith({memory: "512MB"}).https.onRequest(async (req, res) => {
  // リクエストヘッダの認証
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    res.status(401).send("Unauthorized");
    return;
  }
  const token = authHeader.split("Bearer ")[1];
  try {
    await admin.auth().verifyIdToken(token);
  } catch (e) {
    res.status(401).send("Unauthorized");
    return;
  }

  const filePath = req.query.key as string | undefined;
  const widthString = req.query.w as string | undefined;
  const heightString = req.query.h as string | undefined;

  if (filePath === undefined) {
    res.status(400).send("No file path defined");
    return;
  }
  if (widthString === undefined && heightString === undefined) {
    res.status(400).send("w,h or both must be defined");
    return;
  }

  const w = widthString !== undefined ? Number(widthString) : undefined;
  const h = heightString !== undefined ? Number(heightString) : undefined;
  const fileName = basename(filePath);
  const fileDir = dirname(filePath);
  const cachePath = join(fileDir, makeCacheFileName(fileName, w, h));
  const expirationDate = new Date();
  expirationDate.setDate(expirationDate.getDate() + 7);

  const bucket = admin.storage().bucket();
  const workDir = tmpdir();
  const originalFilePath = join(workDir, fileName);
  const resizedFilePath = join(workDir, `thumb_${fileName}`);

  // キャッシュが存在する場合はそのまま返す
  const cacheFile = bucket.file(cachePath);
  const exists = await cacheFile.exists();
  if (exists[0]) {
    const url = await bucket.file(cachePath).getSignedUrl({action: "read", expires: expirationDate});
    res.redirect(302, url[0]);
    return;
  }

  // 元画像のサムネイルを作成
  await fs.ensureDir(workDir);
  await bucket.file(filePath).download({destination: originalFilePath});

  const thumbnail = sharp(originalFilePath)
    .sharpen()
    .resize(w, h, {
      kernel: sharp.kernel.lanczos3,
    });

  if (originalFilePath.split(".").pop() === "jpg") {
    thumbnail.jpeg({quality: 90});
  }

  await thumbnail.toFile(resizedFilePath);

  await bucket.upload(resizedFilePath, {destination: cachePath});

  const url = await bucket.file(cachePath).getSignedUrl({action: "read", expires: expirationDate});
  res.redirect(302, url[0]);

  // ファイルをローカル上からunlinkした後、レスポンスを返す
  fs.unlinkSync(originalFilePath);
  fs.unlinkSync(resizedFilePath);
});


function makeCacheFileName(key: string, w: number | undefined, h: number | undefined) {
  const sizePart = [];
  const extension = key.split(".").pop();
  sizePart.push(w?.toString() ?? "auto");
  sizePart.push(h?.toString() ?? "auto");
  return `/_cache/${key}_${sizePart.join(":")}.${extension}`;
}
