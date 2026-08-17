import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.image,
  });

  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? image;

  String get displayName {
    final combined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return combined.isNotEmpty ? combined : username;
  }

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
