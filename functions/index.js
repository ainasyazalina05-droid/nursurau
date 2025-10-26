/**
 * NurSurau Cloud Functions
 * Sends push notifications to followers when a Surau posts a new program.
 */

const { setGlobalOptions } = require("firebase-functions/v2");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

exports.sendNotificationOnNewPost = onDocumentCreated(
  "surau/{surauId}/posts/{postId}",
  async (event) => {
    const post = event.data.data();
    const surauId = event.params.surauId;

    if (!post) {
      logger.warn("No post data found.");
      return;
    }

    // Get surau details
    const surauDoc = await admin.firestore().collection("surau").doc(surauId).get();
    const surauName = surauDoc.exists ? surauDoc.data().name : "Surau";

    // Get followers
    const followsSnap = await admin.firestore()
      .collection("follows")
      .where("surau_id", "==", surauId)
      .get();

    if (followsSnap.empty) {
      logger.info(`No followers found for ${surauName}`);
      return;
    }

    // Get all follower tokens
    const tokens = [];
    for (const doc of followsSnap.docs) {
      const userId = doc.data().user_id;
      const tokenDoc = await admin.firestore()
        .collection("user_tokens")
        .doc(userId)
        .get();
      if (tokenDoc.exists && tokenDoc.data().token) {
        tokens.push(tokenDoc.data().token);
      }
    }

    if (tokens.length === 0) {
      logger.info(`No tokens found for followers of ${surauName}`);
      return;
    }

    // Compose and send notification
    const message = {
      notification: {
        title: `📢 ${surauName} ada program baru!`,
        body: post.title || "Lihat maklumat lanjut di aplikasi NurSurau.",
      },
      tokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      logger.info(`✅ Sent ${response.successCount} notifications for ${surauName}`);
    } catch (error) {
      logger.error("Error sending notifications:", error);
    }
  }
);
