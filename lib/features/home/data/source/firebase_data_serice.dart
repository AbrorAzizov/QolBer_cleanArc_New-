
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:qolber_clean_arc/features/home/data/models/post_model.dart';

import '../../../../core/errors/firestore_failure.dart';

import '../../domain/entities/post.dart';

abstract class FireBaseDataService {
  Future<Either<FireStoreFailure, Unit>> createPost(Post post);
  Future<Either<FireStoreFailure, Unit>> deletePost(String postId);
  Future<Either<FireStoreFailure, List<Post>>> fetchAllPost();
  Future<Either<FireStoreFailure,List<Post>>> fetchPostByUserId(String userId);
}


class FireBaseDataServiceImp implements FireBaseDataService {


   final CollectionReference postCollection = FirebaseFirestore.instance.collection('post');

  @override
  Future<Either<FireStoreFailure, Unit>> createPost(Post post) async {
    try {
      final PostModel postModel = PostModel.fromEntity(post);
      await postCollection.doc(post.id).set(postModel.toJson());
      return Right(unit);
    } on FirebaseException catch (e) {
      debugPrint('$e');
      return Left(FireStoreFailure.fromExeption(e.code));
    }
  }


  @override
  Future<Either<FireStoreFailure, Unit>> deletePost(String postId) async {
    try {
      await postCollection.doc(postId).delete();
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(FireStoreFailure.fromExeption(e.code));
    }
  }

  @override
  Future<Either<FireStoreFailure,List<Post>>> fetchAllPost() async {
    try {
      final postSnapshot = await postCollection.orderBy('timestamp', descending: true).get();
      final List<Post> postList = postSnapshot.docs.map((e) {
        final json = e.data() as Map <String,dynamic>;
        final entity = PostModel.fromJson(json);
        return entity.toEntity();
      },).toList() ;

      return Right(postList);
    } on FirebaseException catch (error) {
      return Left(FireStoreFailure.fromExeption(error.code));
    }
  }

  @override
  Future<Either<FireStoreFailure,List<Post>>> fetchPostByUserId(String userId) async {
    try {
      final postSnapshot = await postCollection.where('userId', isEqualTo: userId ).get();
      final List<Post> postList = postSnapshot.docs.map((e) {
        final json = e.data() as Map <String,dynamic>;
        final entity = PostModel.fromJson(json);
        return entity.toEntity();
      },).toList() ;

      return Right(postList);
    } on FirebaseException catch (error) {
      return Left(FireStoreFailure.fromExeption(error.code));
    }
  }

}