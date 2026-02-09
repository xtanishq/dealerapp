import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  final String? type;
  final String? category;
  final String? language;

  LoadNotificationsEvent({
    this.type,
    this.category,
    this.language,
  });

  @override
  List<Object?> get props => [type, category, language];
}

class LoadMoreNotificationsEvent extends NotificationEvent {}

class RefreshNotificationsEvent extends NotificationEvent {}
