import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String? email;
  final String role;
  final bool isGuest;
  final bool isBanned;
  final String? field;
  final bool idVerified;
  final double rating;
  final int totalReviews;
  final int totalJobs;
  final double earnings;
  final double monthlyEarnings;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    this.email,
    required this.role,
    required this.isGuest,
    required this.isBanned,
    this.field,
    required this.idVerified,
    required this.rating,
    required this.totalReviews,
    required this.totalJobs,
    required this.earnings,
    required this.monthlyEarnings,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      isGuest: data['isGuest'] ?? false,
      isBanned: data['isBanned'] ?? false,
      field: data['field'],
      idVerified: data['idVerified'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      totalJobs: data['totalJobs'] ?? 0,
      earnings: (data['earnings'] ?? 0).toDouble(),
      monthlyEarnings: (data['monthlyEarnings'] ?? 0).toDouble(),
      createdAt: data['createdAt'],
    );
  }
}
