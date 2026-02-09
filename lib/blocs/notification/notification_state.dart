import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<DealerNotification> notifications;
  final bool hasMore;

  NotificationLoaded(this.notifications, {this.hasMore = true});

  @override
  List<Object?> get props => [notifications, hasMore];
}

class NotificationLoadingMore extends NotificationState {
  final List<DealerNotification> notifications;

  NotificationLoadingMore(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationUnauthorized extends NotificationState {}
