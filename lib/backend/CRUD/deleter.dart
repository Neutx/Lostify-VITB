import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Lostify/components/app_bar.dart';

Future<bool> deleteRequest(String postID, String? postImageURL) async {
  RequestUploadStatus previousRequestUploadStatus = requestUploadStatus.value;
  try {
    requestUploadStatus.value = RequestUploadStatus.deleting;

    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection('privateRequests').doc(postID).delete();

    if (postImageURL != null && postImageURL.isNotEmpty) {
      final storageRef =
          FirebaseStorage.instance.ref().child('postImages/$postID');

      await storageRef.delete();
    }

    deleteSuccess(previousRequestUploadStatus);

    return true;
  } catch (e) {
    debugPrint(e.toString());
    deleteFailure(previousRequestUploadStatus);
    return false;
  }
}

void deleteSuccess(RequestUploadStatus previousRequestUploadStatus) {
  requestUploadStatus.value = RequestUploadStatus.deleted;
  Timer(const Duration(seconds: 1), () {
    requestUploadStatus.value = previousRequestUploadStatus;
  });
}

void deleteFailure(RequestUploadStatus previousRequestUploadStatus) {
  requestUploadStatus.value = RequestUploadStatus.deleteError;
  Timer(const Duration(seconds: 1), () {
    requestUploadStatus.value = previousRequestUploadStatus;
  });
}
