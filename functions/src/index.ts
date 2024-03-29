import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

import {migrate01LastVisited} from "./migrate_01_last_visited";
import {generateThumbnail} from "./image-cache";

admin.initializeApp();

// functions
export {generateThumbnail};


// migration
export {migrate01LastVisited};

export const migratePhoto = functions.pubsub.topic("aaa")
  .onPublish(async (message: functions.pubsub.Message) => {
    // spotの一覧を取得する
    const mapId = message.json["mapId"];
    if (!mapId) {
      throw new Error("mapIdが指定されていません。");
    }
    const snapshot = await admin.firestore().collection("maps")
      .doc(mapId).collection("spots").get();

    snapshot.docs.forEach(async (doc) => {
      const document = doc.data();
      if (!document) {
        return;
      }

      const photos = document.photos;
      if (!photos || photos.length == 0) {
        functions.logger.info(`写真がないためスキップします。 ID: ${doc.id}`, {id: doc.id});
        return;
      }

      const migratedPhotos: object[] = [];

      for (const p of photos) {
        const photoId = p.key;
        const photo = {
          date: p.date ?? null,
          extension: p.extension,
          name: null,
          key: p.key,
          uid: p.uid ?? null,
        };
        functions.logger.info(`写真を移植: key: ${p.key}`, {key: p.key});
        const photoReference = admin.firestore().collection("maps").doc(mapId)
          .collection("photos").doc(photoId);
        await photoReference.create(photo);

        migratedPhotos.push(photoReference);
      }

      await admin.firestore().collection("maps").doc(mapId)
        .collection("spots").doc(doc.id).update({
          photos: migratedPhotos,
        });
    });

    // アプリ側の改修
    //     - photoの一覧を作る処理の見直し
    //     - スポット情報を取得した段階では参照を保持する
    //     - 詳細画面等で一覧表示するタイミングで実際のデータを取得する
    //     - 保存する時もPhotoを保存した後、参照を記録するようにする
  });
