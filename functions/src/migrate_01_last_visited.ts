import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// migrate01LastVisited({'json': {"mapId": "xxxxx"}});

export const migrate01LastVisited = functions.pubsub.topic("migrate01LastVisited")
  .onPublish(async (message: functions.pubsub.Message) => {
    // spotの一覧を取得する
    const mapId = message.json["mapId"];
    if (!mapId) {
      throw new Error("mapIdが指定されていません。");
    }
    const snapshot = await admin.firestore().collection("maps").doc(mapId).collection("spots").get();

    snapshot.docs.forEach(async (doc) => {
      const document = doc.data();
      if (!document) {
        return;
      }

      const photos = (await Promise.all<admin.firestore.DocumentData>(
        document.photos!.map((photo: admin.firestore.DocumentReference) => photo.get()),
      ));


      let lastVisited: Date|undefined = pickLatest(document.date?.toDate(), document.lastVisited?.toDate());
      if (photos && photos.length > 0) {
        lastVisited = pickLatest(getPhotoDate(photos), lastVisited);
      }

      await admin.firestore().collection("maps").doc(mapId).collection("spots").doc(doc.id).update({
        "last_visited": lastVisited ?? null,
      });
    });
    console.log("done");
  });


function getPhotoDate(documents: admin.firestore.DocumentData[]): Date|undefined {
  return documents.reduce<Date|undefined>((prev, current) => {
    return pickLatest(prev, current?.data()?.date?.toDate());
  }, undefined);
}


function pickLatest(date1?: Date, date2?: Date): Date|undefined {
  // 深夜・早朝のものはリアルなものではないので除外する
  // let hour = 0;
  // if (date1) {
  //   hour = date1.getHours() + 9;
  //   if (hour <= 6 || hour >= 20) {
  //     date1 = undefined;
  //   }
  // }
  // if (date2) {
  //   hour = date2.getHours() + 9;
  //   if (hour <= 6 || hour >= 20) {
  //     date2 = undefined;
  //   }
  // }

  if (!date1 && !date2) {
    return undefined;
  } else if (!date1 && date2) {
    return date2;
  } else if (date1 && !date2) {
    return date1;
  }
  if (date1 && date2) {
    if (date1 > date2) {
      return date1;
    } else if (date1 < date2) {
      return date2;
    }
  }
  return date1;
}
