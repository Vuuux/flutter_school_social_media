const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
.document("/followers/{userId}/userFollowers/{followerId}")
.onCreate(async (snapshot, context) => {
console.log("Follower created", snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    //get followed user posts
    const followedUserPostRef = admin
    .firestore()
    .collection('posts')
    .doc(userId)
    .collection('userPosts');

    const timelinePostRef = admin
    .firestore()
    .collection('timeline')
    .doc(followerId)
    .collection('timelinePosts');

    const querySnapshot = await followedUserPostRef.get();

    querySnapshot.forEach(doc => {
    if(doc.exists) {
    const postId = doc.id;
    const postData = doc.data();
    timelinePostRef.doc(postId).set(postData);
    }
    })
});

exports.onDeleteFollower = functions.firestore
.document("/followers/{userId}/userFollowers/{followerId}")
.onDelete(async (snapshot, context) => {

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostRef = admin
    .firestore()
    .collection("timeline")
    .doc(followerId)
    .collection("timelinePosts")
    .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostRef.get();
    querySnapshot.forEach(doc => {
    if(doc.exists) {
        doc.ref.delete();
    }})
});

exports.onCreatePost = functions.firestore
.document("/posts/{userId}/userPosts/{postId}")
.onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    //Get all follower of user
    const userFollowRef = admin
    .firestore()
    .collection("followers")
    .doc(userId)
    .collection("userFollowers");

    const querySnapshot = await userFollowRef.get();

    //add new post to follower timeline
    querySnapshot.forEach(doc => {
    const followerId = doc.id;

    admin
    .firestore()
    .collection('timeline')
    .doc(followerId)
    .collection('timelinePosts')
    .doc(postId)
    .set(postCreated);
    });
});

exports.onUpdatePost = functions.firestore
.document("/posts/{userId}/userPosts/{postId}")
.onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

        //Get all follower of user
        const userFollowRef = admin
        .firestore()
        .collection("followers")
        .doc(userId)
        .collection("userFollowers");

        const querySnapshot = await userFollowRef.get();

        //update new post to follower timeline
        querySnapshot.forEach(doc => {
        const followerId = doc.id;

        admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get().then(doc => {
        if(doc.exists) {
        doc.ref.update(postUpdated)
                }
            });
        });
});

exports.onDeletePost = functions.firestore
.document("/posts/{userId}/userPosts/{postId}")
.onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

        //Get all follower of user
        const userFollowRef = admin
        .firestore()
        .collection("followers")
        .doc(userId)
        .collection("userFollowers");

        const querySnapshot = await userFollowRef.get();

        //update new post to follower timeline
        querySnapshot.forEach(doc => {
        const followerId = doc.id;

        admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get().then(doc => {
        if(doc.exists) {
        doc.ref.delete()
                }
            });
        });
});

exports.onCreateActivityFeedItem = functions.firestore
.document('/feeds/{userId}/feedItems/{activityFeedItem}')
.onCreate(async (snapshot, context) => {
    console.log('Activity Feed item created!', snapshot.data());
    //GET USER
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.collection('tokens').doc(userId).get();

    //CHECK IF HAVE NOTIFICATION;
    const androidNotificationToken = doc.data().token;
    const createdActivityFeedItem = snapshot.data();

    console.log("created Activity Feed:" + snapshot.data());
    if(androidNotificationToken) {
        //send notification
        sendNotification(androidNotificationToken, createdActivityFeedItem);
    }
    else {
        console.log("no token for user, cannot send notification");
    }

    function sendNotification(androidNotificationToken, activityFeedItem) {
    let body;

    switch(activityFeedItem.type) {
        case "comment":
            body = `${activityFeedItem.username} đã trả lời: ${activityFeedItem.commentData}`;
            break;
        case "like":
            body = `${activityFeedItem.username} đã thích bài viết của bạn`;
            break;
        case "accept-request":
            body = `${activityFeedItem.username} đã chấp nhận yêu cầu theo dõi`;
            break;
        case "request":
            body = `${activityFeedItem.username} đã yêu cầu theo dõi bạn`;
            break;
        default:
            break;
    }
    console.log('BODY:' + body);
    const message = {
        notification: {body},
        token: androidNotificationToken,
        data: {recipient: userId}
        };
    console.log('message:' + message);
    admin.messaging().send(message).then(response => {
        console.log("Successfully sent message", response);
    })
    .catch(error => {
        console.log("Error sending message:", error);
    })
    }
});